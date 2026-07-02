import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

/// Outcome of a two-way Google Calendar sync.
class GoogleSyncResult {
  final bool success;
  final int imported;
  final int exported;
  final String? error;

  const GoogleSyncResult({
    required this.success,
    this.imported = 0,
    this.exported = 0,
    this.error,
  });
}

/// A minimal event fetched from Google Calendar.
class GoogleCalendarEvent {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime start;
  final DateTime end;
  final bool allDay;

  const GoogleCalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.start,
    required this.end,
    required this.allDay,
  });

  /// Converts to the app's local [Event] model.
  Event toEvent() => Event(
        id: 'gcal_$id',
        title: title.isEmpty ? 'رویداد گوگل' : title,
        description: description,
        date: start,
        endDate: end,
        location: location,
        allDay: allDay,
      );
}

/// Two-way Google Calendar access over the REST API using an OAuth access
/// token (obtained via [AuthService.requestCalendarAccess]). Using the REST
/// endpoint directly avoids pulling in the heavy `googleapis` package.
class GoogleCalendarService {
  GoogleCalendarService(this.accessToken);

  final String accessToken;
  static const String _base =
      'https://www.googleapis.com/calendar/v3/calendars/primary/events';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

  /// Fetches events in the given time window from the user's primary calendar.
  Future<List<GoogleCalendarEvent>> listEvents({
    required DateTime timeMin,
    required DateTime timeMax,
  }) async {
    final uri = Uri.parse(_base).replace(queryParameters: {
      'timeMin': timeMin.toUtc().toIso8601String(),
      'timeMax': timeMax.toUtc().toIso8601String(),
      'singleEvents': 'true',
      'orderBy': 'startTime',
      'maxResults': '2500',
    });
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('Google Calendar list failed: ${res.statusCode} ${res.body}');
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    final items = (body['items'] as List<dynamic>? ?? const []);
    return items
        .map((e) => _parseEvent(e as Map<String, dynamic>))
        .whereType<GoogleCalendarEvent>()
        .toList();
  }

  /// Inserts a local [event] into Google Calendar; returns the new event id.
  Future<String?> insertEvent(Event event) async {
    final res = await http.post(
      Uri.parse(_base),
      headers: _headers,
      body: json.encode(_toGoogleBody(event)),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Google Calendar insert failed: ${res.statusCode} ${res.body}');
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    return body['id'] as String?;
  }

  Future<void> deleteEvent(String googleEventId) async {
    final res = await http.delete(
      Uri.parse('$_base/$googleEventId'),
      headers: _headers,
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Google Calendar delete failed: ${res.statusCode}');
    }
  }

  Map<String, dynamic> _toGoogleBody(Event event) {
    final start = event.date;
    final end = event.endDate ?? event.date.add(const Duration(hours: 1));
    if (event.allDay) {
      String d(DateTime x) =>
          '${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}';
      return {
        'summary': event.title,
        if (event.description.isNotEmpty) 'description': event.description,
        if (event.location.isNotEmpty) 'location': event.location,
        'start': {'date': d(start)},
        'end': {'date': d(end.add(const Duration(days: 1)))},
      };
    }
    return {
      'summary': event.title,
      if (event.description.isNotEmpty) 'description': event.description,
      if (event.location.isNotEmpty) 'location': event.location,
      'start': {'dateTime': start.toUtc().toIso8601String()},
      'end': {'dateTime': end.toUtc().toIso8601String()},
    };
  }

  GoogleCalendarEvent? _parseEvent(Map<String, dynamic> e) {
    final id = e['id'] as String?;
    if (id == null) return null;
    final startMap = e['start'] as Map<String, dynamic>?;
    final endMap = e['end'] as Map<String, dynamic>?;
    if (startMap == null) return null;

    final allDay = startMap.containsKey('date');
    DateTime? start;
    DateTime? end;
    if (allDay) {
      start = DateTime.tryParse(startMap['date'] as String? ?? '');
      end = DateTime.tryParse(endMap?['date'] as String? ?? '') ?? start;
    } else {
      start = DateTime.tryParse(startMap['dateTime'] as String? ?? '');
      end = DateTime.tryParse(endMap?['dateTime'] as String? ?? '') ?? start;
    }
    if (start == null) return null;

    return GoogleCalendarEvent(
      id: id,
      title: (e['summary'] as String?) ?? '',
      description: (e['description'] as String?) ?? '',
      location: (e['location'] as String?) ?? '',
      start: start,
      end: end ?? start,
      allDay: allDay,
    );
  }
}
