import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/workout_model.dart';

class FirebaseWorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar novo treino
  Future<String> createWorkout({
    required String name,
    required String studentId,
    required String createdBy,
  }) async {
    try {
      final docRef = await _firestore.collection('workouts').add({
        'name': name,
        'studentId': studentId,
        'createdBy': createdBy,
        'exercises': [],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': null,
      });

      // Atualizar com o ID gerado
      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar treino: $e');
    }
  }

  // Adicionar exercício ao treino
  Future<void> addExerciseToWorkout({
    required String workoutId,
    required String exerciseId,
    required int series,
    required int reps,
    String? notes,
  }) async {
    try {
      final workoutExercise = WorkoutExercise(
        exerciseId: exerciseId,
        series: series,
        reps: reps,
        notes: notes,
      );

      await _firestore.collection('workouts').doc(workoutId).update({
        'exercises': FieldValue.arrayUnion([workoutExercise.toMap()]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar exercício: $e');
    }
  }

  // Remover exercício do treino
  Future<void> removeExerciseFromWorkout({
    required String workoutId,
    required String exerciseId,
  }) async {
    try {
      final doc = await _firestore.collection('workouts').doc(workoutId).get();
      final workout = WorkoutModel.fromMap(doc.data()!);

      final updatedExercises = workout.exercises
          .where((e) => e.exerciseId != exerciseId)
          .map((e) => e.toMap())
          .toList();

      await _firestore.collection('workouts').doc(workoutId).update({
        'exercises': updatedExercises,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao remover exercício: $e');
    }
  }

  // Atualizar treino completo
  Future<void> updateWorkout({
    required String workoutId,
    String? name,
    List<WorkoutExercise>? exercises,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (exercises != null) {
        updates['exercises'] = exercises.map((e) => e.toMap()).toList();
      }

      await _firestore.collection('workouts').doc(workoutId).update(updates);
    } catch (e) {
      throw Exception('Erro ao atualizar treino: $e');
    }
  }

  // Deletar treino
  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _firestore.collection('workouts').doc(workoutId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar treino: $e');
    }
  }

  // Buscar treinos de um aluno
  Future<List<WorkoutModel>> getStudentWorkouts(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('workouts')
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WorkoutModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar treinos: $e');
    }
  }

  // Stream de treinos do aluno (tempo real)
  Stream<List<WorkoutModel>> studentWorkoutsStream(String studentId) {
    return _firestore
        .collection('workouts')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WorkoutModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Buscar treinos criados por um personal
  Future<List<WorkoutModel>> getWorkoutsByPersonal(String personalId) async {
    try {
      final snapshot = await _firestore
          .collection('workouts')
          .where('createdBy', isEqualTo: personalId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WorkoutModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar treinos: $e');
    }
  }

  // Buscar um treino específico
  Future<WorkoutModel?> getWorkout(String workoutId) async {
    try {
      final doc = await _firestore.collection('workouts').doc(workoutId).get();
      if (!doc.exists) return null;
      return WorkoutModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Erro ao buscar treino: $e');
    }
  }
}
