import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/event.dart';

/// Local notification scheduling for event reminders.
///
/// Fully functional on Android/iOS. On web (and any platform without the
/// plugin) every method is a safe no-op so the rest of the app keeps working.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'event_reminders',
    'یادآور رویدادها',
    channelDescription: 'اعلان یادآوری برای رویدادها و مناسبت‌ها',
    importance: Importance.max,
    priority: Priority.high,
  );

  static const NotificationDetails _details = NotificationDetails(
    android: _androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> initialize() async {
    if (kIsWeb || _ready) return;
    try {
      tzdata.initializeTimeZones();
      final localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName));

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings);
      _ready = true;
    } catch (e) {
      debugPrint('NotificationService init failed: $e');
    }
  }

  /// Requests notification permission (Android 13+ / iOS). Returns granted.
  static Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    await initialize();
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      }
    } catch (e) {
      debugPrint('NotificationService permission failed: $e');
    }
    return false;
  }

  static int _idFor(String eventId) => eventId.hashCode & 0x7fffffff;

  static Future<void> scheduleEventReminder(Event event) async {
    if (kIsWeb) return;
    if (!event.hasReminder || event.reminderTime == null) return;
    await initialize();
    if (!_ready) return;

    final when = tz.TZDateTime.from(event.reminderTime!, tz.local);
    if (when.isBefore(tz.TZDateTime.now(tz.local))) return; // don't schedule past

    try {
      await _plugin.zonedSchedule(
        _idFor(event.id),
        event.title,
        event.description.isNotEmpty ? event.description : 'یادآوری رویداد',
        when,
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('scheduleEventReminder failed: $e');
    }
  }

  static Future<void> cancelEventReminder(String eventId) async {
    if (kIsWeb) return;
    try {
      await _plugin.cancel(_idFor(eventId));
    } catch (e) {
      debugPrint('cancelEventReminder failed: $e');
    }
  }
}
