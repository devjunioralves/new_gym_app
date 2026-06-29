import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/workout_model.dart';
import '../../../../core/services/firebase_workout_service.dart';

final workoutServiceProvider = Provider((ref) => FirebaseWorkoutService());

final studentWorkoutsProvider =
    FutureProvider.family<List<WorkoutModel>, String>((ref, studentId) async {
      final service = ref.watch(workoutServiceProvider);
      return await service.getStudentWorkouts(studentId);
    });

final studentWorkoutsStreamProvider =
    StreamProvider.family<List<WorkoutModel>, String>((ref, studentId) {
      final service = ref.watch(workoutServiceProvider);
      return service.studentWorkoutsStream(studentId);
    });

final personalStudentWorkoutsStreamProvider =
    StreamProvider.family<List<WorkoutModel>, (String, String)>((
      ref,
      params,
    ) {
      final (studentId, personalId) = params;
      final service = ref.watch(workoutServiceProvider);
      return service.personalStudentWorkoutsStream(studentId, personalId);
    });

final workoutDetailProvider = FutureProvider.family<WorkoutModel?, String>((
  ref,
  workoutId,
) async {
  final service = ref.watch(workoutServiceProvider);
  return await service.getWorkout(workoutId);
});
