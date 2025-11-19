// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/core/models/exercise_model.dart';
import 'package:new_gym_app/core/models/user_model.dart';
import 'package:new_gym_app/core/shared_widgets/app_footer.dart';
import 'package:new_gym_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:new_gym_app/features/exercise_detail/presentation/providers/exercise_provider.dart';
import 'package:new_gym_app/features/home/presentation/widgets/exercise_card.dart';

// --- Providers para a Lógica da HomeScreen ---

// MUDANÇA 1: Criamos um Notifier para o estado da categoria selecionada.
class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() {
    // O estado inicial é `null`, representando "Todos"
    return null;
  }

  // Método público para alterar a categoria
  void selectCategory(String? category) {
    state = category;
  }
}

// MUDANÇA 2: O antigo StateProvider agora é um NotifierProvider.
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
      SelectedCategoryNotifier.new,
    );

// Este provider "computado" não muda, pois ele apenas lê o estado dos outros.
final filteredExerciseListProvider = Provider<List<Exercise>>((ref) {
  final exerciseListAsync = ref.watch(exerciseListProvider);
  // Ele assiste ao novo provider, mas o resultado (o estado) é o mesmo.
  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (exerciseListAsync.isLoading || exerciseListAsync.hasError) {
    return [];
  }
  final exercises = exerciseListAsync.value!;
  if (selectedCategory == null) {
    return exercises;
  } else {
    return exercises.where((ex) => ex.workoutType == selectedCategory).toList();
  }
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usa o currentUserProvider para obter o usuário
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authProvider);

    // Escuta mudanças no estado de autenticação
    ref.listen(authProvider, (_, next) {
      next.whenData((user) {
        if (user == null) context.go('/login');
      });
    });

    // Mostra loading enquanto verifica autenticação
    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, user, ref),
          Expanded(child: _buildBody(context, ref)),
        ],
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }

  Widget _buildHeader(BuildContext context, User user, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(user.photoUrl),
              ),
              const SizedBox(width: 16),
              Text(
                'Olá, ${user.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final exerciseListAsync = ref.watch(exerciseListProvider);

    return exerciseListAsync.when(
      data: (exercises) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkoutCategories(context, ref, exercises),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Exercícios',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: _buildExerciseList(context, ref)),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) =>
          Center(child: Text('Erro ao carregar exercícios: $err')),
    );
  }

  Widget _buildWorkoutCategories(
    BuildContext context,
    WidgetRef ref,
    List<Exercise> allExercises,
  ) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categories = {
      null,
      ...allExercises.map((e) => e.workoutType),
    }.toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      height: 70,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          return ChoiceChip(
            label: Text(category ?? 'Todos'),
            selected: isSelected,
            onSelected: (selected) {
              // MUDANÇA 3: Em vez de modificar o `.state` diretamente,
              // chamamos o método que criamos no nosso Notifier.
              ref
                  .read(selectedCategoryProvider.notifier)
                  .selectCategory(category);
            },
            selectedColor: Colors.blue,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
      ),
    );
  }

  Widget _buildExerciseList(BuildContext context, WidgetRef ref) {
    final filteredList = ref.watch(filteredExerciseListProvider);

    if (filteredList.isEmpty) {
      return const Center(child: Text('Nenhum exercício encontrado.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final exercise = filteredList[index];
        return ExerciseCard(
          exerciseName: exercise.name,
          seriesReps: '${exercise.series} séries x ${exercise.reps} repetições',
          imageUrl: exercise.imageUrl,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }
}
