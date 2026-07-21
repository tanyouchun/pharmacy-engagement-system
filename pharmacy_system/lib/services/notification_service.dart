import 'dart:developer';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../views/home_page.dart';
import 'MedicationAdherenceAIService.dart';
import '../models/MedicationAIResult.dart';
import 'medication_log_service.dart';
import 'app_navigation_service.dart';

/// Background callback function triggered when a notification action
/// is selected while the application is running in the background.
///
/// This allows notification actions such as marking medication as taken
/// or missed to continue working even when the app is not active.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  NotificationService.instance.handleNotificationResponse(response);
}

/// Service class responsible for managing all application notifications.
///
/// This class handles:
/// - Initializing local notifications
/// - Scheduling medication reminders
/// - Cancelling reminder notifications
/// - Processing user notification actions
/// - Tracking medication intake status
/// - Triggering AI-based medication adherence recommendations
/// - Redirecting users to pharmacist communication page
///
/// NotificationService follows the Singleton pattern to ensure only one
/// notification manager instance exists throughout the application.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _doseTakenActionId = 'dose_taken';
  static const String _doseMissedActionId = 'dose_missed';
  static const String _chatPharmacistActionId = 'chat_pharmacist';
  static const String _doseReminderType = 'dose_reminder';
  static const String _aiRecommendationType = 'ai_recommendation';
  static const String _lowMedicationType = 'low_medication';

  /// Initializes the local notification service.
  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kuala_Lumpur'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {}

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

  /// Schedules a daily medication reminder notification.
  Future<void> scheduleDailyReminder({
    required int notificationId,
    required String medicationName,
    required String time,
    required String reminderId,
    required String prescriptionId,
    required String userId,
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
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Medication Reminders',
          channelDescription: 'Medication reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          actions: const [
            AndroidNotificationAction(_doseTakenActionId, 'Taken'),
            AndroidNotificationAction(_doseMissedActionId, 'Missed'),
          ],
        ),
      ),
      payload: jsonEncode({
        'type': _doseReminderType,
        'reminderId': reminderId,
        'prescriptionId': prescriptionId,
        'userId': userId,
        'medicationName': medicationName,
        'reminderTime': time,
      }),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Creates notification schedules for all medication times.
  Future<void> scheduleReminderTimes({
    required String reminderId,
    required String prescriptionId,
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
          reminderId: reminderId,
          prescriptionId: prescriptionId,
          userId: userId,
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

  /// Cancels all notifications related to a reminder.
  Future<void> cancelReminder(String reminderId, int totalTimes) async {
    for (int i = 0; i < totalTimes; i++) {
      await _plugin.cancel(_notificationId(reminderId, i));
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Displays AI-generated medication adherence recommendations.
  ///
  /// This notification is triggered when AI detects potential medication
  /// adherence issues and recommends patient follow-up with pharmacist.
  Future<void> showAIRecommendation({
    required MedicationAIResult aiResult,
    required String reminderId,
    required String prescriptionId,
    required String userId,
    required String medicationName,
  }) async {
    await _plugin.show(
      _notificationId('ai_$reminderId', 0),
      'Medication Recommendation',
      aiResult.recommendation.isNotEmpty
          ? aiResult.recommendation
          : aiResult.summary,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'ai_recommendation_channel',
          'Medication AI Recommendations',
          channelDescription: 'AI-powered medication recommendation alerts',
          importance: Importance.max,
          priority: Priority.high,
          actions: const [
            AndroidNotificationAction(
              _chatPharmacistActionId,
              'Chat with Pharmacist',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
      payload: jsonEncode({
        'type': _aiRecommendationType,
        'reminderId': reminderId,
        'prescriptionId': prescriptionId,
        'userId': userId,
        'medicationName': medicationName,
        'adherenceScore': aiResult.adherenceScore,
        'adherenceStatus': aiResult.adherenceStatus,
        'summary': aiResult.summary,
        'recommendation': aiResult.recommendation,
        'recommendPharmacist': aiResult.recommendPharmacist,
        'followUpRequired': aiResult.followUpRequired,
      }),
    );
  }

  /// Displays warning notification when medication supply is almost finished.
  ///
  /// This feature improves pharmacist-patient engagement by encouraging
  /// users to contact pharmacists for refill or consultation.
  Future<void> showLowMedicationWarning({
    required String reminderId,
    required String prescriptionId,
    required String userId,
    required String medicationName,
  }) async {
    await _plugin.show(
      _notificationId('low_$prescriptionId', 0),
      'Medication Almost Finished',
      'Your medication is almost finished. Would you like to consult your pharmacist regarding a refill or treatment progress?',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'low_medication_channel',
          'Medication Refill Alerts',
          channelDescription: 'Medication refill reminders',
          importance: Importance.max,
          priority: Priority.high,
          actions: const [
            AndroidNotificationAction(
              _chatPharmacistActionId,
              'Chat with Pharmacist',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
      payload: jsonEncode({
        'type': _lowMedicationType,
        'reminderId': reminderId,
        'prescriptionId': prescriptionId,
        'userId': userId,
        'medicationName': medicationName,
      }),
    );
  }

  /// Performs AI medication adherence analysis.
  ///
  /// The AI service evaluates:
  /// - Consecutive missed doses
  /// - Total medication intake history
  /// - Remaining medication duration
  ///
  /// If risk is detected, an AI recommendation notification is displayed.
  Future<void> analyzeAndShowRecommendation({
    required DoseStatusResult doseResult,
    required String reminderId,
    required String prescriptionId,
    required String userId,
    required String medicationName,
    required String frequency,
  }) async {
    if (!doseResult.shouldRunAIAnalysis) {
      return;
    }

    final aiResult = await MedicationAdherenceAIService().analyze(
      consecutiveMissed: doseResult.consecutiveMissedDoses,
      totalTaken: doseResult.totalTaken,
      totalMissed: doseResult.totalMissed,
      totalSnoozed: doseResult.totalSnoozed,
      remainingDays: doseResult.remainingDays,
      medicationName: medicationName,
      frequency: frequency,
    );

    if (aiResult.recommendPharmacist || aiResult.followUpRequired) {
      await showAIRecommendation(
        aiResult: aiResult,
        reminderId: reminderId,
        prescriptionId: prescriptionId,
        userId: userId,
        medicationName: medicationName,
      );
    }
  }

  /// Handles user interaction with notification buttons.
  Future<void> _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    log("=== Notification Response ===");
    log("actionId: ${response.actionId}");
    log("payload: ${response.payload}");

    final payload = _decodePayload(response.payload);
    final type = payload['type'] as String?;
    log("type: $type");

    if (type == _doseReminderType &&
        (response.actionId == _doseTakenActionId ||
            response.actionId == _doseMissedActionId)) {
      final result = await MedicationLogService().recordDoseStatus(
        reminderId: payload['reminderId'] as String? ?? '',
        prescriptionId: payload['prescriptionId'] as String? ?? '',
        userId: payload['userId'] as String? ?? '',
        reminderTime: payload['reminderTime'] as String? ?? '',
        medicationName: payload['medicationName'] as String? ?? '',
        status: response.actionId == _doseTakenActionId ? 'taken' : 'missed',
      );

      // Trigger AI analysis when adherence risk is detected.
      if (result.shouldRunAIAnalysis) {
        await analyzeAndShowRecommendation(
          doseResult: result,
          reminderId: payload['reminderId'] as String? ?? '',
          prescriptionId: payload['prescriptionId'] as String? ?? '',
          userId: payload['userId'] as String? ?? '',
          medicationName: payload['medicationName'] as String? ?? '',
          frequency: await _getReminderFrequency(
            payload['reminderId'] as String? ?? '',
          ),
        );
      }

      if (result.shouldShowLowMedicationWarning) {
        await showLowMedicationWarning(
          reminderId: payload['reminderId'] as String? ?? '',
          prescriptionId: payload['prescriptionId'] as String? ?? '',
          userId: payload['userId'] as String? ?? '',
          medicationName: payload['medicationName'] as String? ?? '',
        );
      }
      return;
    }

    if ((type == _aiRecommendationType || type == _lowMedicationType) &&
        response.actionId == _chatPharmacistActionId) {
      _openChatPage();
    }
  }

  Future<void> handleNotificationResponse(NotificationResponse response) {
    return _handleNotificationResponse(response);
  }

  Map<String, dynamic> _decodePayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return {};
    }

    try {
      return Map<String, dynamic>.from(jsonDecode(payload) as Map);
    } catch (e) {
      log('Failed to decode notification payload: $e');
      return {};
    }
  }

  /// Retrieves medication frequency from Firestore.
  Future<String> _getReminderFrequency(String reminderId) async {
    if (reminderId.isEmpty) {
      return '';
    }

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('reminders')
              .doc(reminderId)
              .get();
      return doc.data()?['frequency'] as String? ?? '';
    } catch (e) {
      log('Failed to load reminder frequency for AI analysis: $e');
      return '';
    }
  }

  /// Opens pharmacist chat page.
  ///
  /// Allows users to communicate with pharmacists after:
  /// - AI recommendation
  /// - Medication refill warning
  void _openChatPage() {
    log("Opening chat page");
    final navigator = appNavigatorKey.currentState;
    log("Navigator: $navigator");
    if (navigator == null) return;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 1)),
      (route) => false,
    );
  }
}
