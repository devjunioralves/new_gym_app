/// Insights gerados pela IA após análise da anamnese
class AnamnesisInsights {
  final String id;
  final String anamnesisId;
  final String summary; // Resumo geral do perfil do aluno
  final List<HealthCondition> conditions; // Condições de saúde identificadas
  final List<String> goals; // Objetivos do aluno
  final List<String> limitations; // Limitações físicas
  final FitnessLevel fitnessLevel; // Nível de condicionamento
  final double injuryRisk; // Risco de lesão (0-1)
  final Map<String, dynamic> recommendations; // Recomendações gerais
  final DateTime analyzedAt;

  const AnamnesisInsights({
    required this.id,
    required this.anamnesisId,
    required this.summary,
    required this.conditions,
    required this.goals,
    required this.limitations,
    required this.fitnessLevel,
    required this.injuryRisk,
    required this.recommendations,
    required this.analyzedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'anamnesisId': anamnesisId,
      'summary': summary,
      'conditions': conditions.map((c) => c.toMap()).toList(),
      'goals': goals,
      'limitations': limitations,
      'fitnessLevel': fitnessLevel.toFirestore(),
      'injuryRisk': injuryRisk,
      'recommendations': recommendations,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  factory AnamnesisInsights.fromMap(Map<String, dynamic> map) {
    return AnamnesisInsights(
      id: map['id'] ?? '',
      anamnesisId: map['anamnesisId'] ?? '',
      summary: map['summary'] ?? '',
      conditions: (map['conditions'] as List<dynamic>?)
              ?.map((c) => HealthCondition.fromMap(c as Map<String, dynamic>))
              .toList() ??
          [],
      goals: (map['goals'] as List<dynamic>?)?.cast<String>() ?? [],
      limitations: (map['limitations'] as List<dynamic>?)?.cast<String>() ?? [],
      fitnessLevel:
          FitnessLevelExtension.fromFirestore(map['fitnessLevel'] ?? 'beginner'),
      injuryRisk: (map['injuryRisk'] ?? 0.0).toDouble(),
      recommendations:
          map['recommendations'] as Map<String, dynamic>? ?? {},
      analyzedAt: DateTime.parse(map['analyzedAt']),
    );
  }

  factory AnamnesisInsights.fromJson(Map<String, dynamic> json) {
    return AnamnesisInsights(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      anamnesisId: json['anamnesisId'] ?? '',
      summary: json['summary'] ?? '',
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((c) => HealthCondition.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      goals: (json['goals'] as List<dynamic>?)?.cast<String>() ?? [],
      limitations: (json['limitations'] as List<dynamic>?)?.cast<String>() ?? [],
      fitnessLevel: FitnessLevelExtension.fromFirestore(
          json['fitnessLevel'] ?? 'beginner'),
      injuryRisk: (json['injuryRisk'] ?? 0.0).toDouble(),
      recommendations: json['recommendations'] as Map<String, dynamic>? ?? {},
      analyzedAt: DateTime.now(),
    );
  }
}

/// Nível de condicionamento físico
enum FitnessLevel {
  sedentary, // Sedentário
  beginner, // Iniciante
  intermediate, // Intermediário
  advanced, // Avançado
}

extension FitnessLevelExtension on FitnessLevel {
  String toFirestore() {
    return toString().split('.').last;
  }

  static FitnessLevel fromFirestore(String value) {
    return FitnessLevel.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => FitnessLevel.beginner,
    );
  }

  String get displayName {
    switch (this) {
      case FitnessLevel.sedentary:
        return 'Sedentário';
      case FitnessLevel.beginner:
        return 'Iniciante';
      case FitnessLevel.intermediate:
        return 'Intermediário';
      case FitnessLevel.advanced:
        return 'Avançado';
    }
  }
}

/// Severidade da condição de saúde
enum ConditionSeverity {
  mild, // Leve
  moderate, // Moderada
  severe, // Severa
}

extension ConditionSeverityExtension on ConditionSeverity {
  String toFirestore() {
    return toString().split('.').last;
  }

  static ConditionSeverity fromFirestore(String value) {
    return ConditionSeverity.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => ConditionSeverity.mild,
    );
  }

  String get displayName {
    switch (this) {
      case ConditionSeverity.mild:
        return 'Leve';
      case ConditionSeverity.moderate:
        return 'Moderada';
      case ConditionSeverity.severe:
        return 'Severa';
    }
  }
}

/// Condição de saúde identificada
class HealthCondition {
  final String name; // Nome da condição (ex: "Hipertensão", "Dor lombar")
  final ConditionSeverity severity; // Severidade
  final List<String> restrictions; // Exercícios/movimentos a evitar
  final String? notes; // Observações adicionais

  const HealthCondition({
    required this.name,
    required this.severity,
    required this.restrictions,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'severity': severity.toFirestore(),
      'restrictions': restrictions,
      'notes': notes,
    };
  }

  factory HealthCondition.fromMap(Map<String, dynamic> map) {
    return HealthCondition(
      name: map['name'] ?? '',
      severity: ConditionSeverityExtension.fromFirestore(
          map['severity'] ?? 'mild'),
      restrictions: (map['restrictions'] as List<dynamic>?)?.cast<String>() ?? [],
      notes: map['notes'],
    );
  }

  factory HealthCondition.fromJson(Map<String, dynamic> json) {
    return HealthCondition(
      name: json['name'] ?? '',
      severity: ConditionSeverityExtension.fromFirestore(
          json['severity'] ?? 'mild'),
      restrictions: (json['restrictions'] as List<dynamic>?)?.cast<String>() ?? [],
      notes: json['notes'],
    );
  }
}
