import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/event.dart';

class LocalEventStore {
  static const String _eventsKeyPrefix = 'events_';

  String _eventsKeyForUid(String uid) => '$_eventsKeyPrefix$uid';

  Future<List<Event>> loadEvents({required String uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString(_eventsKeyForUid(uid));
    if (eventsString == null || eventsString.isEmpty) {
      return <Event>[];
    }

    final eventsJson = json.decode(eventsString) as List<dynamic>;
    return eventsJson
        .map((e) => Event.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveEvents(List<Event> events, {required String uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = events.map((e) => e.toJson()).toList();
    await prefs.setString(_eventsKeyForUid(uid), json.encode(eventsJson));
  }

  Future<void> clearEvents({required String uid}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eventsKeyForUid(uid));
  }

  Future<int> countEvents({required String uid}) async {
    final events = await loadEvents(uid: uid);
    return events.length;
  }
}
