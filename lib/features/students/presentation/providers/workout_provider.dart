import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/workout_model.dart';
import '../../../../core/services/firebase_workout_service.dart';

final workoutServiceProvider = Provider((ref) => FirebaseWorkoutService());

// Provider para listar treinos de um aluno
final studentWorkoutsProvider =
    FutureProvider.family<List<WorkoutModel>, String>((ref, studentId) async {
      final service = ref.watch(workoutServiceProvider);
      return await service.getStudentWorkouts(studentId);
    });

// Stream provider para treinos em tempo real
final studentWorkoutsStreamProvider =
    StreamProvider.family<List<WorkoutModel>, String>((ref, studentId) {
      final service = ref.watch(workoutServiceProvider);
      return service.studentWorkoutsStream(studentId);
    });

// Provider para um treino específico
final workoutDetailProvider = FutureProvider.family<WorkoutModel?, String>((
  ref,
  workoutId,
) async {
  final service = ref.watch(workoutServiceProvider);
  return await service.getWorkout(workoutId);
});
