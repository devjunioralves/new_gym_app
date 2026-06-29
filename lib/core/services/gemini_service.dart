import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:new_gym_app/core/models/anamnesis_insights_model.dart';
import 'package:new_gym_app/core/models/anamnesis_model.dart';

class GeminiService {
  late final GenerativeModel _model;
  final String apiKey;

  GeminiService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-3.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
      ),
    );
  }

  /// Chamada única após todas as perguntas base: gera 3–5 perguntas
  /// diagnósticas personalizadas baseadas no conjunto de respostas.
  Future<List<AnamnesisQuestion>> generateDiagnosticBatch({
    required List<AnamnesisQuestion> coreQuestions,
    required List<AnamnesisAnswer> coreAnswers,
  }) async {
    final context = _buildQAContext(coreQuestions, coreAnswers);

    final prompt = '''
Você é um profissional de educação física experiente realizando uma avaliação inicial.
Acabou de receber as respostas essenciais abaixo de um novo aluno.

RESPOSTAS DO ALUNO:
$context

TAREFA:
Gere entre 3 e 5 perguntas de aprofundamento diagnóstico, altamente personalizadas para ESTE aluno.
O objetivo é construir um diagnóstico clínico-funcional que oriente a prescrição de exercício.

DIRETRIZES:
- Analise TODAS as respostas em conjunto antes de formular as perguntas
- A anamnese já cobre: identificação, objetivo, histórico de treino, estilo de vida, saúde clínica, tabagismo, álcool, cirurgias, sintomas durante esforço, saúde mental — e perguntas específicas por sexo biológico
- Priorize aprofundamento em áreas de risco clínico que ficaram vagas: condições de saúde sem detalhes, lesões sem histórico, respostas positivas em triagem de segurança (dor no peito, tontura)
- Aprofunde pontos específicos: se disse "tenho dor no joelho", pergunte intensidade, o que piora, se já fez fisioterapia
- Considere o objetivo e nível: sedentário → barreiras e rotina; avançado → periodização e histórico específico
- Se fumante ou ex-fumante: investigue capacidade cardiorrespiratória atual
- Se relatou problemas de saúde mental: pergunte se isso impacta disposição para treinar e se há restrições do psiquiatra
- Se usou ou usa hormônios exógenos (qm2): investigue há quanto tempo, exames recentes
- As perguntas devem soar naturais e humanas, não como um formulário burocrático
- NÃO repita o que já foi perguntado

Responda APENAS com JSON válido:
{
  "questions": [
    {
      "text": "pergunta personalizada e direta",
      "type": "text" | "multipleChoice" | "yesNo" | "scale",
      "options": ["opção 1", "opção 2"],
      "reason": "justificativa clínica para esta pergunta"
    }
  ]
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final jsonText = _extractJson(response.text ?? '');
      final json = jsonDecode(jsonText) as Map<String, dynamic>;

      final questionsData = json['questions'] as List<dynamic>? ?? [];
      final baseOrder = coreQuestions.length;

      return questionsData.asMap().entries.map((entry) {
        final i = entry.key;
        final q = entry.value as Map<String, dynamic>;
        return AnamnesisQuestion(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i',
          text: q['text'] as String,
          type: _parseQuestionType(q['type'] as String? ?? 'text'),
          options: (q['options'] as List<dynamic>?)?.cast<String>(),
          isRequired: true,
          isDynamic: true,
          generatedReason: q['reason'] as String?,
          order: baseOrder + i,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Analisa a anamnese completa e gera insights
  Future<AnamnesisInsights> analyzeAnamnesis({
    required String anamnesisId,
    required List<AnamnesisQuestion> questions,
    required List<AnamnesisAnswer> answers,
  }) async {
    final context = _buildQAContext(questions, answers);

    final prompt = '''
Você é um especialista em fisiologia do exercício e prescrição de treino.

Analise esta anamnese e forneça insights baseados em evidências científicas.

ANAMNESE:
$context

Responda APENAS com JSON válido:
{
  "summary": "resumo em 2-3 frases do perfil geral",
  "conditions": [
    {
      "name": "nome da condição",
      "severity": "mild" | "moderate" | "severe",
      "restrictions": ["exercício a evitar"],
      "notes": "observações"
    }
  ],
  "goals": ["objetivo 1"],
  "limitations": ["limitação física 1"],
  "fitnessLevel": "sedentary" | "beginner" | "intermediate" | "advanced",
  "injuryRisk": 0.0,
  "recommendations": {
    "frequency": "frequência semanal",
    "duration": "duração das sessões",
    "focus": "foco principal",
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

  String _buildQAContext(
    List<AnamnesisQuestion> questions,
    List<AnamnesisAnswer> answers,
  ) {
    final now = DateTime.now();
    final buffer = StringBuffer();
    buffer.writeln('DATA DE HOJE: ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}');
    buffer.writeln();

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
      final formatted = _formatAnswer(answer.value);
      buffer.write('R: $formatted');

      // Se for uma data de nascimento, calcula e anexa a idade
      if (question.type == QuestionType.date && formatted != 'Não respondida') {
        final age = _calcularIdade(formatted, now);
        if (age != null) buffer.write(' (idade: $age anos)');
      }
      buffer.writeln();
      buffer.writeln();
    }
    return buffer.toString();
  }

  int? _calcularIdade(String dataNascimento, DateTime hoje) {
    try {
      final partes = dataNascimento.split('/');
      if (partes.length != 3) return null;
      final nascimento = DateTime(
        int.parse(partes[2]),
        int.parse(partes[1]),
        int.parse(partes[0]),
      );
      int idade = hoje.year - nascimento.year;
      if (hoje.month < nascimento.month ||
          (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
        idade--;
      }
      return idade;
    } catch (_) {
      return null;
    }
  }

  String _formatAnswer(dynamic value) {
    if (value is List) return value.join(', ');
    if (value is DateTime) return value.toString().split(' ')[0];
    return value.toString();
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
