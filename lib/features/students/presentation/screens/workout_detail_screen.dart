import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/exercise_model.dart';
import '../../../../core/services/firebase_exercise_service.dart';
import '../providers/workout_provider.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsync = ref.watch(workoutDetailProvider(workoutId));
    final exerciseService = FirebaseExerciseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Treino')),
      body: workoutAsync.when(
        data: (workout) {
          if (workout == null) {
            return const Center(child: Text('Treino não encontrado'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${workout.exercises.length} exercício(s)',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: workout.exercises.isEmpty
                    ? const Center(child: Text('Nenhum exercício neste treino'))
                    : FutureBuilder<List<Exercise>>(
                        future: Future.wait(
                          workout.exercises
                              .where((we) => we.exerciseId.isNotEmpty)
                              .map((we) => exerciseService.getExerciseById(we.exerciseId)),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Erro: ${snapshot.error}'),
                            );
                          }

                          final exercises = snapshot.data ?? [];

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: workout.exercises.length,
                            itemBuilder: (context, index) {
                              final workoutExercise = workout.exercises[index];
                              final exercise = exercises.firstWhere(
                                (e) => e.id == workoutExercise.exerciseId,
                                orElse: () => Exercise(
                                  id: '',
                                  name: 'Exercício não encontrado',
                                  workoutType: '',
                                  series: 0,
                                  reps: 0,
                                  imageUrl: '',
                                  instructions: '',
                                ),
                              );

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ExpansionTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    exercise.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${workoutExercise.series}x${workoutExercise.reps}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.fitness_center,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(exercise.workoutType),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          if (workoutExercise.notes != null &&
                                              workoutExercise.notes!.isNotEmpty)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Row(
                                                  children: [
                                                    Icon(Icons.note, size: 20),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Observações:',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(workoutExercise.notes!),
                                                const SizedBox(height: 8),
                                              ],
                                            ),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              context.push(
                                                '/exercise-detail/${exercise.id}',
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.info_outline,
                                            ),
                                            label: const Text('Ver Detalhes'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
              Text('Erro: $error'),
            ],
          ),
        ),
      ),
    );
  }
}
