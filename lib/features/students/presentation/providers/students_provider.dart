import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/services/firebase_exercise_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final exerciseServiceProvider = Provider((ref) => FirebaseExerciseService());

// Provider para listar alunos do personal logado
final studentsListProvider = FutureProvider<List<User>>((ref) async {
  final service = ref.watch(exerciseServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) return [];

  // Busca apenas alunos vinculados ao personal logado
  return await service.getStudentsByPersonal(currentUser.uid);
});

// Notifier para o estado da busca
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
}

// Provider para buscar alunos (com filtro)
final searchStudentsProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final filteredStudentsProvider = Provider<AsyncValue<List<User>>>((ref) {
  final studentsAsync = ref.watch(studentsListProvider);
  final searchQuery = ref.watch(searchStudentsProvider).toLowerCase();

  return studentsAsync.when(
    data: (students) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(students);
      }
      final filtered = students
          .where(
            (student) =>
                student.name.toLowerCase().contains(searchQuery) ||
                student.email.toLowerCase().contains(searchQuery),
          )
          .toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
