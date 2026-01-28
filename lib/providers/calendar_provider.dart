import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/jalali_date.dart';
import '../models/event.dart';
import '../models/holiday.dart';
import '../models/settings.dart';

class CalendarProvider extends ChangeNotifier {
  JalaliDate _currentDate = JalaliDate.fromGregorian(DateTime.now());
  JalaliDate? _selectedDate;
  List<Event> _events = [];
  AppSettings _settings = AppSettings();
  String _currentView = 'month';

  JalaliDate get currentDate => _currentDate;
  JalaliDate? get selectedDate => _selectedDate;
  List<Event> get events => _events;
  AppSettings get settings => _settings;
  String get currentView => _currentView;

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
      _currentDate = JalaliDate(year: _currentDate.year, month: _currentDate.month + 1, day: 1);
    }
    notifyListeners();
  }

  void previousMonth() {
    if (_currentDate.month == 1) {
      _currentDate = JalaliDate(year: _currentDate.year - 1, month: 12, day: 1);
    } else {
      _currentDate = JalaliDate(year: _currentDate.year, month: _currentDate.month - 1, day: 1);
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
    await _saveEvents();
    notifyListeners();
  }

  Future<void> updateEvent(Event event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      await _saveEvents();
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
    await _saveEvents();
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> loadData() async {
    await _loadEvents();
    await _loadSettings();
    notifyListeners();
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = _events.map((e) => e.toJson()).toList();
    await prefs.setString('events', json.encode(eventsJson));
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString('events');
    if (eventsString != null) {
      final eventsJson = json.decode(eventsString) as List;
      _events = eventsJson.map((e) => Event.fromJson(e)).toList();
    }
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
}