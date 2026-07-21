import 'package:cloud_firestore/cloud_firestore.dart';

/// Stores the result after recording a medication intake action.
class DoseStatusResult {
  final int consecutiveMissedDoses;
  final int totalTaken;
  final int totalMissed;
  final int totalSnoozed;
  final bool shouldShowAdherenceWarning;
  final bool shouldShowLowMedicationWarning;
  final bool shouldRunAIAnalysis;
  final double remainingDays;

  const DoseStatusResult({
    required this.consecutiveMissedDoses,
    required this.totalTaken,
    required this.totalMissed,
    required this.totalSnoozed,
    required this.shouldShowAdherenceWarning,
    required this.shouldShowLowMedicationWarning,
    required this.shouldRunAIAnalysis,
    required this.remainingDays,
  });
}

/// Service responsible for recording and analysing medication adherence.
///
/// This service manages:
/// - Medication intake history
/// - Taken/missed dose records
/// - Medication adherence calculation
/// - Remaining medication estimation
/// - AI analysis trigger conditions
/// - Low medication detection
class MedicationLogService {
  final _db = FirebaseFirestore.instance;

  static const int adherenceAiMissedThreshold = 3;
  static const double lowMedicationAiThresholdDays = 1;

  Future<DoseStatusResult> recordDoseStatus({
    required String reminderId,
    required String prescriptionId,
    required String userId,
    required String reminderTime,
    required String medicationName,
    required String status,
  }) async {
    final now = DateTime.now();
    final today = "${now.year}-${now.month}-${now.day}";

    final docId = "${reminderId}_${reminderTime}_$today";

    await _db.collection('medication_logs').doc(docId).set({
      'reminderId': reminderId,
      'prescriptionId': prescriptionId,
      'userId': userId,
      'reminderTime': reminderTime,
      'medicationName': medicationName,
      'status': status,
      'taken': status == 'taken',
      'missed': status == 'missed',
      'recordedAt': Timestamp.now(),
      if (status == 'taken') 'takenAt': Timestamp.now(),
      if (status == 'missed') 'missedAt': Timestamp.now(),
    });

    final reminderRef = _db.collection('reminders').doc(reminderId);
    final reminderSnap = await reminderRef.get();
    final reminderData = reminderSnap.data() ?? <String, dynamic>{};
    final currentMissed = reminderData['consecutiveMissedDoses'] ?? 0;
    final alertAlreadySent = reminderData['adherenceAlertSent'] ?? false;

    final newMissed = status == 'missed' ? currentMissed + 1 : 0;
    final shouldShowAdherenceWarning =
        status == 'missed' && newMissed >= 1 && !alertAlreadySent;

    await reminderRef.update({
      'consecutiveMissedDoses': newMissed,
      'adherenceAlertSent': status == 'taken' ? false : alertAlreadySent,
      'lastDoseStatus': status,
      'lastDoseRecordedAt': Timestamp.now(),
    });

    final remainingDays = await _estimateRemainingDays(
      userId: userId,
      prescriptionId: prescriptionId,
      reminderId: reminderId,
    );

    final totalTaken = await _countLogs(
      userId: userId,
      prescriptionId: prescriptionId,
      status: 'taken',
    );
    final totalMissed = await _countLogs(
      userId: userId,
      prescriptionId: prescriptionId,
      status: 'missed',
    );
    final totalSnoozed = await _countLogs(
      userId: userId,
      prescriptionId: prescriptionId,
      status: 'snoozed',
    );

    final lowMedicationWarning = await _flagLowMedicationIfNeeded(
      userId: userId,
      prescriptionId: prescriptionId,
      remainingDays: remainingDays,
    );

    final shouldRunAIAnalysis = shouldShowAdherenceWarning;

    return DoseStatusResult(
      consecutiveMissedDoses: newMissed,
      totalTaken: totalTaken,
      totalMissed: totalMissed,
      totalSnoozed: totalSnoozed,
      shouldShowAdherenceWarning: shouldShowAdherenceWarning,
      shouldShowLowMedicationWarning: lowMedicationWarning,
      shouldRunAIAnalysis: shouldRunAIAnalysis,
      remainingDays: remainingDays,
    );
  }

  /// Records medication as successfully taken.
  Future<void> createAndMarkTaken({
    required String reminderId,
    required String prescriptionId,
    required String userId,
    required String reminderTime,
    required String medicationName,
  }) async {
    await recordDoseStatus(
      reminderId: reminderId,
      prescriptionId: prescriptionId,
      userId: userId,
      reminderTime: reminderTime,
      medicationName: medicationName,
      status: 'taken',
    );
  }

  /// Records medication as missed by the patient.
  Future<void> createAndMarkMissed({
    required String reminderId,
    required String prescriptionId,
    required String userId,
    required String reminderTime,
    required String medicationName,
  }) async {
    await recordDoseStatus(
      reminderId: reminderId,
      prescriptionId: prescriptionId,
      userId: userId,
      reminderTime: reminderTime,
      medicationName: medicationName,
      status: 'missed',
    );
  }

  /// Checks whether medication has already been taken
  Future<bool> alreadyTaken({
    required String reminderId,
    required String reminderTime,
  }) async {
    final now = DateTime.now();

    final today = "${now.year}-${now.month}-${now.day}";

    final docId = "${reminderId}_${reminderTime}_$today";

    final doc = await _db.collection('medication_logs').doc(docId).get();

    final data = doc.data();
    return doc.exists && (data?['status'] == 'taken' || data?['taken'] == true);
  }

  /// Retrieves current medication intake status.
  Future<String?> getDoseStatus({
    required String reminderId,
    required String reminderTime,
  }) async {
    final now = DateTime.now();

    final today = "${now.year}-${now.month}-${now.day}";

    final docId = "${reminderId}_${reminderTime}_$today";

    final doc = await _db.collection('medication_logs').doc(docId).get();
    if (!doc.exists) {
      return null;
    }

    final data = doc.data();
    return data?['status'] as String? ??
        (data?['taken'] == true ? 'taken' : null);
  }

  /// Extracts medication quantity from dose information.
  int _doseUnitsFromDose(String dose) {
    final match = RegExp(r'\d+').firstMatch(dose);
    if (match == null) {
      return 1;
    }

    return int.tryParse(match.group(0) ?? '') ?? 1;
  }

  /// Converts medication frequency into doses per day.
  int _dosesPerDayFromFrequency(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'twice daily':
        return 2;
      case 'three times daily':
        return 3;
      case 'four times daily':
        return 4;
      default:
        return 1;
    }
  }

  /// Estimates remaining medication duration.
  Future<double> _estimateRemainingDays({
    required String userId,
    required String prescriptionId,
    required String reminderId,
  }) async {
    final prescriptionRef = _db
        .collection('user_profiles')
        .doc(userId)
        .collection('prescriptions')
        .doc(prescriptionId);

    final prescriptionSnap = await prescriptionRef.get();
    if (!prescriptionSnap.exists) {
      return 999;
    }

    final prescriptionData = prescriptionSnap.data() ?? <String, dynamic>{};
    final quantity =
        (prescriptionData['quantity'] as num?)?.toInt() ??
        (prescriptionData['duration'] as num?)?.toInt() ??
        0;
    final doseUnits = _doseUnitsFromDose(
      prescriptionData['dose'] as String? ?? '1',
    );
    final dosesPerDay = _dosesPerDayFromFrequency(
      prescriptionData['frequency'] as String? ?? '',
    );

    if (quantity <= 0 || dosesPerDay <= 0 || doseUnits <= 0) {
      return 999;
    }

    final takenCount =
        (await _db
                .collection('medication_logs')
                .where('userId', isEqualTo: userId)
                .where('prescriptionId', isEqualTo: prescriptionId)
                .where('status', isEqualTo: 'taken')
                .get())
            .docs
            .length;

    final remainingUnits = (quantity - (takenCount * doseUnits)).clamp(
      0,
      quantity,
    );
    return remainingUnits / (doseUnits * dosesPerDay);
  }

  /// Counts medication logs based on status.
  Future<int> _countLogs({
    required String userId,
    required String prescriptionId,
    required String status,
  }) async {
    final snapshot =
        await _db
            .collection('medication_logs')
            .where('userId', isEqualTo: userId)
            .where('prescriptionId', isEqualTo: prescriptionId)
            .where('status', isEqualTo: status)
            .get();

    return snapshot.docs.length;
  }

  /// Checks whether medication supply is almost finished.
  ///
  /// If remaining medication is less than or equal to one day,
  /// the system generates a pharmacist consultation recommendation.
  Future<bool> _flagLowMedicationIfNeeded({
    required String userId,
    required String prescriptionId,
    required double remainingDays,
  }) async {
    if (remainingDays > 1) {
      return false;
    }

    final prescriptionRef = _db
        .collection('user_profiles')
        .doc(userId)
        .collection('prescriptions')
        .doc(prescriptionId);

    final prescriptionSnap = await prescriptionRef.get();
    if (!prescriptionSnap.exists) {
      return false;
    }

    final data = prescriptionSnap.data() ?? <String, dynamic>{};
    final alreadyAlerted = data['lowMedicationAlertSent'] ?? false;

    if (alreadyAlerted) {
      return false;
    }

    await prescriptionRef.update({'lowMedicationAlertSent': true});
    return true;
  }
}
