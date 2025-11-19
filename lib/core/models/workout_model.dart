class WorkoutModel {
  final String id;
  final String name;
  final String studentId;
  final String createdBy;
  final List<WorkoutExercise> exercises;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.studentId,
    required this.createdBy,
    required this.exercises,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'studentId': studentId,
      'createdBy': createdBy,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      studentId: map['studentId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      exercises:
          (map['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  WorkoutModel copyWith({
    String? id,
    String? name,
    String? studentId,
    String? createdBy,
    List<WorkoutExercise>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      createdBy: createdBy ?? this.createdBy,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WorkoutExercise {
  final String exerciseId;
  final int series;
  final int reps;
  final String? notes;

  WorkoutExercise({
    required this.exerciseId,
    required this.series,
    required this.reps,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'series': series,
      'reps': reps,
      'notes': notes,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      exerciseId: map['exerciseId'] ?? '',
      series: map['series'] ?? 0,
      reps: map['reps'] ?? 0,
      notes: map['notes'],
    );
  }

  WorkoutExercise copyWith({
    String? exerciseId,
    int? series,
    int? reps,
    String? notes,
  }) {
    return WorkoutExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      series: series ?? this.series,
      reps: reps ?? this.reps,
      notes: notes ?? this.notes,
    );
  }
}
