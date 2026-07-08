class MedicationAIResult {
  final int adherenceScore;
  final String adherenceStatus;
  final String summary;
  final String recommendation;
  final bool recommendPharmacist;
  final bool followUpRequired;

  MedicationAIResult({
    required this.adherenceScore,
    required this.adherenceStatus,
    required this.summary,
    required this.recommendation,
    required this.recommendPharmacist,
    required this.followUpRequired,
  });

  factory MedicationAIResult.fromJson(Map<String, dynamic> json) {
    return MedicationAIResult(
      adherenceScore: (json['adherenceScore'] as num?)?.toInt() ?? 0,
      adherenceStatus: json['adherenceStatus'] as String? ?? 'Unknown',
      summary: json['summary'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      recommendPharmacist: json['recommendPharmacist'] as bool? ?? false,
      followUpRequired: json['followUpRequired'] as bool? ?? false,
    );
  }
}