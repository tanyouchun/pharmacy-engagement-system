import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'medication_log_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kuala_Lumpur'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    final permissionGranted =
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();

    log('Notification permission granted: $permissionGranted');
    final androidPlugin =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    final canSchedule = await androidPlugin?.canScheduleExactNotifications();

    log("canScheduleExactNotifications = $canSchedule");

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  int _notificationId(String reminderId, int index) {
    final key = '${reminderId}_$index';
    return key.codeUnits.fold(0, (int value, int unit) {
      return (value * 31 + unit) & 0x7fffffff;
    });
  }

  Future<void> scheduleDailyReminder({
    required int notificationId,
    required String medicationName,
    required String time,
  }) async {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    log("Now = ${tz.TZDateTime.now(tz.local)}");
    log("Scheduled = $scheduledDate");
    log("tz.local = ${tz.local.name}");
    // log('Now (tz.local) = $now');
    log('Now local DateTime = ${now.toLocal()}');
    // log('Selected notification time = $scheduledDate');
    log('Selected notification local = ${scheduledDate.toLocal()}');

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      log(
        'Scheduled time already passed today; scheduling for tomorrow: $scheduledDate',
      );
    }

    await _plugin.zonedSchedule(
      notificationId,
      'Medication Reminder',
      'Time to take $medicationName',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Medication Reminders',
          channelDescription: 'Medication reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleReminderTimes({
    required String reminderId,
    required String userId,
    required String medicationName,
    required List<String> reminderTimes,
  }) async {
    log(
      'Scheduling $reminderTimes for medication: $medicationName (reminderId: $reminderId)',
    );
    for (int i = 0; i < reminderTimes.length; i++) {
      try {
        await scheduleDailyReminder(
          notificationId: _notificationId(reminderId, i),
          medicationName: medicationName,
          time: reminderTimes[i],
        );
        log(
          'Successfully scheduled notification $i for reminderId: $reminderId',
        );

        final pending = await _plugin.pendingNotificationRequests();

        log("Pending count: ${pending.length}");

        for (final p in pending) {
          log("Pending: ${p.id} ${p.title}");
        }
      } catch (e) {
        log('ERROR scheduling notification $i: $e');
      }
    }
  }

  Future<void> cancelReminder(String reminderId, int totalTimes) async {
    for (int i = 0; i < totalTimes; i++) {
      await _plugin.cancel(_notificationId(reminderId, i));
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}