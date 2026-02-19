import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_calendar.dart';
import '../models/calendar_invite.dart';
import '../models/event.dart';
import '../models/holiday.dart';
import '../models/jalali_date.dart';
import '../models/settings.dart';
import '../repositories/firestore_event_store.dart';
import '../repositories/local_event_store.dart';
import '../services/auth_service.dart';

class CalendarProvider extends ChangeNotifier {
  static const String _guestUiLoggedOutKey = 'guest_ui_logged_out';
  static const String _selectedCalendarKeyPrefix = 'currentCalendarId_';

  CalendarProvider({
    LocalEventStore? localEventStore,
    FirestoreEventStore? firestoreEventStore,
  })  : _localEventStore = localEventStore ?? LocalEventStore(),
        _firestoreEventStore = firestoreEventStore ?? FirestoreEventStore();

  final LocalEventStore _localEventStore;
  final FirestoreEventStore _firestoreEventStore;

  JalaliDate _currentDate = JalaliDate.fromGregorian(DateTime.now());
  JalaliDate? _selectedDate;
  List<Event> _events = <Event>[];
  List<AppCalendar> _calendars = <AppCalendar>[];
  AppSettings _settings = AppSettings();
  String _currentView = 'month';
  User? _currentUser;
  String? _activeCalendarId;
  String? _lastFirestoreError;
  bool _isUsingFirestore = false;
  bool _isInitialized = false;
  int _localEventCount = 0;
  int _cloudEventCount = 0;
  bool _selectedCalendarExists = false;
  bool _selectedCalendarMembershipExists = false;
  String? _activeMembershipRole;
  bool _guestUiLoggedOut = false;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<Event>>? _cloudEventsSubscription;

  JalaliDate get currentDate => _currentDate;
  JalaliDate? get selectedDate => _selectedDate;
  List<Event> get events => _events;
  List<AppCalendar> get calendars => _calendars;
  AppSettings get settings => _settings;
  String get currentView => _currentView;
  User? get currentUser => _currentUser;
  String? get activeCalendarId => _activeCalendarId;
  String? get activeCalendarTitle => _currentUser == null ? null : 'My Calendar';
  String? get lastFirestoreError => _lastFirestoreError;
  bool get isUsingFirestore => _isUsingFirestore;
  bool get isInitialized => _isInitialized;
  bool get isUsingLocalFallback => _currentUser != null && !_isUsingFirestore;
  bool get isSignedIn => _currentUser != null;
  bool get isGuestUser => _currentUser?.isAnonymous ?? false;
  bool get isGuestUiLoggedOut => _guestUiLoggedOut;
  int get localEventCount => _localEventCount;
  int get cloudEventCount => _cloudEventCount;
  int get cloudCalendarsCount => _currentUser == null ? 0 : 1;
  bool get selectedCalendarExists => _selectedCalendarExists;
  bool get selectedCalendarMembershipExists => _selectedCalendarMembershipExists;
  String? get activeMembershipRole => _activeMembershipRole;
  bool get canEditActiveCalendarEvents => _currentUser != null;
  bool get isActiveCalendarOwner => _currentUser != null;
  bool get hasSelectedCalendar => _selectedCalendarExists;

  String get accountStatusLabel {
    if (_currentUser == null) return 'Not signed in';
    if (_currentUser!.isAnonymous) return 'Guest';
    return _currentUser!.email ?? _currentUser!.uid;
  }

  String get dataModeStatus =>
      isSignedIn && isUsingFirestore ? 'Cloud (Firestore)' : 'Local fallback';

  String roleForCalendar(String calendarId) {
    if (_currentUser != null && calendarId == _currentUser!.uid) {
      return 'owner';
    }
    return 'viewer';
  }

  List<Event> getEventsForDate(JalaliDate date) {
    return _events.where((event) {
      final eventJalali = JalaliDate.fromGregorian(event.date);
      return eventJalali.year == date.year &&
          eventJalali.month == date.month &&
          eventJalali.day == date.day;
    }).toList();
  }

  List<Holiday> getHolidaysForDate(JalaliDate date) {
    return Holiday.getHolidaysForMonth(date.month)
        .where((h) => h.day == date.day)
        .toList();
  }

  void setCurrentDate(JalaliDate date) {
    _currentDate = date;
    notifyListeners();
  }

  void setSelectedDate(JalaliDate? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void nextMonth() {
    if (_currentDate.month == 12) {
      _currentDate = JalaliDate(year: _currentDate.year + 1, month: 1, day: 1);
    } else {
      _currentDate = JalaliDate(
        year: _currentDate.year,
        month: _currentDate.month + 1,
        day: 1,
      );
    }
    notifyListeners();
  }

  void previousMonth() {
    if (_currentDate.month == 1) {
      _currentDate = JalaliDate(year: _currentDate.year - 1, month: 12, day: 1);
    } else {
      _currentDate = JalaliDate(
        year: _currentDate.year,
        month: _currentDate.month - 1,
        day: 1,
      );
    }
    notifyListeners();
  }

  void goToToday() {
    _currentDate = JalaliDate.fromGregorian(DateTime.now());
    _selectedDate = _currentDate;
    notifyListeners();
  }

  void setView(String view) {
    _currentView = view;
    notifyListeners();
  }

  Future<void> addEvent(Event event) async {
    _events.add(event);
    await _saveLocalEventsForCurrentScope(_events);
    _localEventCount = _events.length;
    await _upsertCloudEvent(event);
    notifyListeners();
  }

  Future<void> updateEvent(Event event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index == -1) return;
    _events[index] = event;
    await _saveLocalEventsForCurrentScope(_events);
    _localEventCount = _events.length;
    await _upsertCloudEvent(event);
    notifyListeners();
  }

  Future<void> deleteEvent(String eventId) async {
    final target = _events.cast<Event?>().firstWhere(
          (e) => e?.id == eventId,
          orElse: () => null,
        );
    _events.removeWhere((e) => e.id == eventId);
    await _saveLocalEventsForCurrentScope(_events);
    _localEventCount = _events.length;
    await _softDeleteCloudEvent(target, eventId);
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings settings) async {
    final normalizedDefaultView = _normalizeView(settings.defaultView);
    final previousDefaultView = _settings.defaultView;
    _settings = settings;
    if (_normalizeView(previousDefaultView) != normalizedDefaultView) {
      _currentView = normalizedDefaultView;
    }
    await _saveSettings();
    notifyListeners();
  }

  Future<void> loadData() async {
    if (_isInitialized) return;

    _events = <Event>[];
    _localEventCount = 0;
    await _loadSettings();
    await _loadGuestUiLogoutState();
    _currentUser = FirebaseAuth.instance.currentUser;

    _authSubscription?.cancel();
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);

    await _onAuthStateChanged(_currentUser);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setActiveCalendar(String calendarId) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;
    _activeCalendarId = uid;
    await _saveSelectedCalendarId(uid: uid, calendarId: uid);
    _refreshSingleUserCalendarState();
    notifyListeners();
  }

  Future<String> createInvite({
    required String email,
    required String role,
  }) async {
    throw StateError('Calendar sharing is disabled in private mode.');
  }

  Future<void> revokeInvite(String inviteId) async {
    throw StateError('Calendar sharing is disabled in private mode.');
  }

  Stream<List<CalendarInvite>> watchPendingInvitesForActiveCalendar() {
    return Stream<List<CalendarInvite>>.value(const <CalendarInvite>[]);
  }

  Future<String> acceptInvite(String inviteCode) async {
    throw StateError('Calendar sharing is disabled in private mode.');
  }

  Future<void> forceSyncLocalToCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to sync local events to cloud.');
    }
    _currentUser = user;
    _activeCalendarId = user.uid;
    _refreshSingleUserCalendarState();

    final localEvents = await _loadLocalEventsForUid(user.uid);
    final syncedEvents = <Event>[];
    for (final event in localEvents) {
      final synced = await _firestoreEventStore.upsertEvent(
        uid: user.uid,
        event: event,
      );
      syncedEvents.add(synced);
    }

    await _localEventStore.saveEvents(syncedEvents, uid: user.uid);
    _events = syncedEvents;
    _localEventCount = syncedEvents.length;
    await _refreshCloudCountForActiveUser();
    _isUsingFirestore = true;
    _lastFirestoreError = null;
    notifyListeners();
  }

  Future<void> clearLocalCache() async {
    final uid = _currentUser?.uid;
    if (uid != null) {
      await _localEventStore.clearEvents(uid: uid);
    }
    _localEventCount = 0;
    if (_currentUser == null || !_isUsingFirestore) {
      _events = <Event>[];
      notifyListeners();
    }
  }

  Future<void> refreshCloudNow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _isUsingFirestore = false;
      _events = <Event>[];
      _localEventCount = 0;
      _selectedCalendarExists = false;
      _selectedCalendarMembershipExists = false;
      _activeMembershipRole = null;
      notifyListeners();
      return;
    }

    _currentUser = user;
    _activeCalendarId = user.uid;
    _refreshSingleUserCalendarState();
    try {
      await _firestoreEventStore.ensureUserEventsReady(user);
      await _refreshCloudCountForActiveUser();
      _lastFirestoreError = null;
      _subscribeToCloudEvents(user.uid);
    } catch (error) {
      await _fallbackToLocal(error);
    }

    notifyListeners();
  }

  Future<AuthUpgradeResult> upgradeToGoogle({
    Future<bool> Function()? onExistingAccountConfirm,
  }) async {
    final result = await AuthService.instance.upgradeToGoogle(
      onExistingAccountConfirm: onExistingAccountConfirm,
    );
    _currentUser = FirebaseAuth.instance.currentUser;
    notifyListeners();
    return result;
  }

  Future<void> signOutCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.isAnonymous) {
      _guestUiLoggedOut = true;
      await _saveGuestUiLogoutState();
      await _applyUiSignedOutState();
      notifyListeners();
      return;
    }

    _guestUiLoggedOut = false;
    await _saveGuestUiLogoutState();
    await AuthService.instance.signOut();
  }

  Future<void> continueAsGuest() async {
    final wasGuestUiLoggedOut = _guestUiLoggedOut;
    _guestUiLoggedOut = false;
    await _saveGuestUiLogoutState();
    final user = await AuthService.instance.continueAsGuest();
    if (user != null && user.isAnonymous && wasGuestUiLoggedOut) {
      await _onAuthStateChanged(user);
      return;
    }
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _lastFirestoreError = null;
    await _cloudEventsSubscription?.cancel();
    _cloudEventsSubscription = null;

    if (user == null) {
      _guestUiLoggedOut = false;
      await _saveGuestUiLogoutState();
      await _applyUiSignedOutState();
      notifyListeners();
      return;
    }

    if (user.isAnonymous && _guestUiLoggedOut) {
      await _applyUiSignedOutState();
      notifyListeners();
      return;
    }

    _currentUser = user;
    _events = await _loadLocalEventsForUid(user.uid);
    _localEventCount = _events.length;
    _activeCalendarId = user.uid;
    await _saveSelectedCalendarId(uid: user.uid, calendarId: user.uid);
    _refreshSingleUserCalendarState();

    if (!user.isAnonymous && _guestUiLoggedOut) {
      _guestUiLoggedOut = false;
      await _saveGuestUiLogoutState();
    }

    try {
      await _firestoreEventStore.ensureUserEventsReady(user);
      await _refreshCloudCountForActiveUser();
      _subscribeToCloudEvents(user.uid);
      _isUsingFirestore = true;
      _lastFirestoreError = null;
    } catch (error) {
      await _fallbackToLocal(error);
    }

    notifyListeners();
  }

  void _refreshSingleUserCalendarState() {
    final user = _currentUser;
    if (user == null) {
      _calendars = <AppCalendar>[];
      _selectedCalendarExists = false;
      _selectedCalendarMembershipExists = false;
      _activeMembershipRole = null;
      return;
    }

    _calendars = <AppCalendar>[
      AppCalendar(
        id: user.uid,
        ownerId: user.uid,
        title: 'My Calendar',
        color: 'blue',
        membershipRole: 'owner',
      ),
    ];
    _selectedCalendarExists = true;
    _selectedCalendarMembershipExists = true;
    _activeMembershipRole = 'owner';
  }

  Future<void> _refreshCloudCountForActiveUser() async {
    final uid = _currentUser?.uid;
    if (uid == null) {
      _cloudEventCount = 0;
      return;
    }
    _cloudEventCount = await _firestoreEventStore.fetchCloudEventCount(
      uid,
      DateTime(1900),
      DateTime(2100, 12, 31),
    );
  }

  void _subscribeToCloudEvents(String uid) {
    _cloudEventsSubscription?.cancel();
    _cloudEventsSubscription = _firestoreEventStore
        .watchEventsForUser(uid, DateTime(1900), DateTime(2100, 12, 31))
        .listen(
      (cloudEvents) async {
        _isUsingFirestore = true;
        _lastFirestoreError = null;
        _cloudEventCount = cloudEvents.length;
        _events = cloudEvents;
        await _localEventStore.saveEvents(cloudEvents, uid: uid);
        _localEventCount = cloudEvents.length;
        notifyListeners();
      },
      onError: (Object error) async {
        await _fallbackToLocal(error);
      },
    );
  }

  Future<void> _upsertCloudEvent(Event event) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;

    try {
      final syncedEvent = await _firestoreEventStore.upsertEvent(
        uid: uid,
        event: event,
      );
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = syncedEvent;
        await _localEventStore.saveEvents(_events, uid: uid);
        _localEventCount = _events.length;
      }
      _isUsingFirestore = true;
      _cloudEventCount = _events.length;
      _lastFirestoreError = null;
    } catch (error) {
      _isUsingFirestore = false;
      _lastFirestoreError = error.toString();
    }
  }

  Future<void> _softDeleteCloudEvent(Event? event, String eventId) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;

    try {
      final targetEvent = event ??
          Event(
            id: eventId,
            title: '',
            date: DateTime.fromMillisecondsSinceEpoch(0),
          );
      await _firestoreEventStore.softDeleteEvent(
        uid: uid,
        eventId: _firestoreEventStore.resolveDocumentId(targetEvent),
      );
      _isUsingFirestore = true;
      _cloudEventCount = _events.length;
      _lastFirestoreError = null;
    } catch (error) {
      _isUsingFirestore = false;
      _lastFirestoreError = error.toString();
    }
  }

  Future<void> _fallbackToLocal(Object error) async {
    _isUsingFirestore = false;
    _lastFirestoreError = error.toString();
    _selectedCalendarMembershipExists = false;
    _activeMembershipRole = null;
    final uid = _currentUser?.uid;
    _events = uid == null ? <Event>[] : await _loadLocalEventsForUid(uid);
    _localEventCount = _events.length;
    notifyListeners();
  }

  Future<void> _applyUiSignedOutState() async {
    await _cloudEventsSubscription?.cancel();
    _cloudEventsSubscription = null;
    _currentUser = null;
    _isUsingFirestore = false;
    _activeCalendarId = null;
    _selectedCalendarExists = false;
    _selectedCalendarMembershipExists = false;
    _activeMembershipRole = null;
    _calendars = <AppCalendar>[];
    _cloudEventCount = 0;
    _events = <Event>[];
    _localEventCount = 0;
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', json.encode(_settings.toJson()));
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString('settings');
    if (settingsString != null) {
      _settings = AppSettings.fromJson(json.decode(settingsString));
      _currentView = _normalizeView(_settings.defaultView);
    }
  }

  String _normalizeView(String view) {
    switch (view) {
      case 'week':
      case 'year':
      case 'month':
        return view;
      default:
        return 'month';
    }
  }

  Future<void> _saveGuestUiLogoutState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestUiLoggedOutKey, _guestUiLoggedOut);
  }

  Future<void> _saveSelectedCalendarId({
    required String uid,
    required String calendarId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_selectedCalendarKeyPrefix$uid', calendarId);
  }

  Future<List<Event>> _loadLocalEventsForUid(String uid) {
    return _localEventStore.loadEvents(uid: uid);
  }

  Future<void> _saveLocalEventsForCurrentScope(List<Event> events) async {
    final uid = _currentUser?.uid;
    if (uid == null) {
      return;
    }
    await _localEventStore.saveEvents(events, uid: uid);
  }

  Future<void> _loadGuestUiLogoutState() async {
    final prefs = await SharedPreferences.getInstance();
    _guestUiLoggedOut = prefs.getBool(_guestUiLoggedOutKey) ?? false;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _cloudEventsSubscription?.cancel();
    super.dispose();
  }
}
