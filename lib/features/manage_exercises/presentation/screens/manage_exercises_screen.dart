import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/core/shared_widgets/app_footer.dart';
import 'package:new_gym_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:new_gym_app/features/exercise_detail/presentation/providers/exercise_provider.dart';

class ManageExercisesScreen extends ConsumerStatefulWidget {
  const ManageExercisesScreen({super.key});

  @override
  ConsumerState<ManageExercisesScreen> createState() =>
      _ManageExercisesScreenState();
}

class _ManageExercisesScreenState extends ConsumerState<ManageExercisesScreen> {
  String? _selectedStudentId;
  final List<String> _selectedExerciseIds = [];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final exercisesAsync = ref.watch(exerciseListProvider);
    final studentsAsync = ref.watch(allStudentsProvider);

    // Apenas personal trainers podem acessar
    if (user == null || !user.isPersonalTrainer) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acesso Negado')),
        body: const Center(
          child: Text('Apenas Personal Trainers podem acessar esta tela'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Treinos')),
      body: Column(
        children: [
          // Seleção de aluno
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: studentsAsync.when(
              data: (students) {
                if (students.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Nenhum aluno cadastrado ainda'),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  initialValue: _selectedStudentId,
                  decoration: const InputDecoration(
                    labelText: 'Selecione um Aluno',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: students.map((student) {
                    return DropdownMenuItem(
                      value: student.uid,
                      child: Text(student.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStudentId = value;
                      _selectedExerciseIds.clear();
                    });
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Erro: $error'),
            ),
          ),

          // Lista de exercícios disponíveis
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return const Center(
                    child: Text('Nenhum exercício cadastrado'),
                  );
                }

                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    final isSelected = _selectedExerciseIds.contains(
                      exercise.id,
                    );

                    return CheckboxListTile(
                      title: Text(exercise.name),
                      subtitle: Text(
                        '${exercise.workoutType} - ${exercise.series}x${exercise.reps}',
                      ),
                      value: isSelected,
                      onChanged: _selectedStudentId == null
                          ? null
                          : (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedExerciseIds.add(exercise.id);
                                } else {
                                  _selectedExerciseIds.remove(exercise.id);
                                }
                              });
                            },
                      secondary: CircleAvatar(
                        child: Text(exercise.workoutType[0]),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Erro: $error')),
            ),
          ),

          // Botão para atribuir exercícios
          if (_selectedStudentId != null && _selectedExerciseIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_task),
                label: Text(
                  'Atribuir ${_selectedExerciseIds.length} exercício(s)',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => _assignExercises(user.uid),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-exercise'),
        icon: const Icon(Icons.add),
        label: const Text('Novo Exercício'),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }

  Future<void> _assignExercises(String personalTrainerId) async {
    if (_selectedStudentId == null || _selectedExerciseIds.isEmpty) return;

    try {
      final service = ref.read(firebaseExerciseServiceProvider);

      // Atribui cada exercício selecionado
      for (final exerciseId in _selectedExerciseIds) {
        await service.assignExerciseToStudent(
          studentId: _selectedStudentId!,
          exerciseId: exerciseId,
          personalTrainerId: personalTrainerId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedExerciseIds.length} exercício(s) atribuído(s) com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _selectedExerciseIds.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atribuir exercícios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
