import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:new_gym_app/core/models/anamnesis_insights_model.dart';
import 'package:new_gym_app/core/models/exercise_model.dart';
import 'package:new_gym_app/core/models/workout_suggestion_model.dart';

/// Service para geração de sugestões de treino usando RAG (Retrieval-Augmented Generation)
/// com base científica (ACSM, NSCA, literatura)
class RAGWorkoutService {
  final GenerativeModel _model;

  RAGWorkoutService({required String apiKey})
    : _model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.8,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 4096,
        ),
      );

  /// Gera sugestões de treino baseadas nos insights da anamnese
  /// e na biblioteca de exercícios disponíveis
  Future<List<WorkoutSuggestion>> generateWorkoutSuggestions({
    required String anamnesisId,
    required AnamnesisInsights insights,
    required List<Exercise> availableExercises,
  }) async {
    // 1. Filtra exercícios seguros baseado nas restrições
    final safeExercises = _filterSafeExercises(
      exercises: availableExercises,
      conditions: insights.conditions,
    );

    // 2. Cria contexto rico para a IA
    final prompt = _buildRAGPrompt(insights, safeExercises);

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final jsonText = _extractJson(response.text ?? '');
      final json = jsonDecode(jsonText) as Map<String, dynamic>;

      final suggestions = (json['suggestions'] as List<dynamic>)
          .map(
            (s) => _parseSuggestion(
              data: s as Map<String, dynamic>,
              anamnesisId: anamnesisId,
            ),
          )
          .toList();

      return suggestions;
    } catch (e) {
      throw Exception('Erro ao gerar sugestões: $e');
    }
  }

  /// Filtra exercícios seguros baseado nas condições de saúde
  List<Exercise> _filterSafeExercises({
    required List<Exercise> exercises,
    required List<HealthCondition> conditions,
  }) {
    // Coleta todas as restrições
    final allRestrictions = conditions
        .expand((c) => c.restrictions)
        .map((r) => r.toLowerCase())
        .toSet();

    // Filtra exercícios que não estão nas restrições
    return exercises.where((exercise) {
      final exerciseName = exercise.name.toLowerCase();
      final exerciseType = exercise.workoutType.toLowerCase();

      // Verifica se o exercício ou tipo está restrito
      return !allRestrictions.any(
        (restriction) =>
            exerciseName.contains(restriction) ||
            exerciseType.contains(restriction),
      );
    }).toList();
  }

  /// Constrói prompt RAG com base científica
  String _buildRAGPrompt(
    AnamnesisInsights insights,
    List<Exercise> safeExercises,
  ) {
    final exerciseList = safeExercises
        .map((e) => '- ${e.name} (${e.workoutType})')
        .join('\n');

    return '''
Você é um especialista em prescrição de exercícios com PhD em Fisiologia do Exercício.

TAREFA:
Crie 2-3 opções de treino personalizadas baseadas RIGOROSAMENTE em evidências científicas.

PERFIL DO ALUNO:
${insights.summary}

OBJETIVOS:
${insights.goals.join(', ')}

LIMITAÇÕES E CONDIÇÕES:
${_formatConditions(insights.conditions)}
${insights.limitations.isNotEmpty ? '\nLimitações Físicas:\n${insights.limitations.map((l) => '- $l').join('\n')}' : ''}

NÍVEL DE CONDICIONAMENTO: ${insights.fitnessLevel.displayName}
RISCO DE LESÃO: ${(insights.injuryRisk * 100).toStringAsFixed(0)}%

EXERCÍCIOS DISPONÍVEIS E SEGUROS:
$exerciseList

DIRETRIZES CIENTÍFICAS A SEGUIR:

1. ACSM Guidelines (2021):
   - Iniciantes: 2-3x/semana, 8-12 repetições, 1-3 séries
   - Intermediários: 3-4x/semana, 6-12 repetições, 3-4 séries
   - Avançados: 4-6x/semana, periodização, 4-6 séries

2. NSCA Essentials:
   - Progressão: 2-10% de carga por semana (máximo)
   - Descanso: 48-72h entre grupos musculares
   - Volume: ajustar baseado em resposta individual

3. Condições Especiais:
   - Hipertensão: evitar Valsalva, preferir circuitos
   - Dores articulares: ROM controlado, baixo impacto
   - Sedentários: começar 40-60% 1RM, progressão lenta

FORMATO DE RESPOSTA (JSON):
{
  "suggestions": [
    {
      "name": "Nome descritivo do treino",
      "exercises": [
        {
          "exerciseName": "nome exato do exercício da lista",
          "series": 3,
          "reps": "10-12" ou "30 segundos",
          "rest": "60-90 segundos",
          "notes": "técnica e cuidados específicos",
          "reason": "justificativa científica (cite fonte: ACSM, NSCA, etc)",
          "modifications": ["modificação 1 se necessário", "modificação 2"]
        }
      ],
      "rationale": "Justificativa geral do treino baseada em evidências (cite estudos ou guidelines)",
      "precautions": ["cuidado específico 1", "cuidado 2"],
      "references": [
        {
          "title": "Título do guideline/estudo",
          "source": "ACSM, NSCA, journal",
          "url": "link se disponível",
          "summary": "relevância para este caso"
        }
      ],
      "confidence": 0.85
    }
  ]
}

IMPORTANTE:
- Use APENAS exercícios da lista fornecida
- Base TODAS as decisões em evidências (ACSM, NSCA, literatura)
- Seja conservador em casos de alto risco
- Inclua SEMPRE as referências científicas
- Sugira modificações quando apropriado
- Confidence deve refletir a certeza científica (0.0-1.0)
''';
  }

  /// Formata condições de saúde para o prompt
  String _formatConditions(List<HealthCondition> conditions) {
    if (conditions.isEmpty) return 'Nenhuma condição reportada';

    return conditions
        .map((c) {
          final restrictions = c.restrictions.isNotEmpty
              ? '\n  Evitar: ${c.restrictions.join(", ")}'
              : '';
          return '- ${c.name} (${c.severity.displayName})$restrictions';
        })
        .join('\n');
  }

  /// Converte dados JSON em WorkoutSuggestion
  WorkoutSuggestion _parseSuggestion({
    required Map<String, dynamic> data,
    required String anamnesisId,
  }) {
    return WorkoutSuggestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      anamnesisId: anamnesisId,
      name: data['name'] as String,
      exercises: (data['exercises'] as List<dynamic>)
          .map((e) => ExerciseSuggestion.fromMap(e as Map<String, dynamic>))
          .toList(),
      rationale: data['rationale'] as String,
      precautions: (data['precautions'] as List<dynamic>).cast<String>(),
      references: (data['references'] as List<dynamic>)
          .map((r) => ScientificReference.fromMap(r as Map<String, dynamic>))
          .toList(),
      confidence: (data['confidence'] ?? 0.7).toDouble(),
      generatedAt: DateTime.now(),
    );
  }

  /// Extrai JSON do texto da resposta
  String _extractJson(String text) {
    final jsonMatch = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
    ).firstMatch(text);
    if (jsonMatch != null) {
      return jsonMatch.group(1)!.trim();
    }

    final jsonObjMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    if (jsonObjMatch != null) {
      return jsonObjMatch.group(0)!.trim();
    }

    return text.trim();
  }
}
