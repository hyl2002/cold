import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }

  static Future<void> scheduleNotification(String name, DateTime date) async {
    final tzDate = tz.TZDateTime.from(
      DateTime(date.year, date.month, date.day - 1, 11, 30),
      tz.local,
    );

    await _plugin.zonedSchedule(
      date.hashCode,
      '纪念日提醒',
      '距离 "$name" 还有 3 天',
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          '提醒频道',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
