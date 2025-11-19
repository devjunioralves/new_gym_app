import 'package:cloud_firestore/cloud_firestore.dart';

/// Relaciona exercícios com usuários (alunos)
/// Personal Trainers atribuem exercícios aos seus alunos
class UserExercise {
  final String id; // ID do documento no Firestore
  final String userId; // ID do aluno
  final String exerciseId; // ID do exercício
  final String assignedBy; // ID do personal trainer que atribuiu
  final DateTime assignedAt; // Data de atribuição
  final int? customSeries; // Séries customizadas (opcional)
  final int? customReps; // Repetições customizadas (opcional)
  final String? notes; // Observações do personal

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

  // Converter para Map (para salvar no Firestore)
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

  // Criar a partir de Map (para ler do Firestore)
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

  // Copiar com modificações
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
