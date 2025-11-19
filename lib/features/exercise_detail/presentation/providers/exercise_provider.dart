// lib/features/exercise_detail/presentation/providers/exercise_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gym_app/core/models/exercise_model.dart';
import 'package:new_gym_app/core/models/user_model.dart';
import 'package:new_gym_app/core/services/firebase_exercise_service.dart';
import 'package:new_gym_app/features/auth/presentation/providers/auth_provider.dart';

// Provider do serviço Firebase
final firebaseExerciseServiceProvider = Provider<FirebaseExerciseService>((
  ref,
) {
  return FirebaseExerciseService();
});

// Provider que busca exercícios baseado no tipo de usuário
// Alunos: apenas exercícios atribuídos a eles
// Personal Trainers: todos os exercícios
final exerciseListProvider = FutureProvider<List<Exercise>>((ref) async {
  final service = ref.watch(firebaseExerciseServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return [];

  // Se for aluno, busca apenas os exercícios atribuídos
  if (user.isStudent) {
    return service.getStudentExercises(user.uid);
  }

  // Se for personal, busca todos os exercícios
  return service.getAllExercises();
});

// Stream de exercícios para alunos (atualização em tempo real)
final studentExercisesStreamProvider = StreamProvider<List<Exercise>>((ref) {
  final service = ref.watch(firebaseExerciseServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null || !user.isStudent) {
    return Stream.value([]);
  }

  return service.studentExercisesStream(user.uid);
});

// Provider que busca exercícios por categoria (com stream para atualizações em tempo real)
final exercisesByCategoryProvider =
    StreamProvider.family<List<Exercise>, String?>((ref, category) {
      final service = ref.watch(firebaseExerciseServiceProvider);
      return service.getExercisesByCategory(category);
    });

// Provider que busca os detalhes de um exercício específico
final exerciseDetailProvider = FutureProvider.family<Exercise, String>((
  ref,
  exerciseName,
) async {
  final service = ref.watch(firebaseExerciseServiceProvider);
  return service.getExerciseByName(exerciseName);
});

// Provider para buscar todos os alunos (para personal trainers)
final allStudentsProvider = FutureProvider<List<User>>((ref) async {
  final service = ref.watch(firebaseExerciseServiceProvider);
  return service.getAllStudents();
});
