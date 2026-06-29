import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/core/utils/anamnesis_template.dart';
import 'package:new_gym_app/features/anamnesis/presentation/providers/anamnesis_providers.dart';
import 'package:new_gym_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:new_gym_app/features/students/presentation/providers/students_provider.dart';

/// Tela para Personal criar anamnese para um aluno
class CreateAnamnesisScreen extends ConsumerWidget {
  const CreateAnamnesisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final studentsAsync = ref.watch(filteredStudentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Anamnese'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: studentsAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Você ainda não tem alunos cadastrados',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Como funciona',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoStep(
                      '1.',
                      'Selecione o aluno que responderá a anamnese',
                    ),
                    _buildInfoStep(
                      '2.',
                      'O aluno responderá 37 perguntas base sobre saúde',
                    ),
                    _buildInfoStep(
                      '3.',
                      'IA gerará perguntas adicionais conforme respostas',
                    ),
                    _buildInfoStep(
                      '4.',
                      'Sistema analisará e sugerirá treinos personalizados',
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Selecione um aluno:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            student.name.isNotEmpty
                                ? student.name[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          student.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(student.email),
                        trailing: ElevatedButton.icon(
                          onPressed: () => _createAnamnesis(
                            context,
                            ref,
                            student.uid,
                            currentUser?.uid ?? '',
                          ),
                          icon: const Icon(Icons.assignment, size: 18),
                          label: const Text('Criar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Erro ao carregar alunos: $error')),
      ),
    );
  }

  Widget _buildInfoStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Future<void> _createAnamnesis(
    BuildContext context,
    WidgetRef ref,
    String studentId,
    String personalId,
  ) async {
    // Mostra dialog de confirmação
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Anamnese'),
        content: const Text(
          'Deseja criar uma nova anamnese para este aluno?\n\n'
          'O aluno receberá 37 perguntas iniciais sobre sua saúde e objetivos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Mostra loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Cria anamnese no Firestore e envia para o aluno responder
      final service = ref.read(anamnesisServiceProvider);
      final anamnesisId = await service.createAnamnesis(
        studentId: studentId,
        personalId: personalId,
        baseQuestions: AnamnesisTemplate.getBaseQuestions(),
      );
      await service.sendToStudent(anamnesisId);

      if (!context.mounted) return;

      // Fecha loading
      Navigator.of(context).pop();

      // Mostra sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anamnese criada e enviada para o aluno!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navega para a lista de anamneses
      context.go('/anamnesis-list');
    } catch (e) {
      if (!context.mounted) return;

      // Fecha loading
      Navigator.of(context).pop();

      // Mostra erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar anamnese: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
