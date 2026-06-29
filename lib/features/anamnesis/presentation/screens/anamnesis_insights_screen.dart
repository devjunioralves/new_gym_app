import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/core/models/anamnesis_insights_model.dart';
import 'package:new_gym_app/core/models/workout_suggestion_model.dart';
import 'package:new_gym_app/features/anamnesis/presentation/providers/anamnesis_providers.dart';

/// Tela para Personal visualizar insights e aprovar sugestões de treino
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

                // Botão de aprovar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: suggestion.approvedByPersonal
                        ? null
                        : () => _approveSuggestion(suggestion),
                    icon: Icon(
                      suggestion.approvedByPersonal
                          ? Icons.check_circle
                          : Icons.thumb_up,
                    ),
                    label: Text(
                      suggestion.approvedByPersonal
                          ? 'Aprovado'
                          : 'Aprovar e Criar Treino',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: suggestion.approvedByPersonal
                          ? Colors.grey
                          : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
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

  Future<void> _approveSuggestion(WorkoutSuggestion suggestion) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aprovar Sugestão'),
        content: const Text(
          'Deseja aprovar esta sugestão?\n\n'
          'Um treino será criado automaticamente na lista do aluno.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Aprovar e Criar Treino'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final workoutId = await ref
          .read(workoutSuggestionNotifierProvider.notifier)
          .approveSuggestion(suggestion);

      if (!mounted) return;
      Navigator.of(context).pop(); // fecha loading

      ref.invalidate(workoutSuggestionsProvider(widget.anamnesisId));

      context.push('/workout-detail/$workoutId');
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // fecha loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar treino: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
