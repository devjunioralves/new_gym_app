import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gym_app/core/models/exercise_model.dart';
import 'package:new_gym_app/core/models/user_model.dart';
import 'package:new_gym_app/core/services/firebase_exercise_service.dart';
import 'package:new_gym_app/features/auth/presentation/providers/auth_provider.dart';

final firebaseExerciseServiceProvider = Provider<FirebaseExerciseService>((
  ref,
) {
  return FirebaseExerciseService();
});

final exerciseListProvider = StreamProvider<List<Exercise>>((ref) {
  final service = ref.watch(firebaseExerciseServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return Stream.value([]);

  if (user.isStudent) {
    return service.studentExercisesStream(user.uid);
  }

  return service.getAllExercisesStream();
});

final studentExercisesStreamProvider = StreamProvider<List<Exercise>>((ref) {
  final service = ref.watch(firebaseExerciseServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null || !user.isStudent) {
    return Stream.value([]);
  }

  return service.studentExercisesStream(user.uid);
});

final exercisesByCategoryProvider =
    StreamProvider.family<List<Exercise>, String?>((ref, category) {
      final service = ref.watch(firebaseExerciseServiceProvider);
      return service.getExercisesByCategory(category);
    });

final exerciseDetailProvider = FutureProvider.family<Exercise, String>((
  ref,
  exerciseName,
) async {
  final service = ref.watch(firebaseExerciseServiceProvider);
  return service.getExerciseByName(exerciseName);
});

final allStudentsProvider = FutureProvider<List<User>>((ref) async {
  final service = ref.watch(firebaseExerciseServiceProvider);
  return service.getAllStudents();
});
