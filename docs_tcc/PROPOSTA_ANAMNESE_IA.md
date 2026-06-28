# Proposta: Sistema de Anamnese Inteligente com IA

## 📋 Visão Geral

Implementação de sistema de anamnese adaptativa com IA para geração dinâmica de perguntas e sugestão inteligente de treinos usando RAG (Retrieval-Augmented Generation).

## 🎯 Objetivos

1. **Anamnese Dinâmica**: Perguntas geradas em tempo real pela IA
2. **Análise Profunda**: IA analisa respostas e identifica padrões
3. **Sugestões Inteligentes**: RAG sugere treinos personalizados
4. **Validação Humana**: Personal sempre tem controle final

## 🏗️ Arquitetura Proposta

### Stack Adicional

```yaml
dependencies:
  google_generative_ai: ^0.4.0 # Google Gemini
  langchain_dart: ^0.7.0 # Framework RAG
  dio: ^5.4.0 # HTTP client
```

### Estrutura de Dados

#### 1. Modelo de Anamnese

```dart
class Anamnesis {
  final String id;
  final String studentId;
  final String personalId;
  final List<Question> questions;
  final List<Answer> answers;
  final AnamnesisStatus status; // inProgress, completed
  final AnamnesisInsights? insights;
  final DateTime createdAt;
  final DateTime? completedAt;
}

class Question {
  final String id;
  final String text;
  final QuestionType type; // text, multipleChoice, scale, yesNo
  final List<String>? options;
  final bool isDynamic; // false = base, true = gerada por IA
  final String? generatedReason; // Por que a IA gerou essa pergunta
}

class Answer {
  final String questionId;
  final dynamic value;
  final DateTime answeredAt;
}

enum QuestionType { text, multipleChoice, scale, yesNo }
enum AnamnesisStatus { draft, inProgress, completed, analyzed }
```

#### 2. Insights da IA

```dart
class AnamnesisInsights {
  final String summary; // Resumo geral
  final List<HealthCondition> conditions;
  final List<String> goals; // Objetivos do aluno
  final List<String> limitations; // Limitações físicas
  final FitnessLevel fitnessLevel;
  final double injuryRisk; // 0-1
  final Map<String, dynamic> recommendations;
}

class HealthCondition {
  final String name; // "Hipertensão", "Dor lombar"
  final ConditionSeverity severity;
  final List<String> restrictions; // Exercícios a evitar
}

enum FitnessLevel { sedentary, beginner, intermediate, advanced }
enum ConditionSeverity { mild, moderate, severe }
```

#### 3. Sugestão de Treino

```dart
class WorkoutSuggestion {
  final String id;
  final String anamnesisId;
  final String name;
  final List<ExerciseSuggestion> exercises;
  final String rationale; // Por que esse treino foi sugerido
  final List<String> precautions;
  final double confidence; // Confiança da IA (0-1)
  final bool approvedByPersonal;
}

class ExerciseSuggestion {
  final String exerciseId;
  final String exerciseName;
  final int series;
  final String reps;
  final String notes;
  final String reason; // Por que esse exercício foi sugerido
}
```

### Firestore Collections

```
/anamnesis/{anamnesisId}
  - id
  - studentId
  - personalId
  - questions (array)
  - answers (array)
  - status
  - createdAt
  - completedAt

/anamnesis/{anamnesisId}/insights/{insightId}
  - summary
  - conditions
  - goals
  - limitations
  - recommendations

/workoutSuggestions/{suggestionId}
  - anamnesisId
  - exercises
  - rationale
  - confidence
  - approvedByPersonal
```

## 🔄 Fluxo de Trabalho

### 1. Personal Cria Template (Opcional)

```
Personal → Define perguntas base
  - "Qual seu objetivo principal?"
  - "Possui alguma lesão ou dor?"
  - "Pratica atividade física? Qual frequência?"
```

### 2. Aluno Inicia Anamnese

```
Aluno → Responde pergunta base
  ↓
Sistema envia para IA:
  - Contexto: perguntas anteriores + respostas
  - Tarefa: "Gerar próxima pergunta relevante"
  ↓
IA decide:
  - Precisa de mais info? → Gera pergunta
  - Informação suficiente? → Finaliza
```

### 3. IA Analisa Anamnese Completa

```
Todas respostas → Enviadas para Gemini/GPT
  ↓
Prompt:
  "Analise esta anamnese e identifique:
   - Condições de saúde
   - Limitações físicas
   - Objetivos de treino
   - Nível de condicionamento
   - Risco de lesão"
  ↓
Retorna: AnamnesisInsights estruturado
```

### 4. RAG Sugere Treinos

```
Insights + Biblioteca de Exercícios → RAG
  ↓
Vector Search:
  - Busca exercícios compatíveis
  - Evita exercícios contraindicados
  ↓
LLM monta treino:
  - Seleciona exercícios
  - Define séries/repetições
  - Adiciona justificativas
  ↓
Retorna: WorkoutSuggestion[]
```

### 5. Personal Valida

```
Personal visualiza:
  - Insights da anamnese
  - Sugestões de treino
  - Justificativas da IA
  ↓
Personal pode:
  - Aprovar treino sugerido
  - Editar e ajustar
  - Rejeitar e criar do zero
```

## 💻 Exemplo de Código

### Service para IA (Gemini)

```dart
// lib/core/services/gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
    );
  }

  // Gera próxima pergunta dinâmica
  Future<Question?> generateNextQuestion({
    required List<Question> previousQuestions,
    required List<Answer> answers,
  }) async {
    final context = _buildContext(previousQuestions, answers);

    final prompt = '''
Você é um especialista em avaliação física e anamnese.
Analise as respostas do aluno e decida:

1. Se precisa de mais informações, gere UMA pergunta relevante
2. Se já tem informação suficiente, retorne "COMPLETE"

Contexto:
$context

Responda em JSON:
{
  "action": "ask" ou "complete",
  "question": {
    "text": "pergunta aqui",
    "type": "text|multipleChoice|yesNo",
    "options": ["opção1", "opção2"], // se multipleChoice
    "reason": "por que essa pergunta é importante"
  }
}
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    final json = _parseJson(response.text);

    if (json['action'] == 'complete') return null;

    return Question(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['question']['text'],
      type: _parseQuestionType(json['question']['type']),
      options: json['question']['options'],
      isDynamic: true,
      generatedReason: json['question']['reason'],
    );
  }

  // Analisa anamnese completa
  Future<AnamnesisInsights> analyzeAnamnesis({
    required List<Answer> answers,
    required List<Question> questions,
  }) async {
    final context = _buildContext(questions, answers);

    final prompt = '''
Analise esta anamnese e forneça insights:

$context

Retorne em JSON:
{
  "summary": "resumo geral do perfil",
  "conditions": [
    {
      "name": "condição de saúde",
      "severity": "mild|moderate|severe",
      "restrictions": ["exercícios a evitar"]
    }
  ],
  "goals": ["objetivo1", "objetivo2"],
  "limitations": ["limitação física 1"],
  "fitnessLevel": "sedentary|beginner|intermediate|advanced",
  "injuryRisk": 0.0-1.0,
  "recommendations": {
    "frequency": "3-4x por semana",
    "duration": "45-60min",
    "focus": "treino de força com baixo impacto"
  }
}
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return AnamnesisInsights.fromJson(_parseJson(response.text));
  }

  String _buildContext(List<Question> questions, List<Answer> answers) {
    // Constrói contexto formatado com perguntas e respostas
    return questions.map((q) {
      final answer = answers.firstWhere((a) => a.questionId == q.id);
      return 'P: ${q.text}\nR: ${answer.value}';
    }).join('\n\n');
  }
}
```

### Service para RAG

```dart
// lib/core/services/rag_workout_service.dart
class RAGWorkoutService {
  final GeminiService _gemini;
  final FirebaseExerciseService _exerciseService;

  Future<List<WorkoutSuggestion>> suggestWorkouts({
    required AnamnesisInsights insights,
  }) async {
    // 1. Busca exercícios disponíveis
    final allExercises = await _exerciseService.getAllExercises();

    // 2. Filtra exercícios contraindicados
    final safeExercises = _filterSafeExercises(
      exercises: allExercises,
      conditions: insights.conditions,
    );

    // 3. Prompt para IA sugerir treino
    final prompt = '''
Crie um treino personalizado baseado neste perfil:

PERFIL DO ALUNO:
${insights.summary}

OBJETIVOS:
${insights.goals.join(', ')}

LIMITAÇÕES:
${insights.limitations.join(', ')}

NÍVEL: ${insights.fitnessLevel}

EXERCÍCIOS DISPONÍVEIS:
${safeExercises.map((e) => '- ${e.name} (${e.category})').join('\n')}

Crie 2-3 opções de treino em JSON:
{
  "suggestions": [
    {
      "name": "Treino A",
      "exercises": [
        {
          "exerciseName": "nome do exercício",
          "series": 3,
          "reps": "12-15",
          "notes": "observações",
          "reason": "por que incluir esse exercício"
        }
      ],
      "rationale": "justificativa geral do treino",
      "precautions": ["cuidado 1", "cuidado 2"]
    }
  ]
}
''';

    final response = await _gemini._model.generateContent([Content.text(prompt)]);
    return _parseSuggestions(response.text, insights.id);
  }

  List<Exercise> _filterSafeExercises({
    required List<Exercise> exercises,
    required List<HealthCondition> conditions,
  }) {
    final restrictedExercises = conditions
        .expand((c) => c.restrictions)
        .toSet();

    return exercises.where((e) =>
      !restrictedExercises.contains(e.name.toLowerCase())
    ).toList();
  }
}
```

### Tela do Aluno Respondendo

```dart
// lib/features/anamnesis/presentation/screens/student_anamnesis_screen.dart
class StudentAnamnesisScreen extends ConsumerStatefulWidget {
  final String anamnesisId;

  @override
  _StudentAnamnesisScreenState createState() => _StudentAnamnesisScreenState();
}

class _StudentAnamnesisScreenState extends ConsumerState<StudentAnamnesisScreen> {
  int currentQuestionIndex = 0;
  final Map<String, dynamic> answers = {};
  bool isGeneratingNextQuestion = false;

  Future<void> _submitAnswer(dynamic answer) async {
    setState(() => isGeneratingNextQuestion = true);

    // Salva resposta
    await ref.read(anamnesisServiceProvider).saveAnswer(
      anamnesisId: widget.anamnesisId,
      questionId: currentQuestion.id,
      answer: answer,
    );

    // IA gera próxima pergunta
    final nextQuestion = await ref.read(geminiServiceProvider).generateNextQuestion(
      previousQuestions: questions,
      answers: allAnswers,
    );

    if (nextQuestion == null) {
      // Anamnese completa! Redireciona para análise
      await _completeAnamnesis();
    } else {
      setState(() {
        questions.add(nextQuestion);
        currentQuestionIndex++;
        isGeneratingNextQuestion = false;
      });
    }
  }

  Future<void> _completeAnamnesis() async {
    // Marca como completa
    await ref.read(anamnesisServiceProvider).complete(widget.anamnesisId);

    // IA analisa
    final insights = await ref.read(geminiServiceProvider).analyzeAnamnesis(
      questions: questions,
      answers: allAnswers,
    );

    // Salva insights
    await ref.read(anamnesisServiceProvider).saveInsights(
      anamnesisId: widget.anamnesisId,
      insights: insights,
    );

    // Navega para resultados
    context.go('/anamnesis/${widget.anamnesisId}/insights');
  }

  @override
  Widget build(BuildContext context) {
    if (isGeneratingNextQuestion) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('IA está analisando sua resposta...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Anamnese'),
        subtitle: Text('Pergunta ${currentQuestionIndex + 1}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
            ),
            SizedBox(height: 24),

            Text(
              currentQuestion.text,
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            if (currentQuestion.isDynamic) ...[
              SizedBox(height: 8),
              Chip(
                label: Text('Pergunta gerada pela IA'),
                backgroundColor: Colors.blue.shade100,
              ),
            ],

            SizedBox(height: 24),

            // Widget de resposta (depende do tipo)
            _buildAnswerWidget(currentQuestion),
          ],
        ),
      ),
    );
  }
}
```

## 💰 Custos Estimados

### API Gemini (Google)

- **Modelo**: gemini-1.5-pro
- **Custo**: ~$0.00025 por requisição (1000 tokens)
- **Estimativa**:
  - Anamnese completa: 10 perguntas = ~$0.0025
  - Análise: ~$0.001
  - Sugestão de treino: ~$0.002
  - **Total por aluno: ~$0.01** (muito baixo!)

### Alternativas

- **Gemini Flash**: Mais barato, menos sofisticado
- **Claude** (Anthropic): Melhor raciocínio, mais caro
- **GPT-4**: Mais conhecido, custo médio

## 📊 Fases de Implementação

### Fase 1: MVP (2-3 semanas)

- [ ] Modelo de dados (Anamnesis, Question, Answer)
- [ ] Firestore collections e security rules
- [ ] Tela de criação de template (Personal)
- [ ] Tela de resposta estática (Aluno)
- [ ] Visualização de respostas (Personal)

### Fase 2: IA Básica (1-2 semanas)

- [ ] Integração Gemini API
- [ ] Análise automática da anamnese
- [ ] Exibição de insights

### Fase 3: Perguntas Dinâmicas (2 semanas)

- [ ] IA gera próxima pergunta em tempo real
- [ ] Lógica de decisão para completude
- [ ] UX de "aguarde enquanto IA analisa"

### Fase 4: RAG e Sugestões (3-4 semanas)

- [ ] Vector database setup (Pinecone ou Firestore)
- [ ] Indexação de exercícios
- [ ] RAG service
- [ ] Tela de sugestões de treino
- [ ] Fluxo de aprovação do Personal

## 🎓 Diferenciais Competitivos

1. **Personalização Real**: Não é formulário genérico
2. **Adaptativo**: IA ajusta perguntas ao perfil
3. **Baseado em Evidências**: RAG usa biblioteca real de exercícios
4. **Validação Profissional**: Personal sempre controla
5. **Escalável**: IA permite atender mais alunos com qualidade

## ⚠️ Considerações

### Privacidade

- Dados sensíveis de saúde (LGPD/HIPAA)
- Consentimento explícito do aluno
- Criptografia em trânsito e repouso

### Responsabilidade

- IA sugere, Personal decide (sempre)
- Disclaimers sobre limitações da IA
- Não substitui avaliação médica

### Performance

- Chamadas de API podem demorar (2-5s)
- Feedback visual importante ("IA pensando...")
- Cache de perguntas frequentes

## 🚀 Próximos Passos

1. **Validar proposta** com você
2. **Escolher modelo de IA** (Gemini recomendado)
3. **Criar API key** e configurar
4. **Implementar Fase 1** (MVP sem IA)
5. **Testar com usuários reais**
6. **Iterar e refinar**

---

**Esta proposta transforma o New Gym App de um sistema de gestão em uma plataforma de inteligência fitness!**
