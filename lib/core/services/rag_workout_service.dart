import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:new_gym_app/core/models/anamnesis_insights_model.dart';
import 'package:new_gym_app/core/models/workout_suggestion_model.dart';

class RAGWorkoutService {
  final GenerativeModel _model;

  RAGWorkoutService({required String apiKey})
    : _model = GenerativeModel(
        model: 'gemini-3.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.8,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
        ),
      );

  Future<List<WorkoutSuggestion>> generateWorkoutSuggestions({
    required String anamnesisId,
    required AnamnesisInsights insights,
  }) async {
    final prompt = _buildRAGPrompt(insights);

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

  String _buildRAGPrompt(AnamnesisInsights insights) {
    return '''
Você é um especialista em prescrição de exercícios com PhD em Fisiologia do Exercício,
certificado pelo ACSM e NSCA.

TAREFA:
Crie 1 plano de treino personalizado baseado em evidências científicas (ACSM/NSCA).
Você tem liberdade total para prescrever qualquer exercício adequado ao perfil do aluno.

PERFIL DO ALUNO:
${insights.summary}

OBJETIVOS: ${insights.goals.join(', ')}
NÍVEL: ${insights.fitnessLevel.displayName}
RISCO DE LESÃO: ${(insights.injuryRisk * 100).toStringAsFixed(0)}%

LIMITAÇÕES E CONDIÇÕES:
${_formatConditions(insights.conditions)}
${insights.limitations.isNotEmpty ? 'Limitações físicas: ${insights.limitations.join(', ')}' : ''}

DIRETRIZES CIENTÍFICAS:
- Iniciantes: 2-3x/sem, 8-15 reps, 1-3 séries, carga leve-moderada (ACSM 2021)
- Intermediários: 3-4x/sem, 6-12 reps, 3-4 séries, progressão controlada
- Avançados: 4-6x/sem, 4-12 reps, 4-6 séries, periodização
- Progressão máxima de carga: 10%/semana (NSCA Position Statement)
- Hipertensão: evitar manobra de Valsalva, preferir cargas moderadas
- Lesões articulares: ROM controlado, evitar impacto excessivo
- Gravidez: posição supina após 1º trimestre, intensidade moderada, sem impacto
- SOP/distúrbios hormonais: priorizar treino resistido e HIIT moderado
- Osteoporose/osteopenia: exercícios de impacto leve com suporte ósseo (caminhada, mini-saltos), resistência moderada
- Hérnia: evitar compressão abdominal elevada, sem Valsalva

RESPONDA APENAS com JSON válido, sem texto extra:
{
  "suggestions": [
    {
      "name": "Nome descritivo do treino",
      "exercises": [
        {
          "exerciseName": "nome do exercício em português",
          "muscleGroup": "grupo muscular principal (ex: Peito, Costas, Pernas, Ombro, Bíceps, Tríceps, Core, Glúteo, Cardio)",
          "series": 3,
          "reps": "10-12",
          "rest": "60s",
          "notes": "instrução técnica e cuidados",
          "reason": "justificativa baseada em ACSM/NSCA ou evidência científica",
          "modifications": ["variação mais fácil ou adaptação se necessário"]
        }
      ],
      "rationale": "Justificativa geral do plano baseada em evidências",
      "precautions": ["cuidado específico 1", "cuidado específico 2"],
      "references": [
        {
          "title": "Título do guideline ou estudo",
          "source": "ACSM, NSCA, ou journal científico",
          "url": "",
          "summary": "Como essa referência justifica o plano"
        }
      ],
      "confidence": 0.85
    }
  ]
}
''';
  }

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

  WorkoutSuggestion _parseSuggestion({
    required Map<String, dynamic> data,
    required String anamnesisId,
  }) {
    return WorkoutSuggestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      anamnesisId: anamnesisId,
      name: data['name'] as String? ?? 'Treino personalizado',
      exercises: (data['exercises'] as List<dynamic>? ?? []).map((e) {
        final map = e as Map<String, dynamic>;
        return ExerciseSuggestion.fromMap(map);
      }).toList(),
      rationale: data['rationale'] as String? ?? '',
      precautions: (data['precautions'] as List<dynamic>?)?.cast<String>() ?? [],
      references: (data['references'] as List<dynamic>? ?? [])
          .map((r) => ScientificReference.fromMap(r as Map<String, dynamic>))
          .toList(),
      confidence: (data['confidence'] ?? 0.7).toDouble(),
      generatedAt: DateTime.now(),
    );
  }

  String _extractJson(String text) {
    final jsonMatch = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
    ).firstMatch(text);
    if (jsonMatch != null) return jsonMatch.group(1)!.trim();

    final jsonObjMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    if (jsonObjMatch != null) return jsonObjMatch.group(0)!.trim();

    return text.trim();
  }
}
