import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:new_gym_app/core/models/anamnesis_insights_model.dart';
import 'package:new_gym_app/core/models/anamnesis_model.dart';

/// Service para integração com Google Gemini (IA)
class GeminiService {
  late final GenerativeModel _model;
  final String apiKey;

  GeminiService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );
  }

  /// Gera a próxima pergunta dinâmica baseada nas respostas anteriores
  /// Retorna null se a IA determinar que já tem informação suficiente
  Future<AnamnesisQuestion?> generateNextQuestion({
    required List<AnamnesisQuestion> previousQuestions,
    required List<AnamnesisAnswer> answers,
  }) async {
    final context = _buildQAContext(previousQuestions, answers);

    final prompt =
        '''
Você é um especialista em avaliação física e anamnese para treino personalizado.

Analise as respostas do aluno e decida:
1. Se precisa de MAIS informações para criar um treino seguro e eficaz, gere UMA pergunta relevante
2. Se já tem informação SUFICIENTE sobre objetivos, saúde e limitações, retorne "COMPLETE"

CONTEXTO DAS RESPOSTAS:
$context

INSTRUÇÕES:
- Faça perguntas objetivas e diretas
- Priorize informações sobre saúde, lesões e limitações
- Evite perguntas redundantes
- Seja profissional mas acessível

Responda APENAS com JSON válido:
{
  "action": "ask" ou "complete",
  "question": {
    "text": "sua pergunta aqui",
    "type": "text" | "multipleChoice" | "yesNo" | "scale",
    "options": ["opção1", "opção2"],
    "reason": "breve justificativa técnica"
  }
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final jsonText = _extractJson(response.text ?? '');
      final json = jsonDecode(jsonText) as Map<String, dynamic>;

      if (json['action'] == 'complete') return null;

      final questionData = json['question'] as Map<String, dynamic>;
      final nextOrder = previousQuestions.length;

      return AnamnesisQuestion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: questionData['text'] as String,
        type: _parseQuestionType(questionData['type'] as String),
        options: (questionData['options'] as List<dynamic>?)?.cast<String>(),
        isRequired: true,
        isDynamic: true,
        generatedReason: questionData['reason'] as String?,
        order: nextOrder,
      );
    } catch (e) {
      throw Exception('Erro ao gerar pergunta: $e');
    }
  }

  /// Analisa a anamnese completa e gera insights
  Future<AnamnesisInsights> analyzeAnamnesis({
    required String anamnesisId,
    required List<AnamnesisQuestion> questions,
    required List<AnamnesisAnswer> answers,
  }) async {
    final context = _buildQAContext(questions, answers);

    final prompt =
        '''
Você é um especialista em fisiologia do exercício e prescrição de treino.

Analise esta anamnese e forneça insights profundos baseados em evidências científicas.

ANAMNESE:
$context

TAREFA:
Retorne uma análise completa em JSON com:
1. Resumo do perfil do aluno
2. Condições de saúde identificadas (com severidade e restrições)
3. Objetivos de treino
4. Limitações físicas
5. Nível de condicionamento atual
6. Risco de lesão (0.0 a 1.0)
7. Recomendações gerais

IMPORTANTE:
- Base suas conclusões em guidelines da ACSM e NSCA
- Identifique contraindicações absolutas e relativas
- Seja conservador em relação à segurança
- Use terminologia técnica mas compreensível

Responda APENAS com JSON válido:
{
  "summary": "resumo em 2-3 frases do perfil geral",
  "conditions": [
    {
      "name": "nome da condição (ex: Hipertensão)",
      "severity": "mild" | "moderate" | "severe",
      "restrictions": ["exercício a evitar 1", "exercício a evitar 2"],
      "notes": "observações adicionais"
    }
  ],
  "goals": ["objetivo 1", "objetivo 2"],
  "limitations": ["limitação física 1", "limitação 2"],
  "fitnessLevel": "sedentary" | "beginner" | "intermediate" | "advanced",
  "injuryRisk": 0.0-1.0,
  "recommendations": {
    "frequency": "frequência semanal sugerida",
    "duration": "duração das sessões",
    "focus": "foco principal do treino",
    "progression": "estratégia de progressão",
    "monitoring": "parâmetros a monitorar"
  }
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final jsonText = _extractJson(response.text ?? '');
      final json = jsonDecode(jsonText) as Map<String, dynamic>;

      return AnamnesisInsights.fromJson({
        ...json,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'anamnesisId': anamnesisId,
      });
    } catch (e) {
      throw Exception('Erro ao analisar anamnese: $e');
    }
  }

  /// Constrói contexto formatado de perguntas e respostas
  String _buildQAContext(
    List<AnamnesisQuestion> questions,
    List<AnamnesisAnswer> answers,
  ) {
    final buffer = StringBuffer();

    for (final question in questions) {
      final answer = answers.firstWhere(
        (a) => a.questionId == question.id,
        orElse: () => AnamnesisAnswer(
          questionId: question.id,
          value: 'Não respondida',
          answeredAt: DateTime.now(),
        ),
      );

      buffer.writeln('P: ${question.text}');
      buffer.writeln('R: ${_formatAnswer(answer.value)}');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Formata valor da resposta para exibição
  String _formatAnswer(dynamic value) {
    if (value is List) {
      return value.join(', ');
    } else if (value is DateTime) {
      return value.toString().split(' ')[0];
    }
    return value.toString();
  }

  /// Extrai JSON do texto da resposta (remove markdown se presente)
  String _extractJson(String text) {
    // Remove markdown code blocks se presentes
    final jsonMatch = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
    ).firstMatch(text);
    if (jsonMatch != null) {
      return jsonMatch.group(1)!.trim();
    }

    // Tenta encontrar objeto JSON diretamente
    final jsonObjMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    if (jsonObjMatch != null) {
      return jsonObjMatch.group(0)!.trim();
    }

    return text.trim();
  }

  /// Converte string de tipo para enum
  QuestionType _parseQuestionType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return QuestionType.text;
      case 'multiplechoice':
        return QuestionType.multipleChoice;
      case 'multiselect':
        return QuestionType.multiSelect;
      case 'yesno':
        return QuestionType.yesNo;
      case 'scale':
        return QuestionType.scale;
      case 'date':
        return QuestionType.date;
      default:
        return QuestionType.text;
    }
  }
}
