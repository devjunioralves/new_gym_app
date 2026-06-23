/// Sugestão de treino gerada pela IA usando RAG
class WorkoutSuggestion {
  final String id;
  final String anamnesisId;
  final String name;
  final List<ExerciseSuggestion> exercises;
  final String rationale; // Justificativa científica do treino
  final List<String> precautions; // Precauções e avisos
  final List<ScientificReference> references; // Referências científicas
  final double confidence; // Confiança da IA (0-1)
  final bool approvedByPersonal; // Se foi aprovado pelo personal
  final DateTime generatedAt;
  final DateTime? approvedAt;

  const WorkoutSuggestion({
    required this.id,
    required this.anamnesisId,
    required this.name,
    required this.exercises,
    required this.rationale,
    required this.precautions,
    required this.references,
    required this.confidence,
    this.approvedByPersonal = false,
    required this.generatedAt,
    this.approvedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'anamnesisId': anamnesisId,
      'name': name,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'rationale': rationale,
      'precautions': precautions,
      'references': references.map((r) => r.toMap()).toList(),
      'confidence': confidence,
      'approvedByPersonal': approvedByPersonal,
      'generatedAt': generatedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
    };
  }

  factory WorkoutSuggestion.fromMap(Map<String, dynamic> map) {
    return WorkoutSuggestion(
      id: map['id'] ?? '',
      anamnesisId: map['anamnesisId'] ?? '',
      name: map['name'] ?? '',
      exercises:
          (map['exercises'] as List<dynamic>?)
              ?.map(
                (e) => ExerciseSuggestion.fromMap(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      rationale: map['rationale'] ?? '',
      precautions: (map['precautions'] as List<dynamic>?)?.cast<String>() ?? [],
      references:
          (map['references'] as List<dynamic>?)
              ?.map(
                (r) => ScientificReference.fromMap(r as Map<String, dynamic>),
              )
              .toList() ??
          [],
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      approvedByPersonal: map['approvedByPersonal'] ?? false,
      generatedAt: DateTime.parse(map['generatedAt']),
      approvedAt: map['approvedAt'] != null
          ? DateTime.parse(map['approvedAt'])
          : null,
    );
  }

  WorkoutSuggestion copyWith({
    String? id,
    String? anamnesisId,
    String? name,
    List<ExerciseSuggestion>? exercises,
    String? rationale,
    List<String>? precautions,
    List<ScientificReference>? references,
    double? confidence,
    bool? approvedByPersonal,
    DateTime? generatedAt,
    DateTime? approvedAt,
  }) {
    return WorkoutSuggestion(
      id: id ?? this.id,
      anamnesisId: anamnesisId ?? this.anamnesisId,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      rationale: rationale ?? this.rationale,
      precautions: precautions ?? this.precautions,
      references: references ?? this.references,
      confidence: confidence ?? this.confidence,
      approvedByPersonal: approvedByPersonal ?? this.approvedByPersonal,
      generatedAt: generatedAt ?? this.generatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}

/// Sugestão de exercício dentro do treino
class ExerciseSuggestion {
  final String exerciseId;
  final String exerciseName;
  final int series;
  final String reps; // Pode ser "10-12" ou "30 segundos"
  final String? rest; // Tempo de descanso
  final String notes; // Observações técnicas
  final String reason; // Por que esse exercício foi sugerido
  final List<String> modifications; // Modificações possíveis

  const ExerciseSuggestion({
    required this.exerciseId,
    required this.exerciseName,
    required this.series,
    required this.reps,
    this.rest,
    required this.notes,
    required this.reason,
    this.modifications = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'series': series,
      'reps': reps,
      'rest': rest,
      'notes': notes,
      'reason': reason,
      'modifications': modifications,
    };
  }

  factory ExerciseSuggestion.fromMap(Map<String, dynamic> map) {
    return ExerciseSuggestion(
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      series: map['series'] ?? 3,
      reps: map['reps'] ?? '10-12',
      rest: map['rest'],
      notes: map['notes'] ?? '',
      reason: map['reason'] ?? '',
      modifications:
          (map['modifications'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

/// Referência científica
class ScientificReference {
  final String title; // Título do estudo/guideline
  final String source; // Fonte (ACSM, NSCA, journal, etc)
  final String? url; // Link se disponível
  final String summary; // Resumo da relevância

  const ScientificReference({
    required this.title,
    required this.source,
    this.url,
    required this.summary,
  });

  Map<String, dynamic> toMap() {
    return {'title': title, 'source': source, 'url': url, 'summary': summary};
  }

  factory ScientificReference.fromMap(Map<String, dynamic> map) {
    return ScientificReference(
      title: map['title'] ?? '',
      source: map['source'] ?? '',
      url: map['url'],
      summary: map['summary'] ?? '',
    );
  }
}
