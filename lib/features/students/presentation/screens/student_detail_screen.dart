import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/core/models/anamnesis_model.dart';
import 'package:new_gym_app/core/utils/anamnesis_template.dart';
import 'package:new_gym_app/features/anamnesis/presentation/providers/anamnesis_providers.dart';
import 'package:new_gym_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:new_gym_app/features/students/presentation/providers/students_provider.dart';

import '../providers/workout_provider.dart';

class StudentDetailScreen extends ConsumerStatefulWidget {
  final String studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  ConsumerState<StudentDetailScreen> createState() =>
      _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsListProvider);
    final student = studentsAsync.value
        ?.where((s) => s.uid == widget.studentId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(student?.name ?? 'Detalhe do Aluno'),
        backgroundColor: Theme.of(context).primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.assignment), text: 'Anamneses'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Treinos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnamnesisTab(context),
          _buildWorkoutsTab(context),
        ],
      ),
    );
  }

  // ─── Aba de Anamneses ────────────────────────────────────────────────────

  Widget _buildAnamnesisTab(BuildContext context) {
    final personalId = ref.watch(currentUserProvider)?.uid ?? '';
    final anamnesesAsync = ref.watch(
      ptStudentAnamnesesProvider((widget.studentId, personalId)),
    );

    return anamnesesAsync.when(
      data: (anamneses) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _createAnamnesis(context),
                icon: const Icon(Icons.add),
                label: const Text('Nova Anamnese'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          if (anamneses.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Nenhuma anamnese criada',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: anamneses.length,
                itemBuilder: (context, index) =>
                    _buildAnamnesisCard(context, anamneses[index]),
              ),
            ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
    );
  }

  Widget _buildAnamnesisCard(BuildContext context, Anamnesis anamnesis) {
    final statusColor = _statusColor(anamnesis.status);
    final statusLabel = _statusLabel(anamnesis.status);
    final total = anamnesis.questions.length;
    final answered = anamnesis.answers.length;
    final progress = total > 0 ? answered / total : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(anamnesis.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$answered/$total respostas',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              color: statusColor,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 12),
            _buildAnamnesisAction(context, anamnesis),
          ],
        ),
      ),
    );
  }

  Widget _buildAnamnesisAction(BuildContext context, Anamnesis anamnesis) {
    switch (anamnesis.status) {
      case AnamnesisStatus.analyzed:
      case AnamnesisStatus.completed:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                context.push('/anamnesis-insights/${anamnesis.id}'),
            icon: const Icon(Icons.analytics, size: 16),
            label: const Text('Ver Insights e Sugestões'),
          ),
        );
      case AnamnesisStatus.inProgress:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.hourglass_top, size: 16),
            label: const Text('Aguardando resposta do aluno'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
          ),
        );
      case AnamnesisStatus.draft:
        return const SizedBox.shrink();
    }
  }

  // ─── Aba de Treinos ──────────────────────────────────────────────────────

  Widget _buildWorkoutsTab(BuildContext context) {
    final workoutsAsync = ref.watch(
      studentWorkoutsStreamProvider(widget.studentId),
    );

    return workoutsAsync.when(
      data: (workouts) {
        if (workouts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fitness_center_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nenhum treino criado',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.push('/create-workout/${widget.studentId}'),
                  icon: const Icon(Icons.add),
                  label: const Text('Criar Primeiro Treino'),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.push('/create-workout/${widget.studentId}'),
                  icon: const Icon(Icons.add),
                  label: const Text('Novo Treino'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
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
                        backgroundColor: Theme.of(context).primaryColor,
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${workout.exercises.length} exercício(s)',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            context.push('/edit-workout/${workout.id}'),
                      ),
                      onTap: () =>
                          context.push('/workout-detail/${workout.id}'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erro: $error'),
          ],
        ),
      ),
    );
  }

  // ─── Criação de anamnese ─────────────────────────────────────────────────

  Future<void> _createAnamnesis(BuildContext context) async {
    final personalId = ref.read(currentUserProvider)?.uid;
    if (personalId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Anamnese'),
        content: const Text(
          'Criar uma anamnese para este aluno?\n\n'
          'O aluno poderá respondê-la quando acessar o app.',
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = ref.read(anamnesisServiceProvider);
      final anamnesisId = await service.createAnamnesis(
        studentId: widget.studentId,
        personalId: personalId,
        baseQuestions: AnamnesisTemplate.getBaseQuestions(),
      );
      await service.sendToStudent(anamnesisId);

      if (!context.mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anamnese criada e enviada para o aluno!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar anamnese: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

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

  String _statusLabel(AnamnesisStatus status) {
    switch (status) {
      case AnamnesisStatus.draft:
        return 'Rascunho';
      case AnamnesisStatus.inProgress:
        return 'Em andamento';
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
