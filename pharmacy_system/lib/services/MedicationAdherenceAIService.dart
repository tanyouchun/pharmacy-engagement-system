import 'dart:convert';
import 'dart:developer';

import 'package:pharmacy_system/models/MedicationAIResult .dart';
import 'package:pharmacy_system/services/openai_service.dart';

class MedicationAdherenceAIService {
  final OpenAIService _openAI = OpenAIService();

  Future<MedicationAIResult> analyze({
    required int consecutiveMissed,
    required int totalTaken,
    required int totalMissed,
    required int totalSnoozed,
    required double remainingDays,
    required String medicationName,
    required String frequency,
  }) async {
    final userPrompt = """
Medication:
$medicationName

Frequency:
$frequency

Consecutive missed doses:
$consecutiveMissed

Taken:
$totalTaken

Missed:
$totalMissed

Snoozed:
$totalSnoozed

""";

    return _openAI
        .sendMessage(
          promptKey: "medication_adherence_analysis",
          messages: [
            {"role": "user", "content": userPrompt},
          ],
        )
        .then(_parseResult);
  }

  MedicationAIResult _parseResult(String response) {
    final trimmed = response.trim();
    final jsonText =
        trimmed.startsWith('```')
            ? trimmed
                .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
                .replaceFirst(RegExp(r'\s*```$'), '')
            : trimmed;

    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is Map<String, dynamic>) {
        return MedicationAIResult.fromJson(decoded);
      }

      return MedicationAIResult.fromJson(
        Map<String, dynamic>.from(decoded as Map),
      );
    } catch (e) {
      log('Failed to parse medication adherence AI response: $e');
      return MedicationAIResult(
        adherenceScore: 0,
        adherenceStatus: 'Unknown',
        summary: response,
        recommendation: response,
        recommendPharmacist: false,
        followUpRequired: false,
      );
    }
  }
}
