import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_calendar.dart';
import '../models/calendar_invite.dart';
import '../models/event.dart';

class FirestoreEventStore {
  FirestoreEventStore({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const Duration _inviteLifetime = Duration(days: 7);
  static const _inviteCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  Future<void> ensureUserDocument(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    final now = Timestamp.now();
    final email = user.email;
    final payload = <String, dynamic>{
      'email': email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'lastSeenAt': now,
    };

    if (!snapshot.exists) {
      payload['createdAt'] = now;
    }

    await userRef.set(payload, SetOptions(merge: true));
  }

  Future<String> ensureDefaultCalendarForUser(User user) async {
    await ensureUserDocument(user);

    final calendarId = user.uid;
    final calendarRef = _firestore.collection('calendars').doc(calendarId);
    final memberRef = calendarRef.collection('members').doc(user.uid);
    var createdCalendar = false;
    var createdMember = false;

    try {
      await calendarRef.update({
        'ownerId': user.uid,
        'title': 'My Calendar',
        'color': 'blue',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      if (_isNotFound(error)) {
        await calendarRef.set({
          'ownerId': user.uid,
          'title': 'My Calendar',
          'color': 'blue',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        createdCalendar = true;
      } else if (error.code != 'permission-denied') {
        rethrow;
      }
    }

    try {
      await memberRef.update({
        'uid': user.uid,
        'role': 'owner',
        'email': user.email,
      });
    } on FirebaseException catch (error) {
      if (_isNotFound(error)) {
        await memberRef.set({
          'uid': user.uid,
          'role': 'owner',
          'email': user.email,
          'joinedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        createdMember = true;
      } else if (error.code != 'permission-denied') {
        rethrow;
      }
    }

    if (kDebugMode) {
      debugPrint(
        '[CalendarBootstrap] uid=${user.uid} isAnonymous=${user.isAnonymous} '
        'createdCalendar=$createdCalendar createdMember=$createdMember',
      );
    }

    return calendarId;
  }

  bool _isNotFound(FirebaseException error) {
    return error.code == 'not-found';
  }

  Future<AppCalendar> createCalendar({
    required User owner,
    required String title,
    required String color,
  }) async {
    final calendarRef = _firestore.collection('calendars').doc();
    await calendarRef.set({
      'ownerId': owner.uid,
      'title': title,
      'color': color,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await calendarRef.collection('members').doc(owner.uid).set({
      'uid': owner.uid,
      'role': 'owner',
      'email': owner.email,
      'joinedAt': FieldValue.serverTimestamp(),
    });

    return AppCalendar(
      id: calendarRef.id,
      ownerId: owner.uid,
      title: title,
      color: color,
    );
  }

  Future<List<AppCalendar>> fetchCalendarsForUser(String uid) async {
    final memberships = await _firestore
        .collectionGroup('members')
        .where('uid', isEqualTo: uid)
        .get();

    final calendarIds = _extractCalendarIds(memberships.docs);
    if (kDebugMode) {
      debugPrint(
        '[CalendarMembership] uid=$uid memberships=${memberships.docs.length} '
        'calendarIds=$calendarIds',
      );
    }
    return _fetchCalendarsByIds(calendarIds);
  }

  Stream<List<AppCalendar>> watchMyCalendars(User user) async* {
    var defaultCalendarCreated = false;
    final membershipQuery =
        _firestore.collectionGroup('members').where('uid', isEqualTo: user.uid);

    await for (final memberships in membershipQuery.snapshots()) {
      final calendarIds = _extractCalendarIds(memberships.docs);
      if (kDebugMode) {
        debugPrint(
          '[CalendarMembership] uid=${user.uid} isAnonymous=${user.isAnonymous} '
          'memberships=${memberships.docs.length} calendarIds=$calendarIds',
        );
      }

      if (calendarIds.isEmpty && !defaultCalendarCreated) {
        defaultCalendarCreated = true;
        await ensureDefaultCalendarForUser(user);
        continue;
      }

      yield await _fetchCalendarsByIds(calendarIds);
    }
  }

  Future<bool> hasCalendarMembership({
    required String calendarId,
    required String uid,
  }) async {
    final memberDoc = await _firestore
        .collection('calendars')
        .doc(calendarId)
        .collection('members')
        .doc(uid)
        .get();
    return memberDoc.exists;
  }

  Future<String?> fetchMembershipRole({
    required String calendarId,
    required String uid,
  }) async {
    final memberDoc = await _firestore
        .collection('calendars')
        .doc(calendarId)
        .collection('members')
        .doc(uid)
        .get();
    if (!memberDoc.exists) {
      return null;
    }
    return memberDoc.data()?['role']?.toString();
  }

  Future<String> createInvite(
    String calendarId,
    String email,
    String role,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Please sign in to create invites.');
    }

    final normalizedEmail = email.trim().toLowerCase();
    if (role != 'viewer' && role != 'editor') {
      throw StateError('Invite role must be viewer or editor.');
    }

    final now = DateTime.now();
    for (var attempt = 0; attempt < 8; attempt++) {
      final inviteCode = _generateInviteCode();
      final codeRef = _firestore.collection('inviteCodes').doc(inviteCode);
      final existingCode = await codeRef.get();
      if (existingCode.exists) {
        continue;
      }

      final inviteRef = _firestore
          .collection('calendars')
          .doc(calendarId)
          .collection('invites')
          .doc(inviteCode);

      final expiresAt = Timestamp.fromDate(now.add(_inviteLifetime));
      final invitePayload = <String, dynamic>{
        'inviteId': inviteCode,
        'calendarId': calendarId,
        'role': role,
        'createdBy': user.uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': expiresAt,
      };
      if (normalizedEmail.isNotEmpty) {
        invitePayload['emailLower'] = normalizedEmail;
      }

      final codePayload = <String, dynamic>{
        'inviteId': inviteCode,
        'calendarId': calendarId,
        'role': role,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': expiresAt,
      };
      if (normalizedEmail.isNotEmpty) {
        codePayload['emailLower'] = normalizedEmail;
      }

      final batch = _firestore.batch();
      batch.set(inviteRef, invitePayload);
      batch.set(codeRef, codePayload);
      await batch.commit();
      return inviteCode;
    }

    throw StateError('Could not generate a unique invite code. Please retry.');
  }

  Future<void> revokeInvite(String calendarId, String inviteId) async {
    final inviteRef = _firestore
        .collection('calendars')
        .doc(calendarId)
        .collection('invites')
        .doc(
          inviteId,
        );
    final codeRef = _firestore.collection('inviteCodes').doc(inviteId);
    final batch = _firestore.batch();
    batch.set(
        inviteRef,
        {
          'status': 'revoked',
          'revokedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true));
    batch.delete(codeRef);
    await batch.commit();
  }

  Stream<List<CalendarInvite>> watchPendingInvites(String calendarId) {
    return _firestore
        .collection('calendars')
        .doc(calendarId)
        .collection('invites')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      return snapshot.docs
          .map((doc) => _inviteFromFirestore(doc, calendarId))
          .where(
            (invite) =>
                invite.status == 'pending' &&
                (invite.expiresAt == null || invite.expiresAt!.isAfter(now)),
          )
          .toList(growable: false);
    });
  }

  Future<void> acceptInvite(String inviteCode) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Please sign in to join shared calendars.');
    }
    if (user.isAnonymous) {
      throw StateError('Please upgrade to Google to join shared calendars.');
    }

    final emailLower = (user.email ?? '').trim().toLowerCase();
    if (emailLower.isEmpty) {
      throw StateError('A Google account email is required to join.');
    }

    final codeRef = _firestore.collection('inviteCodes').doc(inviteCode);
    final codeSnapshot = await codeRef.get();
    if (!codeSnapshot.exists) {
      throw StateError('Invite code is invalid or expired.');
    }
    final codeData = codeSnapshot.data() ?? <String, dynamic>{};
    final calendarId = (codeData['calendarId'] ?? '').toString();
    if (calendarId.isEmpty) {
      throw StateError('Invite code is invalid.');
    }
    final inviteRole = (codeData['role'] ?? '').toString();
    if (inviteRole != 'viewer' && inviteRole != 'editor') {
      throw StateError('Invite role is invalid.');
    }
    final expiresAt = _readTimestamp(codeData['expiresAt']);
    if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
      throw StateError('This invite has expired.');
    }
    final targetEmailLower = (codeData['emailLower'] ?? '').toString();
    if (targetEmailLower.isNotEmpty && targetEmailLower != emailLower) {
      throw StateError('Invite code is not for this account.');
    }

    final memberRef = _firestore
        .collection('calendars')
        .doc(calendarId)
        .collection('members')
        .doc(user.uid);
    final memberSnapshot = await memberRef.get();
    if (memberSnapshot.exists) {
      throw StateError('Already joined');
    }

    await memberRef.set({
      'uid': user.uid,
      'role': inviteRole,
      'email': user.email,
      'joinedAt': FieldValue.serverTimestamp(),
      // Used by rules to validate invite-based membership creation.
      'inviteId': inviteCode,
    });
  }

  Future<bool> calendarExists(String calendarId) async {
    final doc = await _firestore.collection('calendars').doc(calendarId).get();
    return doc.exists;
  }

  Stream<List<Event>> watchEvents(
    String calendarId,
    DateTime start,
    DateTime end,
  ) async* {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Cannot read cloud events while signed out.');
    }

    final hasAccess =
        await hasCalendarMembership(calendarId: calendarId, uid: uid);
    if (!hasAccess) {
      throw StateError('Current user is not a member of calendar $calendarId.');
    }

    final eventsRef = _firestore
        .collection('calendars')
        .doc(calendarId)
        .collection('events')
        .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('startAt');

    yield* eventsRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => _eventFromFirestore(doc, calendarId))
          .where((event) => event.deletedAt == null)
          .toList();
    });
  }

  Future<int> fetchCloudEventCount(
    String calendarId,
    DateTime start,
    DateTime end,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return 0;
    }

    final hasAccess =
        await hasCalendarMembership(calendarId: calendarId, uid: uid);
    if (!hasAccess) {
      throw StateError('Current user is not a member of calendar $calendarId.');
    }

    final snapshot = await _firestore
        .collection('calendars')
        .doc(calendarId)
        .collection('events')
        .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    var count = 0;
    for (final doc in snapshot.docs) {
      if (doc.data()['deletedAt'] == null) {
        count++;
      }
    }
    return count;
  }

  Future<Event> upsertEvent({
    required String calendarId,
    required Event event,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Cannot upsert cloud event while signed out.');
    }

    final hasAccess = await hasCalendarMembership(
      calendarId: calendarId,
      uid: user.uid,
    );
    if (!hasAccess) {
      throw StateError('Cannot write event: user is not a calendar member.');
    }

    final now = Timestamp.now();
    final docId = resolveDocumentId(event);
    final eventRef = _firestore
        .collection('calendars')
        .doc(calendarId)
        .collection('events')
        .doc(docId);

    final existing = await eventRef.get();
    final existingData = existing.data();
    final startAt = event.date;
    final endAt = event.endDate ??
        (event.allDay
            ? DateTime(startAt.year, startAt.month, startAt.day + 1)
            : startAt.add(const Duration(hours: 1)));

    await eventRef.set({
      'title': event.title,
      'description': event.description.isEmpty ? null : event.description,
      'location': event.location.isEmpty ? null : event.location,
      'allDay': event.allDay,
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'timezone':
          event.timezone.isEmpty ? DateTime.now().timeZoneName : event.timezone,
      'createdBy': (existingData?['createdBy'] ?? user.uid).toString(),
      'createdAt': existingData?['createdAt'] ?? now,
      'updatedAt': now,
      'deletedAt': null,
      'localId': event.id,
      'category': event.category,
      'hasReminder': event.hasReminder,
      'reminderTime': event.reminderTime == null
          ? null
          : Timestamp.fromDate(event.reminderTime!),
      'color': event.color,
    }, SetOptions(merge: true));

    return event.copyWith(
      cloudId: docId,
      calendarId: calendarId,
      endDate: endAt,
      updatedAt: now.toDate(),
      createdAt: (existingData?['createdAt'] is Timestamp)
          ? (existingData?['createdAt'] as Timestamp).toDate()
          : event.createdAt,
      createdBy: (existingData?['createdBy'] ?? user.uid).toString(),
    );
  }

  Future<void> softDeleteEvent({
    required String calendarId,
    required String eventId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Cannot delete cloud event while signed out.');
    }

    final hasAccess = await hasCalendarMembership(
      calendarId: calendarId,
      uid: user.uid,
    );
    if (!hasAccess) {
      throw StateError('Cannot delete event: user is not a calendar member.');
    }

    final eventRef = _firestore
        .collection('calendars')
        .doc(calendarId)
        .collection('events')
        .doc(eventId);

    await eventRef.set({
      'deletedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  String resolveDocumentId(Event event) {
    if (event.cloudId != null && event.cloudId!.isNotEmpty) {
      return event.cloudId!;
    }
    if (event.id.isNotEmpty) {
      final localIdEncoded =
          base64Url.encode(utf8.encode(event.id)).replaceAll('=', '');
      return 'local_$localIdEncoded';
    }

    final endAt = event.endDate ??
        (event.allDay
            ? DateTime(event.date.year, event.date.month, event.date.day + 1)
            : event.date.add(const Duration(hours: 1)));
    final timezone =
        event.timezone.isEmpty ? DateTime.now().timeZoneName : event.timezone;
    final seed = [
      event.title,
      event.date.toUtc().toIso8601String(),
      endAt.toUtc().toIso8601String(),
      event.allDay.toString(),
      timezone,
    ].join('|');
    final hash = _deterministicHash(seed);
    return 'evt_$hash';
  }

  Event _eventFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String calendarId,
  ) {
    final data = doc.data();
    final startAt = _readTimestamp(data['startAt']) ?? DateTime.now();
    final endAt = _readTimestamp(data['endAt']);

    return Event(
      id: (data['localId'] ?? doc.id).toString(),
      cloudId: doc.id,
      calendarId: calendarId,
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      location: (data['location'] ?? '').toString(),
      allDay: (data['allDay'] ?? false) as bool,
      timezone: (data['timezone'] ?? '').toString(),
      date: startAt,
      endDate: endAt,
      createdBy: data['createdBy']?.toString(),
      createdAt: _readTimestamp(data['createdAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
      deletedAt: _readTimestamp(data['deletedAt']),
      category: (data['category'] ?? 'personal').toString(),
      hasReminder: (data['hasReminder'] ?? false) as bool,
      reminderTime: _readTimestamp(data['reminderTime']),
      color: (data['color'] ?? '#2196F3').toString(),
    );
  }

  DateTime? _readTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

  CalendarInvite _inviteFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String calendarId,
  ) {
    final data = doc.data();
    return CalendarInvite(
      inviteId: (data['inviteId'] ?? doc.id).toString(),
      calendarId: (data['calendarId'] ?? calendarId).toString(),
      emailLower: (data['emailLower'] ?? '').toString(),
      role: (data['role'] ?? 'viewer').toString(),
      createdBy: (data['createdBy'] ?? '').toString(),
      status: (data['status'] ?? '').toString(),
      createdAt: _readTimestamp(data['createdAt']),
      expiresAt: _readTimestamp(data['expiresAt']),
    );
  }

  String _deterministicHash(String input) {
    var hash = 2166136261;
    for (final byte in utf8.encode(input)) {
      hash ^= byte;
      hash = (hash * 16777619) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  List<String> _extractCalendarIds(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> membershipDocs,
  ) {
    return membershipDocs
        .map((doc) => doc.reference.parent.parent?.id)
        .whereType<String>()
        .toSet()
        .toList(growable: false);
  }

  Future<List<AppCalendar>> _fetchCalendarsByIds(
      List<String> calendarIds) async {
    if (calendarIds.isEmpty) {
      return <AppCalendar>[];
    }

    final calendarSnapshots = await Future.wait(
      calendarIds
          .map((id) => _firestore.collection('calendars').doc(id).get())
          .toList(growable: false),
    );

    final calendars = <AppCalendar>[];
    for (final snapshot in calendarSnapshots) {
      if (!snapshot.exists) {
        continue;
      }
      final data = snapshot.data() ?? <String, dynamic>{};
      calendars.add(
        AppCalendar(
          id: snapshot.id,
          ownerId: (data['ownerId'] ?? '').toString(),
          title: (data['title'] ?? 'My Calendar').toString(),
          color: (data['color'] ?? 'blue').toString(),
        ),
      );
    }
    calendars.sort((a, b) => a.title.compareTo(b.title));
    return calendars;
  }

  String _generateInviteCode({int length = 8}) {
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      final index = random.nextInt(_inviteCodeAlphabet.length);
      buffer.write(_inviteCodeAlphabet[index]);
    }
    return buffer.toString();
  }
}
