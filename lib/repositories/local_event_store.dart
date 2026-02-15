import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/event.dart';

class LocalEventStore {
  static const String _eventsKey = 'events';

  Future<List<Event>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString(_eventsKey);
    if (eventsString == null || eventsString.isEmpty) {
      return <Event>[];
    }

    final eventsJson = json.decode(eventsString) as List<dynamic>;
    return eventsJson
        .map((e) => Event.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = events.map((e) => e.toJson()).toList();
    await prefs.setString(_eventsKey, json.encode(eventsJson));
  }

  Future<void> clearEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eventsKey);
  }

  Future<int> countEvents() async {
    final events = await loadEvents();
    return events.length;
  }
}
