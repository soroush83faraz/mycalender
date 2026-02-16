import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../models/app_calendar.dart';
import '../models/calendar_invite.dart';
import '../models/jalali_date.dart';
import '../models/event.dart';
import '../models/holiday.dart';
import '../models/settings.dart';
import '../repositories/firestore_event_store.dart';
import '../repositories/local_event_store.dart';
import '../services/auth_service.dart';

class CalendarProvider extends ChangeNotifier {
  static const String _guestUiLoggedOutKey = 'guest_ui_logged_out';

  CalendarProvider({
    LocalEventStore? localEventStore,
    FirestoreEventStore? firestoreEventStore,
  })  : _localEventStore = localEventStore ?? LocalEventStore(),
        _firestoreEventStore = firestoreEventStore ?? FirestoreEventStore();

  final LocalEventStore _localEventStore;
  final FirestoreEventStore _firestoreEventStore;

  JalaliDate _currentDate = JalaliDate.fromGregorian(DateTime.now());
  JalaliDate? _selectedDate;
  List<Event> _events = [];
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
  String? _bootstrappedUid;
  bool _guestUiLoggedOut = false;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<Event>>? _cloudEventsSubscription;
  StreamSubscription<List<AppCalendar>>? _calendarWatchSubscription;

  JalaliDate get currentDate => _currentDate;
  JalaliDate? get selectedDate => _selectedDate;
  List<Event> get events => _events;
  List<AppCalendar> get calendars => _calendars;
  AppSettings get settings => _settings;
  String get currentView => _currentView;
  User? get currentUser => _currentUser;
  String? get activeCalendarId => _activeCalendarId;
  String? get activeCalendarTitle {
    final id = _activeCalendarId;
    if (id == null) return null;
    for (final calendar in _calendars) {
      if (calendar.id == id) {
        return calendar.title;
      }
    }
    return null;
  }

  String? get lastFirestoreError => _lastFirestoreError;
  bool get isUsingFirestore => _isUsingFirestore;
  bool get isInitialized => _isInitialized;
  bool get isUsingLocalFallback => _currentUser != null && !_isUsingFirestore;
  bool get isSignedIn => _currentUser != null;
  bool get isGuestUser => _currentUser?.isAnonymous ?? false;
  bool get isGuestUiLoggedOut => _guestUiLoggedOut;
  String get accountStatusLabel {
    if (_currentUser == null) return 'Not signed in';
    if (_currentUser!.isAnonymous) return 'Guest';
    return _currentUser!.email ?? _currentUser!.uid;
  }

  int get localEventCount => _localEventCount;
  int get cloudEventCount => _cloudEventCount;
  int get cloudCalendarsCount => _calendars.length;
  bool get selectedCalendarExists => _selectedCalendarExists;
  bool get selectedCalendarMembershipExists =>
      _selectedCalendarMembershipExists;
  String? get activeMembershipRole => _activeMembershipRole;
  bool get canEditActiveCalendarEvents =>
      _activeMembershipRole == 'owner' || _activeMembershipRole == 'editor';
  bool get isActiveCalendarOwner => _activeMembershipRole == 'owner';
  bool get hasSelectedCalendar => _selectedCalendarExists;
  String get dataModeStatus =>
      isSignedIn && isUsingFirestore ? 'Cloud (Firestore)' : 'Local fallback';

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
          year: _currentDate.year, month: _currentDate.month + 1, day: 1);
    }
    notifyListeners();
  }

  void previousMonth() {
    if (_currentDate.month == 1) {
      _currentDate = JalaliDate(year: _currentDate.year - 1, month: 12, day: 1);
    } else {
      _currentDate = JalaliDate(
          year: _currentDate.year, month: _currentDate.month - 1, day: 1);
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
    if (_currentUser != null && _activeMembershipRole == 'viewer') {
      throw StateError('You have read-only access to this calendar.');
    }
    _events.add(event);
    await _localEventStore.saveEvents(_events);
    _localEventCount = _events.length;
    await _upsertCloudEvent(event);
    notifyListeners();
  }

  Future<void> updateEvent(Event event) async {
    if (_currentUser != null && _activeMembershipRole == 'viewer') {
      throw StateError('You have read-only access to this calendar.');
    }
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      await _localEventStore.saveEvents(_events);
      _localEventCount = _events.length;
      await _upsertCloudEvent(event);
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    if (_currentUser != null && _activeMembershipRole == 'viewer') {
      throw StateError('You have read-only access to this calendar.');
    }
    final target = _events.cast<Event?>().firstWhere(
          (e) => e?.id == eventId,
          orElse: () => null,
        );
    _events.removeWhere((e) => e.id == eventId);
    await _localEventStore.saveEvents(_events);
    _localEventCount = _events.length;
    await _softDeleteCloudEvent(target, eventId);
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> loadData() async {
    if (_isInitialized) return;
    _events = await _localEventStore.loadEvents();
    _localEventCount = _events.length;
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
    if (_activeCalendarId == calendarId) return;
    _activeCalendarId = calendarId;
    if (_currentUser != null) {
      try {
        await _refreshSelectedCalendarStatus();
        await _refreshCloudCountForActiveCalendar();
      } catch (error) {
        _lastFirestoreError = error.toString();
      }
      _subscribeToCloudEvents(calendarId);
    } else {
      _selectedCalendarExists = false;
      _selectedCalendarMembershipExists = false;
      _activeMembershipRole = null;
    }
    notifyListeners();
  }

  Future<String> createInvite({
    required String email,
    required String role,
  }) async {
    if (_currentUser == null) {
      throw StateError('Please sign in to create invites.');
    }
    if (_activeCalendarId == null) {
      throw StateError('No active calendar selected.');
    }
    if (!isActiveCalendarOwner) {
      throw StateError('Only calendar owners can create invites.');
    }
    return _firestoreEventStore.createInvite(_activeCalendarId!, email, role);
  }

  Future<void> revokeInvite(String inviteId) async {
    if (_currentUser == null) {
      throw StateError('Please sign in to revoke invites.');
    }
    if (_activeCalendarId == null) {
      throw StateError('No active calendar selected.');
    }
    if (!isActiveCalendarOwner) {
      throw StateError('Only calendar owners can revoke invites.');
    }
    await _firestoreEventStore.revokeInvite(_activeCalendarId!, inviteId);
  }

  Stream<List<CalendarInvite>> watchPendingInvitesForActiveCalendar() {
    final calendarId = _activeCalendarId;
    if (calendarId == null || !isActiveCalendarOwner) {
      return Stream<List<CalendarInvite>>.value(const <CalendarInvite>[]);
    }
    return _firestoreEventStore.watchPendingInvites(calendarId);
  }

  Future<void> acceptInvite(String inviteCode) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Please sign in to join shared calendars.');
    }
    if (user.isAnonymous) {
      throw StateError('Please upgrade to Google to join shared calendars.');
    }

    final beforeCalendarIds = _calendars.map((calendar) => calendar.id).toSet();
    await _firestoreEventStore.acceptInvite(inviteCode.trim());

    final refreshedCalendars =
        await _firestoreEventStore.fetchCalendarsForUser(user.uid);
    _calendars = refreshedCalendars;

    String? joinedCalendarId;
    for (final calendar in refreshedCalendars) {
      if (!beforeCalendarIds.contains(calendar.id)) {
        joinedCalendarId = calendar.id;
        break;
      }
    }

    if (joinedCalendarId != null) {
      await setActiveCalendar(joinedCalendarId);
      return;
    }

    await _refreshSelectedCalendarStatus();
    await _refreshCloudCountForActiveCalendar();
    notifyListeners();
  }

  Future<void> forceSyncLocalToCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to sync local events to cloud.');
    }
    _currentUser = user;

    final calendarId = _activeCalendarId ?? await _ensureUserCalendar(user);
    _subscribeToCloudEvents(calendarId);

    final localEvents = await _localEventStore.loadEvents();
    final syncedEvents = <Event>[];

    for (final event in localEvents) {
      final synced = await _firestoreEventStore.upsertEvent(
        calendarId: calendarId,
        event: event,
      );
      syncedEvents.add(synced);
    }

    await _localEventStore.saveEvents(syncedEvents);
    _events = syncedEvents;
    _localEventCount = syncedEvents.length;
    await _refreshCloudCountForActiveCalendar();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cloud_migrated_${user.uid}', true);

    _isUsingFirestore = true;
    _lastFirestoreError = null;
    notifyListeners();
  }

  Future<void> clearLocalCache() async {
    await _localEventStore.clearEvents();
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
      _events = await _localEventStore.loadEvents();
      _localEventCount = _events.length;
      _selectedCalendarExists = false;
      _selectedCalendarMembershipExists = false;
      _activeMembershipRole = null;
      notifyListeners();
      return;
    }
    _currentUser = user;

    try {
      final refreshedCalendarId = await _ensureUserCalendar(user);
      await _refreshCloudCountForActiveCalendar();
      _lastFirestoreError = null;
      _subscribeToCloudEvents(refreshedCalendarId);
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
    await _calendarWatchSubscription?.cancel();
    _calendarWatchSubscription = null;

    if (kDebugMode) {
      debugPrint(
        '[Auth] state changed uid=${user?.uid ?? '(null)'} '
        'isAnonymous=${user?.isAnonymous ?? false} '
        'guestUiLoggedOut=$_guestUiLoggedOut',
      );
    }

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
    if (!user.isAnonymous && _guestUiLoggedOut) {
      _guestUiLoggedOut = false;
      await _saveGuestUiLogoutState();
    }

    try {
      String selectedCalendarId;
      if (_bootstrappedUid != user.uid || _activeCalendarId == null) {
        selectedCalendarId = await _ensureUserCalendar(user);
        _bootstrappedUid = user.uid;
      } else {
        selectedCalendarId = _activeCalendarId!;
        await _refreshSelectedCalendarStatus();
      }

      await _startCalendarWatch(user);
      await _refreshCloudCountForActiveCalendar();
      _subscribeToCloudEvents(selectedCalendarId);
      _isUsingFirestore = true;
    } catch (error) {
      await _fallbackToLocal(error);
    }

    notifyListeners();
  }

  Future<String> _ensureUserCalendar(User user) async {
    final selectedCalendarId =
        await _firestoreEventStore.ensureDefaultCalendarForUser(user);
    _activeCalendarId = selectedCalendarId;

    try {
      _calendars = await _firestoreEventStore.fetchCalendarsForUser(user.uid);
    } catch (_) {
      _calendars = <AppCalendar>[
        AppCalendar(
          id: selectedCalendarId,
          ownerId: user.uid,
          title: 'My Calendar',
          color: 'blue',
        ),
      ];
    }

    await _refreshSelectedCalendarStatus();
    return selectedCalendarId;
  }

  Future<void> _startCalendarWatch(User user) async {
    await _calendarWatchSubscription?.cancel();
    _calendarWatchSubscription =
        _firestoreEventStore.watchMyCalendars(user).listen(
      (calendars) async {
        _lastFirestoreError = null;
        _calendars = calendars;
        if (_calendars.isEmpty) {
          _selectedCalendarExists = false;
          _selectedCalendarMembershipExists = false;
          _activeMembershipRole = null;
          return;
        }

        final previousCalendarId = _activeCalendarId;
        if (_activeCalendarId == null ||
            !_calendars.any((calendar) => calendar.id == _activeCalendarId)) {
          _activeCalendarId = _calendars.first.id;
        }

        await _refreshSelectedCalendarStatus();
        await _refreshCloudCountForActiveCalendar();
        if (_activeCalendarId != null &&
            previousCalendarId != _activeCalendarId) {
          _subscribeToCloudEvents(_activeCalendarId!);
        }
        notifyListeners();
      },
      onError: (Object error) {
        _lastFirestoreError = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> _refreshCloudCountForActiveCalendar() async {
    final calendarId = _activeCalendarId;
    if (calendarId == null || _currentUser == null) {
      _cloudEventCount = 0;
      return;
    }

    _cloudEventCount = await _firestoreEventStore.fetchCloudEventCount(
      calendarId,
      DateTime(1900),
      DateTime(2100, 12, 31),
    );
  }

  Future<void> _refreshSelectedCalendarStatus() async {
    final user = _currentUser;
    final calendarId = _activeCalendarId;
    if (user == null || calendarId == null) {
      _selectedCalendarExists = false;
      _selectedCalendarMembershipExists = false;
      _activeMembershipRole = null;
      return;
    }

    _selectedCalendarExists =
        await _firestoreEventStore.calendarExists(calendarId);
    _selectedCalendarMembershipExists =
        await _firestoreEventStore.hasCalendarMembership(
      calendarId: calendarId,
      uid: user.uid,
    );
    _activeMembershipRole = await _firestoreEventStore.fetchMembershipRole(
      calendarId: calendarId,
      uid: user.uid,
    );
  }

  void _subscribeToCloudEvents(String calendarId) {
    _cloudEventsSubscription?.cancel();

    _cloudEventsSubscription = _firestoreEventStore
        .watchEvents(calendarId, DateTime(1900), DateTime(2100, 12, 31))
        .listen(
      (cloudEvents) async {
        _isUsingFirestore = true;
        _lastFirestoreError = null;
        _cloudEventCount = cloudEvents.length;
        _events = cloudEvents;
        await _localEventStore.saveEvents(cloudEvents);
        _localEventCount = cloudEvents.length;
        notifyListeners();
      },
      onError: (Object error) async {
        await _fallbackToLocal(error);
      },
    );
  }

  Future<void> _upsertCloudEvent(Event event) async {
    final user = _currentUser;
    final calendarId = _activeCalendarId;
    if (user == null || calendarId == null) {
      return;
    }

    try {
      final syncedEvent = await _firestoreEventStore.upsertEvent(
        calendarId: calendarId,
        event: event,
      );
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = syncedEvent;
        await _localEventStore.saveEvents(_events);
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
    final calendarId = _activeCalendarId;
    if (_currentUser == null || calendarId == null) {
      return;
    }

    try {
      final targetEvent = event ??
          Event(
            id: eventId,
            title: '',
            date: DateTime.fromMillisecondsSinceEpoch(0),
          );
      await _firestoreEventStore.softDeleteEvent(
        calendarId: calendarId,
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
    _events = await _localEventStore.loadEvents();
    _localEventCount = _events.length;
    notifyListeners();
  }

  Future<void> _applyUiSignedOutState() async {
    await _cloudEventsSubscription?.cancel();
    _cloudEventsSubscription = null;
    await _calendarWatchSubscription?.cancel();
    _calendarWatchSubscription = null;
    _currentUser = null;
    _isUsingFirestore = false;
    _activeCalendarId = null;
    _selectedCalendarExists = false;
    _selectedCalendarMembershipExists = false;
    _activeMembershipRole = null;
    _bootstrappedUid = null;
    _calendars = <AppCalendar>[];
    _cloudEventCount = 0;
    _events = await _localEventStore.loadEvents();
    _localEventCount = _events.length;
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
    }
  }

  Future<void> _saveGuestUiLogoutState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestUiLoggedOutKey, _guestUiLoggedOut);
  }

  Future<void> _loadGuestUiLogoutState() async {
    final prefs = await SharedPreferences.getInstance();
    _guestUiLoggedOut = prefs.getBool(_guestUiLoggedOutKey) ?? false;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _cloudEventsSubscription?.cancel();
    _calendarWatchSubscription?.cancel();
    super.dispose();
  }
}
