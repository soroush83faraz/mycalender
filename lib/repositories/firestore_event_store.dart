import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/event.dart';

class FirestoreEventStore {
  FirestoreEventStore({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> ensureUserDocument(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    final now = Timestamp.now();
    final payload = <String, dynamic>{
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'lastSeenAt': now,
    };

    if (!snapshot.exists) {
      payload['createdAt'] = now;
    }

    await userRef.set(payload, SetOptions(merge: true));
  }

  Future<void> ensureUserEventsReady(User user) async {
    await ensureUserDocument(user);
    await _migrateLegacyCalendarEventsIfNeeded(user);
  }

  Future<void> _migrateLegacyCalendarEventsIfNeeded(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userSnapshot = await userRef.get();
    final userData = userSnapshot.data() ?? <String, dynamic>{};
    final alreadyMigrated = userData['eventsMigratedV1'] == true;
    if (alreadyMigrated) {
      return;
    }

    var copiedCount = 0;
    final legacyCalendars = await _firestore
        .collection('calendars')
        .where('ownerId', isEqualTo: user.uid)
        .get();

    for (final calendarDoc in legacyCalendars.docs) {
      final legacyEvents = await calendarDoc.reference.collection('events').get();
      for (final legacyEventDoc in legacyEvents.docs) {
        final targetRef =
            userRef.collection('events').doc(legacyEventDoc.id);
        final existing = await targetRef.get();
        if (existing.exists) {
          continue;
        }
        final migratedData = _migrateLegacyEventData(
          data: legacyEventDoc.data(),
          uid: user.uid,
          eventId: legacyEventDoc.id,
        );
        await targetRef.set(migratedData, SetOptions(merge: true));
        copiedCount++;
      }
    }

    await userRef.set({
      'eventsMigratedV1': true,
      'eventsMigratedAt': FieldValue.serverTimestamp(),
      'legacyCalendarsChecked': legacyCalendars.docs.length,
      'legacyEventsCopied': copiedCount,
    }, SetOptions(merge: true));
  }

  Map<String, dynamic> _migrateLegacyEventData({
    required Map<String, dynamic> data,
    required String uid,
    required String eventId,
  }) {
    final migrated = Map<String, dynamic>.from(data);
    migrated.remove('calendarId');
    migrated['localId'] = (migrated['localId'] ?? eventId).toString();
    migrated['createdBy'] = (migrated['createdBy'] ?? uid).toString();

    if (migrated['startAt'] == null && migrated['date'] is String) {
      migrated['startAt'] = Timestamp.fromDate(DateTime.parse(migrated['date']));
    }
    if (migrated['endAt'] == null && migrated['endDate'] is String) {
      migrated['endAt'] = Timestamp.fromDate(DateTime.parse(migrated['endDate']));
    }

    migrated.remove('date');
    migrated.remove('endDate');
    return migrated;
  }

  Stream<List<Event>> watchEventsForUser(
    String uid,
    DateTime start,
    DateTime end,
  ) async* {
    final authUid = _auth.currentUser?.uid;
    if (authUid == null || authUid != uid) {
      throw StateError('Cannot read cloud events for another user.');
    }

    final eventsRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('events')
        .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('startAt');

    yield* eventsRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map(_eventFromFirestore)
          .where((event) => event.deletedAt == null)
          .toList(growable: false);
    });
  }

  Future<int> fetchCloudEventCount(
    String uid,
    DateTime start,
    DateTime end,
  ) async {
    final authUid = _auth.currentUser?.uid;
    if (authUid == null || authUid != uid) {
      return 0;
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
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
    required String uid,
    required Event event,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != uid) {
      throw StateError('Cannot upsert cloud event while signed out.');
    }

    final now = Timestamp.now();
    final docId = resolveDocumentId(event);
    final eventRef =
        _firestore.collection('users').doc(uid).collection('events').doc(docId);

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
      endDate: endAt,
      updatedAt: now.toDate(),
      createdAt: (existingData?['createdAt'] is Timestamp)
          ? (existingData?['createdAt'] as Timestamp).toDate()
          : event.createdAt,
      createdBy: (existingData?['createdBy'] ?? user.uid).toString(),
    );
  }

  Future<void> softDeleteEvent({
    required String uid,
    required String eventId,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != uid) {
      throw StateError('Cannot delete cloud event while signed out.');
    }

    final eventRef =
        _firestore.collection('users').doc(uid).collection('events').doc(eventId);

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
    final startAt = event.date.toUtc().toIso8601String();
    return 'evt_${startAt.hashCode.abs()}';
  }

  Event _eventFromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final startAt = _readTimestamp(data['startAt']) ?? DateTime.now();
    final endAt = _readTimestamp(data['endAt']);

    return Event(
      id: (data['localId'] ?? doc.id).toString(),
      cloudId: doc.id,
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
}
