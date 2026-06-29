import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/core/models/anamnesis_model.dart';
import 'package:new_gym_app/core/models/exercise_model.dart';
import 'package:new_gym_app/core/models/user_model.dart';
import 'package:new_gym_app/core/shared_widgets/app_footer.dart';
import 'package:new_gym_app/features/anamnesis/presentation/providers/anamnesis_providers.dart';
import 'package:new_gym_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:new_gym_app/features/exercise_detail/presentation/providers/exercise_provider.dart';
import 'package:new_gym_app/features/home/presentation/widgets/exercise_card.dart';

import '../../../students/presentation/providers/workout_provider.dart';

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void selectCategory(String? category) {
    state = category;
  }
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
      SelectedCategoryNotifier.new,
    );

final filteredExerciseListProvider = Provider<AsyncValue<List<Exercise>>>((
  ref,
) {
  final exerciseListAsync = ref.watch(exerciseListProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return exerciseListAsync.when(
    data: (exercises) {
      if (selectedCategory == null) {
        return AsyncValue.data(exercises);
      } else {
        return AsyncValue.data(
          exercises.where((ex) => ex.workoutType == selectedCategory).toList(),
        );
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      next.whenData((user) {
        if (user == null) context.go('/login');
      });
    });

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
                    backgroundImage: user.photoUrl.startsWith('http')
                        ? NetworkImage(user.photoUrl)
                        : AssetImage(user.photoUrl) as ImageProvider,
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
          if (user.isPersonalTrainer) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.fitness_center),
                    label: const Text('Exercícios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      context.push('/exercises-library');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.people),
                    label: const Text('Alunos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      context.push('/students');
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user?.isStudent == true) {
      return _buildStudentWorkouts(context, ref, user!);
    }

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
    final anamnesesAsync = ref.watch(studentAnamnesesProvider(user.uid));

    final pendingAnamneses = anamnesesAsync.when(
      data: (list) =>
          list.where((a) => a.status == AnamnesisStatus.inProgress).toList(),
      loading: () => <Anamnesis>[],
      error: (_, __) => <Anamnesis>[],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pendingAnamneses.isNotEmpty)
          _buildPendingAnamnesisSection(context, pendingAnamneses),

        workoutsAsync.when(
          data: (workouts) {
            if (workouts.isEmpty && pendingAnamneses.isEmpty) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
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
                ),
              );
            }

            if (workouts.isEmpty) return const SizedBox.shrink();

            return Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Meus Treinos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
              ),
            );
          },
          loading: () => const Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar treinos: $error'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingAnamnesisSection(
    BuildContext context,
    List<Anamnesis> pending,
  ) {
    return Container(
      color: Colors.orange.shade50,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.assignment_late, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Anamnese Pendente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Responda a anamnese para que seu personal possa criar um treino personalizado para você.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ...pending.map((a) => _buildPendingAnamnesisCard(context, a)),
        ],
      ),
    );
  }

  Widget _buildPendingAnamnesisCard(
    BuildContext context,
    Anamnesis anamnesis,
  ) {
    final answered = anamnesis.answers.length;
    final total = anamnesis.questions.length;
    final progress = total > 0 ? answered / total : 0.0;
    final isStarted = answered > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.orange, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isStarted ? 'Continuar Anamnese' : 'Nova Anamnese',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$answered/$total perguntas',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: Colors.orange,
              minHeight: 6,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.push('/answer-anamnesis/${anamnesis.id}'),
                icon: Icon(isStarted ? Icons.play_arrow : Icons.edit_note),
                label: Text(isStarted ? 'Continuar' : 'Responder Agora'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
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
    final filteredListAsync = ref.watch(filteredExerciseListProvider);

    return filteredListAsync.when(
      data: (filteredList) {
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
              seriesReps:
                  '${exercise.series} séries x ${exercise.reps} repetições',
              imageUrl: exercise.imageUrl,
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Erro: $error')),
    );
  }
}
