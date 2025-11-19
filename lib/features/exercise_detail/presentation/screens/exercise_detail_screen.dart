// lib/features/exercise_detail/presentation/screens/exercise_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gym_app/core/models/exercise_model.dart';
import 'package:new_gym_app/core/services/firebase_exercise_service.dart';
import 'package:new_gym_app/core/shared_widgets/app_footer.dart';
import 'package:new_gym_app/features/exercise_detail/presentation/providers/exercise_provider.dart';

// Provider para buscar exercício por ID
final exerciseByIdProvider = FutureProvider.family<Exercise?, String>((
  ref,
  exerciseId,
) async {
  final service = FirebaseExerciseService();
  return await service.getExerciseById(exerciseId);
});

class ExerciseDetailScreen extends ConsumerWidget {
  final String? exerciseId;
  final String? exerciseName;
  final String? workoutName;

  const ExerciseDetailScreen({
    super.key,
    this.exerciseId,
    this.exerciseName,
    this.workoutName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Se tiver exerciseId, busca por ID, senão busca por nome
    final exerciseAsyncValue = exerciseId != null
        ? ref.watch(exerciseByIdProvider(exerciseId!))
        : ref.watch(exerciseDetailProvider(exerciseName!));

    return Scaffold(
      body: exerciseAsyncValue.when(
        data: (exercise) {
          if (exercise == null) {
            return const Center(child: Text('Exercício não encontrado'));
          }
          return _buildExerciseDetails(context, exercise);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: ${err.toString()}')),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }

  // Widget separado para construir a UI quando os dados estiverem disponíveis
  Widget _buildExerciseDetails(BuildContext context, Exercise exercise) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              exercise.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              exercise.workoutType,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Exibir imagem/GIF/vídeo do exercício
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[200],
                child: exercise.imageUrl.isNotEmpty
                    ? (exercise.imageUrl.startsWith('http')
                          ? Image.network(
                              exercise.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text('Erro ao carregar mídia'),
                                    ],
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                            )
                          : Image.asset(
                              exercise.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.fitness_center,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ))
                    : const Center(
                        child: Icon(
                          Icons.fitness_center,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          '${exercise.series} séries x ${exercise.reps} repetições',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (exercise.instructions.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Instruções:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise.instructions,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Adicionar lógica para marcar como concluído
                          },
                          child: const Text('Marcar como concluído'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
