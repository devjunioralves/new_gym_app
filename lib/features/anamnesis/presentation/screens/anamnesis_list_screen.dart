import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/core/models/anamnesis_model.dart';
import 'package:new_gym_app/core/models/user_model.dart';
import 'package:new_gym_app/core/models/user_role.dart';
import 'package:new_gym_app/core/shared_widgets/app_footer.dart';
import 'package:new_gym_app/features/anamnesis/presentation/providers/anamnesis_providers.dart';
import 'package:new_gym_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:new_gym_app/features/students/presentation/providers/students_provider.dart';

class AnamnesisListScreen extends ConsumerWidget {
  const AnamnesisListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentUser.isPersonalTrainer) {
      return _PersonalAnamnesisListScreen(personalId: currentUser.uid);
    } else {
      return _StudentAnamnesisListScreen(studentId: currentUser.uid);
    }
  }
}

// ---------- VISÃO DO PERSONAL ----------

class _PersonalAnamnesisListScreen extends ConsumerWidget {
  final String personalId;
  const _PersonalAnamnesisListScreen({required this.personalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anamnesesAsync = ref.watch(personalAnamnesesProvider(personalId));
    final studentsAsync = ref.watch(studentsListProvider);
    final students = studentsAsync.asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anamneses'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      bottomNavigationBar: const AppFooter(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-anamnesis'),
        icon: const Icon(Icons.add),
        label: const Text('Nova Anamnese'),
        backgroundColor: Colors.green,
      ),
      body: anamnesesAsync.when(
        data: (anamneses) {
          if (anamneses.isEmpty) {
            return _buildEmpty(
              context,
              icon: Icons.assignment_outlined,
              message: 'Nenhuma anamnese criada ainda',
              actionLabel: 'Criar Primeira Anamnese',
              onAction: () => context.push('/create-anamnesis'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: anamneses.length,
            itemBuilder: (context, index) {
              final anamnesis = anamneses[index];
              final student = students.firstWhere(
                (s) => s.uid == anamnesis.studentId,
                orElse: () => User(
                  uid: anamnesis.studentId,
                  name: 'Aluno',
                  email: '',
                  photoUrl: '',
                  role: UserRole.student,
                ),
              );
              return _AnamnesisCard(
                anamnesis: anamnesis,
                title: student.name,
                subtitle: student.email,
                onTap: () => _navigate(context, anamnesis),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}

// ---------- VISÃO DO ALUNO ----------

class _StudentAnamnesisListScreen extends ConsumerWidget {
  final String studentId;
  const _StudentAnamnesisListScreen({required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anamnesesAsync = ref.watch(studentAnamnesesProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Anamneses'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      bottomNavigationBar: const AppFooter(),
      body: anamnesesAsync.when(
        data: (anamneses) {
          if (anamneses.isEmpty) {
            return _buildEmpty(
              context,
              icon: Icons.assignment_outlined,
              message: 'Nenhuma anamnese disponível',
              actionLabel: null,
              onAction: null,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: anamneses.length,
            itemBuilder: (context, index) {
              final anamnesis = anamneses[index];
              return _AnamnesisCard(
                anamnesis: anamnesis,
                title: _statusText(anamnesis.status),
                subtitle:
                    'Criada em ${_formatDate(anamnesis.createdAt)}',
                onTap: () => _navigateStudent(context, anamnesis),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}

// ---------- WIDGETS COMPARTILHADOS ----------

void _navigate(BuildContext context, Anamnesis anamnesis) {
  if (anamnesis.status == AnamnesisStatus.completed ||
      anamnesis.status == AnamnesisStatus.analyzed) {
    context.push('/anamnesis-insights/${anamnesis.id}');
  } else {
    context.push('/answer-anamnesis/${anamnesis.id}');
  }
}

void _navigateStudent(BuildContext context, Anamnesis anamnesis) {
  if (anamnesis.status == AnamnesisStatus.completed ||
      anamnesis.status == AnamnesisStatus.analyzed) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              anamnesis.status == AnamnesisStatus.analyzed
                  ? Icons.fitness_center
                  : Icons.hourglass_top,
              size: 56,
              color: anamnesis.status == AnamnesisStatus.analyzed
                  ? Colors.green
                  : Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              anamnesis.status == AnamnesisStatus.analyzed
                  ? 'Análise concluída!'
                  : 'Aguardando avaliação',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              anamnesis.status == AnamnesisStatus.analyzed
                  ? 'Seu personal trainer já analisou suas respostas e em breve criará seu treino personalizado.'
                  : 'Suas respostas foram enviadas. Aguarde seu personal trainer avaliar e criar seu treino.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  } else {
    context.push('/answer-anamnesis/${anamnesis.id}');
  }
}

Widget _buildEmpty(
  BuildContext context, {
  required IconData icon,
  required String message,
  required String? actionLabel,
  required VoidCallback? onAction,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ],
    ),
  );
}

class _AnamnesisCard extends StatelessWidget {
  final Anamnesis anamnesis;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AnamnesisCard({
    required this.anamnesis,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(anamnesis.status);
    final progress = anamnesis.questions.isEmpty
        ? 0.0
        : anamnesis.answers.length / anamnesis.questions.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      _statusText(anamnesis.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${anamnesis.answers.length}/${anamnesis.questions.length} respostas',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                minHeight: 5,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _statusColor(AnamnesisStatus status) {
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

String _statusText(AnamnesisStatus status) {
  switch (status) {
    case AnamnesisStatus.draft:
      return 'Rascunho';
    case AnamnesisStatus.inProgress:
      return 'Em progresso';
    case AnamnesisStatus.completed:
      return 'Concluída';
    case AnamnesisStatus.analyzed:
      return 'Analisada';
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
