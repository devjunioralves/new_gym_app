import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/core/models/anamnesis_model.dart';
import 'package:new_gym_app/features/anamnesis/presentation/providers/anamnesis_providers.dart';
import 'package:new_gym_app/features/auth/presentation/providers/auth_provider.dart';

/// Tela para listar todas as anamneses do Personal
class AnamnesisListScreen extends ConsumerWidget {
  const AnamnesisListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final anamnesesAsync = ref.watch(
      personalAnamnesesProvider(currentUser?.uid ?? ''),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anamneses'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-anamnesis'),
        icon: const Icon(Icons.add),
        label: const Text('Nova Anamnese'),
        backgroundColor: Colors.green,
      ),
      body: anamnesesAsync.when(
        data: (anamneses) {
          if (anamneses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma anamnese criada ainda',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/create-anamnesis'),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Primeira Anamnese'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: anamneses.length,
            itemBuilder: (context, index) {
              final anamnesis = anamneses[index];
              return _buildAnamnesisCard(context, anamnesis);
            },
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

  Widget _buildAnamnesisCard(BuildContext context, Anamnesis anamnesis) {
    final statusColor = _getStatusColor(anamnesis.status);
    final statusText = _getStatusText(anamnesis.status);
    final progress = anamnesis.questions.isEmpty
        ? 0.0
        : anamnesis.answers.length / anamnesis.questions.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (anamnesis.status == AnamnesisStatus.completed ||
              anamnesis.status == AnamnesisStatus.analyzed) {
            context.push('/anamnesis-insights/${anamnesis.id}');
          } else {
            context.push('/answer-anamnesis/${anamnesis.id}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aluno: ${anamnesis.studentId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Criado em: ${_formatDate(anamnesis.createdAt)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Barra de progresso
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso: ${anamnesis.answers.length}/${anamnesis.questions.length}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    minHeight: 6,
                  ),
                ],
              ),

              // Ações
              const SizedBox(height: 12),
              Row(
                children: [
                  if (anamnesis.status == AnamnesisStatus.completed ||
                      anamnesis.status == AnamnesisStatus.analyzed)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push('/anamnesis-insights/${anamnesis.id}');
                        },
                        icon: const Icon(Icons.analytics, size: 16),
                        label: const Text('Ver Insights'),
                      ),
                    ),
                  if (anamnesis.status == AnamnesisStatus.inProgress)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push('/answer-anamnesis/${anamnesis.id}');
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Continuar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(AnamnesisStatus status) {
    switch (status) {
      case AnamnesisStatus.draft:
        return Colors.grey;
      case AnamnesisStatus.inProgress:
        return Colors.orange;
      case AnamnesisStatus.completed:
        return Colors.blue;
      case AnamnesisStatus.analyzed:
        return Colors.green;
    }
  }

  String _getStatusText(AnamnesisStatus status) {
    switch (status) {
      case AnamnesisStatus.draft:
        return 'Rascunho';
      case AnamnesisStatus.inProgress:
        return 'Em Progresso';
      case AnamnesisStatus.completed:
        return 'Concluída';
      case AnamnesisStatus.analyzed:
        return 'Analisada';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
