import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/exercise_model.dart';
import '../../../../core/models/workout_model.dart';
import '../../../../core/services/firebase_exercise_service.dart';
import '../../../../core/services/firebase_workout_service.dart';

class EditWorkoutScreen extends ConsumerStatefulWidget {
  final String workoutId;

  const EditWorkoutScreen({super.key, required this.workoutId});

  @override
  ConsumerState<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends ConsumerState<EditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _workoutService = FirebaseWorkoutService();
  final _exerciseService = FirebaseExerciseService();

  List<Exercise> _allExercises = [];
  final Map<String, WorkoutExercise> _selectedExercises = {};
  bool _isLoading = false;
  bool _isLoadingData = true;
  WorkoutModel? _workout;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);

    try {
      final workout = await _workoutService.getWorkout(widget.workoutId);

      if (workout == null) {
        throw Exception('Treino não encontrado');
      }

      final exercises = await _exerciseService.getAllExercises();

      setState(() {
        _workout = workout;
        _nameController.text = workout.name;
        _allExercises = exercises;

        for (final workoutExercise in workout.exercises) {
          _selectedExercises[workoutExercise.exerciseId] = workoutExercise;
        }

        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _updateWorkout() async {
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
      await _workoutService.updateWorkoutName(
        widget.workoutId,
        _nameController.text.trim(),
      );

      for (final exercise in _workout!.exercises) {
        await _workoutService.removeExerciseFromWorkout(
          workoutId: widget.workoutId,
          exerciseId: exercise.exerciseId,
        );
      }

      for (final workoutExercise in _selectedExercises.values) {
        await _workoutService.addExerciseToWorkout(
          workoutId: widget.workoutId,
          exerciseId: workoutExercise.exerciseId,
          series: workoutExercise.series,
          reps: workoutExercise.reps,
          notes: workoutExercise.notes,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treino atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar treino: $e'),
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
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Treino')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Treino')),
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
                      orElse: () => Exercise(
                        id: exerciseId,
                        name: 'Exercício não encontrado',
                        workoutType: '',
                        imageUrl: '',
                        series: 0,
                        reps: 0,
                        instructions: '',
                      ),
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
            onPressed: _isLoading ? null : _updateWorkout,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Salvar Alterações',
                    style: TextStyle(fontSize: 16),
                  ),
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
