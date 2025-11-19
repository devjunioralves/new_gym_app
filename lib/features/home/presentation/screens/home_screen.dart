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

import '../../../students/presentation/providers/workout_provider.dart';

// --- Providers para a Lógica da HomeScreen ---

// 1. Criamos um Notifier para o estado da categoria selecionada.
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

// 2. O antigo StateProvider agora é um NotifierProvider.
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
      SelectedCategoryNotifier.new,
    );

// Este provider "computado" não muda, pois ele apenas lê o estado dos outros.
final filteredExerciseListProvider = Provider<List<Exercise>>((ref) {
  final exerciseListAsync = ref.watch(exerciseListProvider);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(user.photoUrl),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${user.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user.role.displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
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
          // Botão de gerenciar para Personal Trainers
          if (user.isPersonalTrainer) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.people),
              label: const Text('Gerenciar Alunos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
              ),
              onPressed: () {
                context.push('/students');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    // Se for aluno, mostrar treinos ao invés de lista de exercícios
    if (user?.isStudent == true) {
      return _buildStudentWorkouts(context, ref, user!);
    }

    // Personal Trainer vê todos os exercícios
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

  Widget _buildStudentWorkouts(BuildContext context, WidgetRef ref, User user) {
    final workoutsAsync = ref.watch(studentWorkoutsStreamProvider(user.uid));

    return workoutsAsync.when(
      data: (workouts) {
        if (workouts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Nenhum treino disponível',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Aguarde seu personal trainer criar um treino para você',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Meus Treinos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final workout = workouts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          '${workout.exercises.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        workout.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${workout.exercises.length} exercício(s)',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/workout-detail/${workout.id}');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erro ao carregar treinos: $error'),
          ],
        ),
      ),
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
              // AJUSTADO: Chama o método do notifier para mudar o estado
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
