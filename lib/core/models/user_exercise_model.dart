import 'package:cloud_firestore/cloud_firestore.dart';

class UserExercise {
  final String id;
  final String userId;
  final String exerciseId;
  final String assignedBy;
  final DateTime assignedAt;
  final int? customSeries;
  final int? customReps;
  final String? notes;

  UserExercise({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.assignedBy,
    required this.assignedAt,
    this.customSeries,
    this.customReps,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'exerciseId': exerciseId,
      'assignedBy': assignedBy,
      'assignedAt': Timestamp.fromDate(assignedAt),
      if (customSeries != null) 'customSeries': customSeries,
      if (customReps != null) 'customReps': customReps,
      if (notes != null) 'notes': notes,
    };
  }

  factory UserExercise.fromMap(Map<String, dynamic> map, String id) {
    return UserExercise(
      id: id,
      userId: map['userId'] ?? '',
      exerciseId: map['exerciseId'] ?? '',
      assignedBy: map['assignedBy'] ?? '',
      assignedAt: (map['assignedAt'] as Timestamp).toDate(),
      customSeries: map['customSeries'],
      customReps: map['customReps'],
      notes: map['notes'],
    );
  }

  UserExercise copyWith({
    String? id,
    String? userId,
    String? exerciseId,
    String? assignedBy,
    DateTime? assignedAt,
    int? customSeries,
    int? customReps,
    String? notes,
  }) {
    return UserExercise(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exerciseId: exerciseId ?? this.exerciseId,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedAt: assignedAt ?? this.assignedAt,
      customSeries: customSeries ?? this.customSeries,
      customReps: customReps ?? this.customReps,
      notes: notes ?? this.notes,
    );
  }
}
