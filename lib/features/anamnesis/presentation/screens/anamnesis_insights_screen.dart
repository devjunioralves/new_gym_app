import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/core/models/anamnesis_insights_model.dart';
import 'package:new_gym_app/core/models/workout_suggestion_model.dart';
import 'package:new_gym_app/features/anamnesis/presentation/providers/anamnesis_providers.dart';
import 'package:new_gym_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:new_gym_app/features/exercise_detail/presentation/providers/exercise_provider.dart';

/// Tela exclusiva para Personal Trainer visualizar insights e aprovar sugestões
class AnamnesisInsightsScreen extends ConsumerStatefulWidget {
  final String anamnesisId;

  const AnamnesisInsightsScreen({super.key, required this.anamnesisId});

  @override
  ConsumerState<AnamnesisInsightsScreen> createState() =>
      _AnamnesisInsightsScreenState();
}

class _AnamnesisInsightsScreenState
    extends ConsumerState<AnamnesisInsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGeneratingSuggestions = false;

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
    final user = ref.watch(currentUserProvider);

    if (user == null || user.isStudent) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acesso restrito')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Esta área é exclusiva para Personal Trainers.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final insightsAsync = ref.watch(
      anamnesisInsightsProvider(widget.anamnesisId),
    );
    final suggestionsAsync = ref.watch(
      workoutSuggestionsProvider(widget.anamnesisId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise da Anamnese'),
        backgroundColor: Theme.of(context).primaryColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Insights', icon: Icon(Icons.analytics)),
            Tab(text: 'Sugestões', icon: Icon(Icons.fitness_center)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Insights
          insightsAsync.when(
            data: (insights) {
              if (insights == null) {
                return const Center(
                  child: Text('Anamnese ainda não foi analisada'),
                );
              }
              return _buildInsightsView(insights);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Erro: $error')),
          ),

          // Tab 2: Sugestões
          suggestionsAsync.when(
            data: (suggestions) {
              if (suggestions.isEmpty) {
                return _buildEmptySuggestionsView();
              }
              return _buildSuggestionsView(suggestions);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Erro: $error')),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsView(AnamnesisInsights insights) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumo
          _buildCard(
            title: '📋 Resumo',
            child: Text(insights.summary, style: const TextStyle(fontSize: 16)),
          ),

          // Nível de condicionamento
          _buildCard(
            title: '💪 Nível de Condicionamento',
            child: Row(
              children: [
                _buildFitnessLevelChip(insights.fitnessLevel),
                const Spacer(),
                Text(
                  'Risco de lesão: ${(insights.injuryRisk * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: insights.injuryRisk > 0.7
                        ? Colors.red
                        : insights.injuryRisk > 0.4
                        ? Colors.orange
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Condições de saúde
          if (insights.conditions.isNotEmpty)
            _buildCard(
              title: '⚠️ Condições de Saúde',
              child: Column(
                children: insights.conditions.map((condition) {
                  return _buildConditionCard(condition);
                }).toList(),
              ),
            ),

          // Objetivos
          if (insights.goals.isNotEmpty)
            _buildCard(
              title: '🎯 Objetivos',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: insights.goals.map((goal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text(goal)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // Limitações
          if (insights.limitations.isNotEmpty)
            _buildCard(
              title: '🚫 Limitações e Restrições',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: insights.limitations.map((limitation) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(child: Text(limitation)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // Recomendações
          if (insights.recommendations.isNotEmpty)
            _buildCard(
              title: '💡 Recomendações',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: insights.recommendations.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(entry.value),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptySuggestionsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma sugestão gerada ainda',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Clique no botão abaixo para gerar sugestões de treino baseadas na análise da IA',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isGeneratingSuggestions ? null : _generateSuggestions,
            icon: const Icon(Icons.auto_awesome),
            label: _isGeneratingSuggestions
                ? const Text('Gerando...')
                : const Text('Gerar Sugestões com IA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsView(List<WorkoutSuggestion> suggestions) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return _buildSuggestionCard(suggestion, index + 1);
      },
    );
  }

  Widget _buildSuggestionCard(WorkoutSuggestion suggestion, int number) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: ExpansionTile(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple,
              child: Text(
                '$number',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (suggestion.approvedByPersonal)
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${suggestion.exercises.length} exercícios'),
            Text(
              'Confiança: ${(suggestion.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.blue),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Justificativa
                const Text(
                  'Justificativa:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(suggestion.rationale),
                const SizedBox(height: 16),

                // Exercícios
                const Text(
                  'Exercícios:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...suggestion.exercises.map((exercise) {
                  return Card(
                    color: Colors.grey.shade50,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(exercise.exerciseName),
                      subtitle: Text(
                        '${exercise.series}x${exercise.reps}${exercise.rest != null ? ' • Descanso: ${exercise.rest}s' : ''}\n${exercise.reason}',
                      ),
                      dense: true,
                    ),
                  );
                }),

                // Precauções
                if (suggestion.precautions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Precauções:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...suggestion.precautions.map((precaution) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(precaution)),
                        ],
                      ),
                    );
                  }),
                ],

                // Referências científicas
                if (suggestion.references.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    '📚 Base Científica:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...suggestion.references.map((ref) {
                    return Card(
                      color: Colors.blue.shade50,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          ref.title,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(ref.source),
                        dense: true,
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 16),

                if (!suggestion.approvedByPersonal)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditAndApproveSheet(suggestion),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar e Aprovar Treino'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  )
                else
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Treino criado', style: TextStyle(color: Colors.green)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFitnessLevelChip(FitnessLevel level) {
    Color color;
    String label;

    switch (level) {
      case FitnessLevel.sedentary:
        color = Colors.red;
        label = 'Sedentário';
        break;
      case FitnessLevel.beginner:
        color = Colors.orange;
        label = 'Iniciante';
        break;
      case FitnessLevel.intermediate:
        color = Colors.blue;
        label = 'Intermediário';
        break;
      case FitnessLevel.advanced:
        color = Colors.green;
        label = 'Avançado';
        break;
    }

    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  Widget _buildConditionCard(HealthCondition condition) {
    Color severityColor;
    switch (condition.severity) {
      case ConditionSeverity.mild:
        severityColor = Colors.green;
        break;
      case ConditionSeverity.moderate:
        severityColor = Colors.orange;
        break;
      case ConditionSeverity.severe:
        severityColor = Colors.red;
        break;
    }

    return Card(
      color: severityColor.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, color: severityColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    condition.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(
                    condition.severity.toString().split('.').last,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: severityColor,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            if (condition.restrictions.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...condition.restrictions.map((restriction) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $restriction'),
                );
              }),
            ],
            if (condition.notes != null && condition.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                condition.notes!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generateSuggestions() async {
    setState(() => _isGeneratingSuggestions = true);

    try {
      await ref
          .read(workoutSuggestionNotifierProvider.notifier)
          .generateSuggestions(anamnesisId: widget.anamnesisId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sugestões geradas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Invalida provider para recarregar
        ref.invalidate(workoutSuggestionsProvider(widget.anamnesisId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar sugestões: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingSuggestions = false);
      }
    }
  }

  Future<void> _showEditAndApproveSheet(WorkoutSuggestion suggestion) async {
    final editedExercises = List<ExerciseSuggestion>.from(suggestion.exercises);
    bool confirmed = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, controller) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          suggestion.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Exercícios',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      ...editedExercises.asMap().entries.map((entry) {
                        final i = entry.key;
                        final ex = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              ex.exerciseName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text('${ex.series} séries × ${ex.reps}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Remover',
                              onPressed: () =>
                                  setSheetState(() => editedExercises.removeAt(i)),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await _showExercisePicker(sheetContext);
                          if (picked != null) {
                            setSheetState(() => editedExercises.add(picked));
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar da biblioteca'),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    16 + MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: editedExercises.isEmpty
                          ? null
                          : () {
                              confirmed = true;
                              Navigator.of(sheetContext).pop();
                            },
                      icon: const Icon(Icons.check),
                      label: Text(
                        'Confirmar e criar treino (${editedExercises.length})',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (!confirmed || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Criando treino...'),
          ],
        ),
      ),
    );

    try {
      final workoutId = await ref
          .read(workoutSuggestionNotifierProvider.notifier)
          .approveSuggestion(suggestion, editedExercises: editedExercises);

      if (!mounted) return;
      Navigator.of(context).pop();
      ref.invalidate(workoutSuggestionsProvider(widget.anamnesisId));
      context.push('/workout-detail/$workoutId');
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar treino: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<ExerciseSuggestion?> _showExercisePicker(BuildContext sheetContext) async {
    final exercisesAsync = ref.read(exerciseListProvider);
    final exercises = exercisesAsync.asData?.value ?? [];

    return showDialog<ExerciseSuggestion>(
      context: sheetContext,
      builder: (dialogContext) {
        String search = '';
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final filtered = exercises
                .where((e) => e.name.toLowerCase().contains(search.toLowerCase()))
                .toList();

            return AlertDialog(
              title: const Text('Selecionar exercício'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar exercício...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setDialogState(() => search = v),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('Nenhum exercício encontrado'))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final ex = filtered[i];
                                return ListTile(
                                  title: Text(ex.name),
                                  subtitle: Text(ex.workoutType),
                                  onTap: () => Navigator.of(dialogContext).pop(
                                    ExerciseSuggestion(
                                      exerciseId: ex.id,
                                      exerciseName: ex.name,
                                      muscleGroup: ex.workoutType,
                                      series: 3,
                                      reps: '10-12',
                                      notes: '',
                                      reason: 'Adicionado manualmente pelo personal',
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
