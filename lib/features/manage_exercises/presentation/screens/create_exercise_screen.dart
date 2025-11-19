import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/core/services/firebase_exercise_service.dart';

class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() =>
      _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _workoutTypeController = TextEditingController();
  final _seriesController = TextEditingController();
  final _repsController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _instructionsController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _workoutTypeController.dispose();
    _seriesController.dispose();
    _repsController.dispose();
    _imageUrlController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _createExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = FirebaseExerciseService();

      await service.createExercise(
        name: _nameController.text.trim(),
        workoutType: _workoutTypeController.text.trim(),
        series: int.parse(_seriesController.text),
        reps: int.parse(_repsController.text),
        imageUrl: _imageUrlController.text.trim(),
        instructions: _instructionsController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercício cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar exercício: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Exercício'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nome do exercício
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Exercício *',
                hintText: 'Ex: Supino Reto',
                prefixIcon: Icon(Icons.fitness_center),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o nome do exercício';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tipo de treino
            TextFormField(
              controller: _workoutTypeController,
              decoration: const InputDecoration(
                labelText: 'Tipo de Treino *',
                hintText: 'Ex: Peito, Costas, Pernas',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o tipo de treino';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Séries e Repetições
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _seriesController,
                    decoration: const InputDecoration(
                      labelText: 'Séries *',
                      hintText: '3',
                      prefixIcon: Icon(Icons.repeat),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obrigatório';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _repsController,
                    decoration: const InputDecoration(
                      labelText: 'Repetições *',
                      hintText: '12',
                      prefixIcon: Icon(Icons.numbers),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obrigatório';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // URL da imagem/GIF/vídeo
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL do GIF/Vídeo de Demonstração',
                hintText: 'https://example.com/exercicio.gif',
                prefixIcon: Icon(Icons.video_library),
                border: OutlineInputBorder(),
                helperText: 'Cole a URL de um GIF ou vídeo de demonstração',
                helperMaxLines: 2,
              ),
              keyboardType: TextInputType.url,
              maxLines: 2,
            ),
            const SizedBox(height: 8),

            // Dica sobre onde encontrar GIFs
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Dica:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Você pode encontrar GIFs de exercícios em sites como:\n• Giphy.com\n• Tenor.com\n• ou usar links diretos de imagens/vídeos',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instruções
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instruções de Execução',
                hintText: 'Descreva como executar o exercício corretamente...',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira as instruções do exercício';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Botão de cadastrar
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createExercise,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_isLoading ? 'Cadastrando...' : 'Cadastrar Exercício'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
