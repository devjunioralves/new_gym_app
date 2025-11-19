import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/exercise_model.dart';
import '../../../../core/models/workout_model.dart';
import '../../../../core/services/firebase_exercise_service.dart';
import '../../../../core/services/firebase_workout_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CreateWorkoutScreen extends ConsumerStatefulWidget {
  final String studentId;

  const CreateWorkoutScreen({super.key, required this.studentId});

  @override
  ConsumerState<CreateWorkoutScreen> createState() =>
      _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends ConsumerState<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _workoutService = FirebaseWorkoutService();
  final _exerciseService = FirebaseExerciseService();

  List<Exercise> _allExercises = [];
  final Map<String, WorkoutExercise> _selectedExercises = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await _exerciseService.getAllExercises();
      setState(() {
        _allExercises = exercises;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar exercícios: $e')),
        );
      }
    }
  }

  Future<void> _createWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um exercício'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authProvider).value;
      if (user == null) throw Exception('Usuário não autenticado');

      // Criar treino
      final workoutId = await _workoutService.createWorkout(
        name: _nameController.text.trim(),
        studentId: widget.studentId,
        createdBy: user.uid,
      );

      // Adicionar exercícios
      for (final workoutExercise in _selectedExercises.values) {
        await _workoutService.addExerciseToWorkout(
          workoutId: workoutId,
          exerciseId: workoutExercise.exerciseId,
          series: workoutExercise.series,
          reps: workoutExercise.reps,
          notes: workoutExercise.notes,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treino criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar treino: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showExerciseDialog(Exercise exercise) {
    final seriesController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '12');
    final notesController = TextEditingController();

    // Se já está selecionado, preencher com valores existentes
    if (_selectedExercises.containsKey(exercise.id)) {
      final existing = _selectedExercises[exercise.id]!;
      seriesController.text = existing.series.toString();
      repsController.text = existing.reps.toString();
      notesController.text = existing.notes ?? '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: seriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Séries',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Repetições',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final workoutExercise = WorkoutExercise(
                exerciseId: exercise.id,
                series: int.tryParse(seriesController.text) ?? 3,
                reps: int.tryParse(repsController.text) ?? 12,
                notes: notesController.text.isEmpty
                    ? null
                    : notesController.text,
              );

              setState(() {
                _selectedExercises[exercise.id] = workoutExercise;
              });

              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Treino')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Treino',
                  hintText: 'Ex: Treino A - Peito e Tríceps',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Digite um nome para o treino';
                  }
                  return null;
                },
              ),
            ),
            if (_selectedExercises.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedExercises.length,
                  itemBuilder: (context, index) {
                    final exerciseId = _selectedExercises.keys.elementAt(index);
                    final exercise = _allExercises.firstWhere(
                      (e) => e.id == exerciseId,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(exercise.name),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _selectedExercises.remove(exerciseId);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Selecione os exercícios:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _allExercises.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _allExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _allExercises[index];
                        final isSelected = _selectedExercises.containsKey(
                          exercise.id,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                              child: Icon(
                                isSelected ? Icons.check : Icons.fitness_center,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(exercise.name),
                            subtitle: Text(exercise.workoutType),
                            trailing: isSelected
                                ? Text(
                                    '${_selectedExercises[exercise.id]!.series}x${_selectedExercises[exercise.id]!.reps}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                            onTap: () => _showExerciseDialog(exercise),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createWorkout,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Criar Treino', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
