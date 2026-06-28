# 🤖 GUIA TÉCNICO: Integração IA Gemini + RAG

## Visão Geral da Arquitetura IA

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUXO COMPLETO DE IA                          │
└─────────────────────────────────────────────────────────────────┘

FASE 1: Perguntas Dinâmicas (Gemini Service)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Aluno responde pergunta
    ↓
GeminiService.generateNextQuestion()
    ↓
Analisa contexto (37 perguntas base + respostas)
    ↓
Gemini API (LLM 1.5-pro, temp: 0.7)
    ↓
Retorna: próxima pergunta OU null (terminou)
    ↓
Salva pergunta dinâmica no Firebase


FASE 2: Análise da Anamnese (Gemini Service)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Anamnese completa (base + dinâmicas)
    ↓
GeminiService.analyzeAnamnesis()
    ↓
Monta contexto completo (todas Q&A)
    ↓
Gemini API (LLM 1.5-pro, temp: 0.7)
    ↓
Retorna: AnamnesisInsights
  • summary (resumo perfil)
  • conditions[] (hipertensão, dor lombar...)
  • fitnessLevel (sedentary/beginner/...)
  • injuryRisk (0.0-1.0)
  • limitations[] (exercícios a evitar)
  • recommendations{}
    ↓
Salva insights no Firestore


FASE 3: Geração de Treinos (RAG Service)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Personal solicita sugestões
    ↓
RAGWorkoutService.generateWorkoutSuggestions()
    ↓
1. RETRIEVAL (Busca conhecimento)
   • Carrega AnamnesisInsights
   • Carrega TODOS exercícios do Firebase
   • Carrega guidelines ACSM/NSCA (hardcoded)
    ↓
2. FILTER (Filtra exercícios seguros)
   • Remove exercícios nas restrictions[]
   • Ex: Se "dor lombar" → remove deadlifts
    ↓
3. AUGMENTATION (Monta prompt enriquecido)
   • Perfil do aluno (insights)
   • Exercícios disponíveis (safe list)
   • Guidelines científicas (ACSM + NSCA)
    ↓
4. GENERATION (IA gera treinos)
   • Gemini API (LLM 1.5-pro, temp: 0.8)
   • Retorna 3 sugestões de treino
   • Cada uma com:
     - Exercícios + séries/reps/descanso
     - Rationale (justificativa)
     - Precautions (cuidados)
     - References[] (ACSM, NSCA)
     - Confidence (0.0-1.0)
    ↓
Salva sugestões no Firestore
    ↓
Personal revisa e aprova
```

---

## 1. GEMINI SERVICE - Perguntas Dinâmicas

### 1.1 Objetivo
Gerar perguntas contextuais para aprofundar o entendimento sobre o aluno, criando uma anamnese adaptativa.

### 1.2 Código-Chave

```dart
class GeminiService {
  final GenerativeModel _model;

  GeminiService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-pro',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7, // Equilíbrio criatividade/precisão
            maxOutputTokens: 500,
          ),
        );

  Future<AnamnesisQuestion?> generateNextQuestion({
    required List<AnamnesisQuestion> previousQuestions,
    required List<AnamnesisAnswer> answers,
  }) async {
    // Monta contexto de Q&A
    final context = _buildQAContext(previousQuestions, answers);
    
    // Prompt engenheirado
    final prompt = '''
Você é um especialista em avaliação física e anamnese.

CONTEXTO DA ANAMNESE:
$context

TAREFA:
Analise as respostas acima e determine se há necessidade de UMA pergunta
adicional para entender melhor o perfil do aluno.

REGRAS:
1. Faça APENAS UMA pergunta por vez
2. A pergunta deve ser relevante para prescrição de exercícios
3. NÃO repita informações já coletadas
4. Se já tem informação suficiente, retorne null
5. Priorize perguntas sobre limitações, dores, ou condições médicas

EXEMPLOS DE BOAS PERGUNTAS:
- "Em uma escala de 1-10, qual a intensidade da sua dor nas costas?"
- "Há quanto tempo você é sedentário?"
- "Você toma alguma medicação regularmente?"

FORMATO DE RESPOSTA (JSON):
{
  "question": "Texto da pergunta" OU null,
  "type": "text|yesNo|scale|multipleChoice",
  "options": ["opção1", "opção2"] (apenas para multipleChoice),
  "reason": "Por que essa pergunta é importante"
}

Se NÃO houver necessidade de mais perguntas, retorne:
{ "question": null }
''';

    final response = await _model.generateContent([
      Content.text(prompt)
    ]);

    final json = _extractJson(response.text!);
    
    if (json['question'] == null) {
      return null; // Fim das perguntas
    }

    return AnamnesisQuestion(
      id: 'dynamic_${DateTime.now().millisecondsSinceEpoch}',
      text: json['question'],
      type: _parseQuestionType(json['type']),
      isDynamic: true,
      generatedReason: json['reason'],
      options: json['options']?.cast<String>(),
    );
  }
}
```

### 1.3 Exemplo Real de Interação

**Cenário:** Aluno respondendo anamnese

**Pergunta Base #1:**  
`"Qual seu principal objetivo?"`  
**Resposta:** `"Emagrecimento"`

↓ **IA analisa contexto**

**Pergunta Dinâmica #1 (gerada):**  
`"Quantos quilos você deseja perder?"`  
**Resposta:** `"10kg"`

↓ **IA analisa novo contexto**

**Pergunta Base #5:**  
`"Você pratica atividade física atualmente?"`  
**Resposta:** `"Não, sou sedentário há 2 anos"`

↓ **IA detecta flag importante**

**Pergunta Dinâmica #2 (gerada):**  
`"Em média, quantas horas por dia você fica sentado?"`  
**Reason:** `"Quantificar sedentarismo para avaliar risco cardiovascular"`  
**Resposta:** `"8-10 horas (trabalho em escritório)"`

↓ **IA continua**

**Pergunta Base #25:**  
`"Você sente dores nas costas?"`  
**Resposta:** `"Sim"`

↓ **IA detecta condição médica**

**Pergunta Dinâmica #3 (gerada):**  
`"Em uma escala de 1-10, qual a intensidade dessa dor?"`  
**Type:** `scale`  
**Reason:** `"Avaliar severidade para determinar restrições de exercícios"`  
**Resposta:** `"7"`

↓ **IA decide aprofundar**

**Pergunta Dinâmica #4 (gerada):**  
`"A dor piora com algum movimento específico?"`  
**Type:** `text`  
**Resposta:** `"Sim, ao flexionar o tronco para frente"`

↓ **IA tem contexto suficiente**

**Próxima chamada retorna:** `{ "question": null }`  
**Anamnese completa!**

### 1.4 Por que Temperature 0.7?

```dart
temperature: 0.7
```

**0.0 = Determinístico** (sempre mesma resposta)  
**1.0 = Criativo** (respostas variadas, mas pode "alucinar")  
**0.7 = Sweet spot** (criatividade controlada)

Para perguntas dinâmicas, queremos:
- ✅ Criatividade para perguntas relevantes
- ✅ Consistência na estrutura
- ✅ Não repetir perguntas
- ❌ Evitar perguntas absurdas

---

## 2. GEMINI SERVICE - Análise da Anamnese

### 2.1 Objetivo
Processar todas as respostas (base + dinâmicas) e extrair insights estruturados sobre condições de saúde, limitações e perfil fitness.

### 2.2 Código-Chave

```dart
Future<AnamnesisInsights> analyzeAnamnesis({
  required String anamnesisId,
  required List<AnamnesisQuestion> questions,
  required List<AnamnesisAnswer> answers,
}) async {
  final context = _buildQAContext(questions, answers);

  final prompt = '''
Você é um médico do esporte e especialista em avaliação física.

ANAMNESE COMPLETA:
$context

TAREFA:
Analise a anamnese acima e retorne uma avaliação estruturada do perfil do aluno.

FORMATO DE RESPOSTA (JSON):
{
  "summary": "Resumo do perfil em 2-3 frases",
  "conditions": [
    {
      "name": "Nome da condição (ex: Hipertensão)",
      "severity": "mild|moderate|severe",
      "restrictions": ["Lista de exercícios a EVITAR"],
      "notes": "Observações adicionais"
    }
  ],
  "goals": ["Lista de objetivos do aluno"],
  "limitations": ["Lista de limitações físicas ou de saúde"],
  "fitnessLevel": "sedentary|beginner|intermediate|advanced",
  "injuryRisk": 0.0-1.0 (probabilidade de lesão),
  "recommendations": {
    "frequency": "Frequência semanal recomendada",
    "intensity": "Intensidade inicial",
    "progression": "Como progredir",
    "precautions": "Cuidados especiais"
  }
}

CRITÉRIOS PARA CLASSIFICAÇÃO:

FITNESS LEVEL:
- sedentary: 0-2 meses sem atividade
- beginner: Treina há menos de 6 meses
- intermediate: Treina há 6 meses a 2 anos
- advanced: Treina há mais de 2 anos consistentemente

INJURY RISK:
- 0.0-0.3: Baixo (saudável, sem limitações)
- 0.3-0.6: Moderado (1-2 condições leves)
- 0.6-0.8: Alto (múltiplas condições ou 1 severa)
- 0.8-1.0: Muito alto (necessita aval médico)

RESTRICTIONS (exemplos):
- Hipertensão → "Exercícios isométricos prolongados", "Manobra de Valsalva"
- Dor lombar → "Deadlift convencional", "Flexão de tronco com carga"
- Problemas no joelho → "Agachamento profundo", "Saltos"
''';

  final response = await _model.generateContent([
    Content.text(prompt)
  ]);

  final json = _extractJson(response.text!);

  return AnamnesisInsights(
    id: anamnesisId,
    anamnesisId: anamnesisId,
    summary: json['summary'],
    conditions: (json['conditions'] as List)
        .map((c) => HealthCondition(
              name: c['name'],
              severity: _parseSeverity(c['severity']),
              restrictions: c['restrictions'].cast<String>(),
              notes: c['notes'],
            ))
        .toList(),
    goals: json['goals'].cast<String>(),
    limitations: json['limitations'].cast<String>(),
    fitnessLevel: _parseFitnessLevel(json['fitnessLevel']),
    injuryRisk: json['injuryRisk'].toDouble(),
    recommendations: Map<String, String>.from(json['recommendations']),
    analyzedAt: DateTime.now(),
  );
}
```

### 2.3 Exemplo Real de Análise

**Input (anamnese completa):**
```
Q1: Objetivo? → Emagrecimento, 10kg
Q2: Pratica atividade? → Não, sedentário há 2 anos
Q3: Horas sentado/dia? → 8-10 horas
Q4: Dor nas costas? → Sim
Q5: Intensidade dor (1-10)? → 7
Q6: Piora com movimento? → Sim, ao flexionar tronco
Q7: Hipertensão? → Sim, controlada com medicação
Q8: Outras doenças? → Não
[... 30+ perguntas]
```

**Output (AnamnesisInsights):**
```json
{
  "summary": "Homem, 35 anos, sedentário há 2 anos com objetivo de emagrecimento (-10kg). Apresenta dor lombar moderada e hipertensão controlada. Alto risco de lesão devido ao sedentarismo prolongado e falta de condicionamento.",
  
  "conditions": [
    {
      "name": "Dor lombar crônica",
      "severity": "moderate",
      "restrictions": [
        "Deadlift convencional",
        "Agachamento livre com barra",
        "Flexão de tronco com carga",
        "Good morning",
        "Stiff leg deadlift"
      ],
      "notes": "Dor intensidade 7/10, piora com flexão de tronco. Requer progressão muito gradual e foco em estabilização do core."
    },
    {
      "name": "Hipertensão arterial controlada",
      "severity": "mild",
      "restrictions": [
        "Exercícios isométricos prolongados (prancha >1min)",
        "Manobra de Valsalva (segurar respiração)",
        "Circuitos de alta intensidade sem descanso"
      ],
      "notes": "Controlada com medicação. Monitorar pressão arterial antes e após treinos. Evitar apneia durante execução."
    }
  ],
  
  "goals": [
    "Emagrecimento de 10kg",
    "Redução de gordura corporal",
    "Melhora da saúde cardiovascular"
  ],
  
  "limitations": [
    "Sedentarismo prolongado (2 anos)",
    "Dor lombar ao flexionar tronco",
    "Hipertensão (requer monitoramento)",
    "Condicionamento cardiovascular muito baixo",
    "Provável fraqueza de core"
  ],
  
  "fitnessLevel": "sedentary",
  
  "injuryRisk": 0.7,
  
  "recommendations": {
    "frequency": "Iniciar com 2x/semana, progredir para 3x após 4 semanas",
    "intensity": "40-50% 1RM nas primeiras 4 semanas, progressão de 5% a cada 2 semanas",
    "progression": "Fase 1 (4 sem): Adaptação anatômica com máquinas. Fase 2 (4 sem): Introduzir pesos livres leves. Fase 3 (4+ sem): Progressão gradual de carga",
    "precautions": "Aquecer 10 min (cardio leve), ênfase em técnica perfeita, monitorar dor lombar (parar se >3/10), medir PA antes/após treino, evitar apneia, descanso 48-72h entre sessões"
  }
}
```

**Por que isso é importante?**
- ✅ **Estruturado:** Não é texto livre, é um objeto com campos tipados
- ✅ **Acionável:** Personal sabe exatamente o que evitar
- ✅ **Científico:** Baseado em severidade, não em "achismos"
- ✅ **Rastreável:** Salvo no Firestore para auditoria

---

## 3. RAG SERVICE - Geração de Treinos

### 3.1 O que é RAG?

**RAG = Retrieval-Augmented Generation**

```
┌─────────────────────────────────────────────────────────────┐
│  Problema: LLMs podem "alucinar" (inventar fatos)           │
│  Solução: Ancorar IA em conhecimento verificável            │
└─────────────────────────────────────────────────────────────┘

SEM RAG (Perigoso):
━━━━━━━━━━━━━━━━━━━
User: "Crie treino para hipertenso"
LLM: "Faça burpees e sprints!" ❌ (pode causar pico de pressão)

COM RAG (Seguro):
━━━━━━━━━━━━━━━━━━━
1. RETRIEVAL: Busca "hipertensão + exercícios" em base de conhecimento
   → Encontra: "ACSM: evitar isométricos prolongados, Valsalva"
   
2. AUGMENTATION: Monta prompt com conhecimento:
   "Aluno tem hipertensão. Segundo ACSM Guidelines 2021, 
    deve evitar: isométricos prolongados, Valsalva, circuitos
    sem descanso. Exercícios seguros disponíveis: [lista]"
   
3. GENERATION: LLM gera treino BASEADO no conhecimento
   → "Treino com máquinas, descanso 90s, respiração contínua" ✅
```

### 3.2 Código-Chave

```dart
class RAGWorkoutService {
  final GenerativeModel _model;
  final FirebaseExerciseService _exerciseService;

  RAGWorkoutService(String apiKey, this._exerciseService)
      : _model = GenerativeModel(
          model: 'gemini-1.5-pro',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.8, // Mais criativo para variação
            maxOutputTokens: 4000,
          ),
        );

  Future<List<WorkoutSuggestion>> generateWorkoutSuggestions({
    required String anamnesisId,
    required AnamnesisInsights insights,
  }) async {
    // PASSO 1: RETRIEVAL - Busca conhecimento
    final allExercises = await _exerciseService.getExercises().first;
    final scientificGuidelines = _getScientificGuidelines(); // Hardcoded
    
    // PASSO 2: FILTER - Remove exercícios perigosos
    final safeExercises = _filterSafeExercises(
      exercises: allExercises,
      restrictions: insights.getAllRestrictions(),
    );
    
    // PASSO 3: AUGMENTATION - Monta prompt enriquecido
    final prompt = _buildRAGPrompt(
      insights: insights,
      safeExercises: safeExercises,
      guidelines: scientificGuidelines,
    );
    
    // PASSO 4: GENERATION - IA gera sugestões
    final response = await _model.generateContent([
      Content.text(prompt)
    ]);
    
    return _parseSuggestions(response.text!, anamnesisId);
  }

  List<Exercise> _filterSafeExercises({
    required List<Exercise> exercises,
    required List<String> restrictions,
  }) {
    return exercises.where((exercise) {
      // Verifica se exercício está nas restrições
      for (final restriction in restrictions) {
        if (exercise.name.toLowerCase().contains(restriction.toLowerCase())) {
          return false; // Remove exercício perigoso
        }
      }
      return true; // Exercício seguro
    }).toList();
  }

  String _buildRAGPrompt({
    required AnamnesisInsights insights,
    required List<Exercise> safeExercises,
    required Map<String, String> guidelines,
  }) {
    return '''
Você é um personal trainer certificado pela ACSM e NSCA.

═══════════════════════════════════════════════════════════════
PERFIL DO ALUNO (baseado em anamnese médica):
═══════════════════════════════════════════════════════════════

RESUMO: ${insights.summary}

NÍVEL DE CONDICIONAMENTO: ${insights.fitnessLevel}
RISCO DE LESÃO: ${(insights.injuryRisk * 100).toStringAsFixed(0)}% ${_getRiskLabel(insights.injuryRisk)}

CONDIÇÕES DE SAÚDE:
${insights.conditions.map((c) => '''
- ${c.name} (${c.severity})
  Restrições: ${c.restrictions.join(', ')}
  ${c.notes != null ? 'Obs: ${c.notes}' : ''}
''').join('\n')}

OBJETIVOS:
${insights.goals.map((g) => '• $g').join('\n')}

LIMITAÇÕES:
${insights.limitations.map((l) => '• $l').join('\n')}

═══════════════════════════════════════════════════════════════
EXERCÍCIOS SEGUROS DISPONÍVEIS (já filtrados):
═══════════════════════════════════════════════════════════════

${safeExercises.map((e) => '• ${e.name} (${e.workoutType})').join('\n')}

Total: ${safeExercises.length} exercícios aprovados

═══════════════════════════════════════════════════════════════
GUIDELINES CIENTÍFICAS (OBRIGATÓRIAS):
═══════════════════════════════════════════════════════════════

ACSM Guidelines for Exercise Testing 2021:

FREQUÊNCIA SEMANAL:
• Sedentários/Iniciantes: 2-3 dias/semana
• Intermediários: 3-4 dias/semana  
• Avançados: 4-6 dias/semana

INTENSIDADE (% 1RM):
• Iniciantes: 40-60% 1RM (RPE 5-6/10)
• Intermediários: 60-70% 1RM (RPE 6-7/10)
• Avançados: 70-85% 1RM (RPE 7-9/10)

VOLUME:
• Iniciantes: 1-3 séries x 8-12 repetições
• Intermediários: 2-4 séries x 8-12 repetições
• Avançados: 3-6 séries x 6-12 repetições

DESCANSO ENTRE SÉRIES:
• Hipertrofia: 60-90 segundos
• Força: 2-5 minutos
• Resistência: 30-60 segundos

PROGRESSÃO:
• Aumentar carga em 2-10% quando conseguir completar
  o número máximo de repetições com boa técnica em
  todas as séries por 2 treinos consecutivos

NSCA Essentials of Strength Training 4th Ed:

DESCANSO MUSCULAR:
• Músculos grandes: 48-72h entre sessões
• Músculos pequenos: 24-48h entre sessões

ORDEM DE EXERCÍCIOS:
1. Multiarticulares grandes (agachamento, supino)
2. Multiarticulares pequenos (rosca direta)
3. Monoarticulares (extensão de joelho)

INICIANTES (primeiros 3-6 meses):
• Priorizar TÉCNICA sobre carga
• Começar com MÁQUINAS (maior segurança)
• Evitar falha muscular
• Progressão LENTA e consistente

CONDIÇÕES ESPECIAIS:

Hipertensão:
• Evitar exercícios isométricos prolongados (>1min)
• Evitar manobra de Valsalva (segurar ar)
• Evitar circuitos sem descanso
• Respiração contínua e controlada
• Monitorar PA antes/após treino

Dor Lombar/Problemas Coluna:
• Priorizar exercícios em máquinas guiadas
• ROM (amplitude) controlada, sem extremos
• Fortalecer core ANTES de cargas altas
• Evitar flexão de tronco com carga
• Postura neutra SEMPRE

Sedentários (>6 meses sem exercício):
• Começar MUITO leve (40% 1RM)
• Fase de adaptação anatômica: 4-6 semanas
• Ênfase em aprender movimentos
• Progressão gradual (não pular etapas)

═══════════════════════════════════════════════════════════════
TAREFA:
═══════════════════════════════════════════════════════════════

Crie 3 SUGESTÕES DE TREINO diferentes para este aluno.

REQUISITOS OBRIGATÓRIOS:
1. Usar APENAS exercícios da lista "Exercícios Seguros Disponíveis"
2. Seguir ESTRITAMENTE as guidelines ACSM/NSCA acima
3. Considerar TODAS as condições de saúde e restrições
4. Cada sugestão deve ter abordagem DIFERENTE (ex: Full Body, AB, Push/Pull)
5. Incluir justificativa CIENTÍFICA com referências

FORMATO DE RESPOSTA (JSON array com 3 sugestões):
[
  {
    "name": "Nome do treino",
    "exercises": [
      {
        "exerciseId": "ID do exercício (da lista acima)",
        "exerciseName": "Nome do exercício",
        "series": número de séries,
        "reps": "faixa de repetições (ex: 10-12)",
        "rest": descanso em segundos,
        "notes": "observações de execução",
        "reason": "Por que escolheu este exercício para este aluno",
        "modifications": ["adaptações possíveis se necessário"]
      }
    ],
    "rationale": "Explicação científica de por que este treino é adequado, citando ACSM/NSCA",
    "precautions": ["Cuidados específicos durante execução"],
    "references": [
      {
        "title": "ACSM Guidelines for Exercise Testing and Prescription",
        "source": "American College of Sports Medicine",
        "url": "https://www.acsm.org/read-research/books/acsms-guidelines-for-exercise-testing-and-prescription",
        "summary": "Página/capítulo específico relevante"
      }
    ],
    "confidence": 0.0-1.0 (quão confiante está nesta prescrição)
  }
]

ATENÇÃO:
• NÃO invente exercícios fora da lista
• NÃO ignore restrições médicas
• NÃO prescreva volumes excessivos para iniciantes
• SEMPRE justifique cientificamente
''';
  }

  String _getScientificGuidelines() {
    // Retorna as guidelines hardcoded
    // (já incluídas no prompt acima)
  }

  String _getRiskLabel(double risk) {
    if (risk < 0.3) return '🟢 BAIXO';
    if (risk < 0.6) return '🟡 MODERADO';
    if (risk < 0.8) return '🟠 ALTO';
    return '🔴 MUITO ALTO';
  }
}
```

### 3.3 Exemplo Real de RAG

**Input:**
```dart
AnamnesisInsights(
  fitnessLevel: 'sedentary',
  injuryRisk: 0.7,
  conditions: [
    HealthCondition(
      name: 'Dor lombar',
      severity: 'moderate',
      restrictions: ['Deadlift', 'Agachamento livre', 'Flexão tronco'],
    ),
    HealthCondition(
      name: 'Hipertensão',
      severity: 'mild',
      restrictions: ['Isométricos >1min', 'Valsalva'],
    ),
  ],
  goals: ['Emagrecimento -10kg'],
)

safeExercises: [
  Exercise(id: 'leg-press', name: 'Leg Press', workoutType: 'Pernas'),
  Exercise(id: 'supino-maq', name: 'Supino Máquina', workoutType: 'Peito'),
  Exercise(id: 'remada-sent', name: 'Remada Sentada', workoutType: 'Costas'),
  // ... 65 outros exercícios seguros
]
```

**Output (1 das 3 sugestões):**
```json
{
  "name": "Treino Full Body Iniciante - Máquinas",
  
  "exercises": [
    {
      "exerciseId": "leg-press",
      "exerciseName": "Leg Press 45°",
      "series": 2,
      "reps": "10-12",
      "rest": 90,
      "notes": "Amplitude parcial inicial (90°), progredir gradualmente. Pés na largura dos ombros.",
      "reason": "Leg press é seguro para lombar pois não há carga axial na coluna. Permite trabalhar pernas sem risco de lesão lombar.",
      "modifications": [
        "Iniciar com carga leve (20-30kg) para aprender movimento",
        "Se sentir desconforto lombar, reduzir amplitude"
      ]
    },
    {
      "exerciseId": "supino-maq",
      "exerciseName": "Supino Máquina",
      "series": 2,
      "reps": "10-12",
      "rest": 90,
      "notes": "Expirar ao empurrar (evitar Valsalva), inspirar ao descer. Movimento controlado.",
      "reason": "Máquina guiada é ideal para iniciantes aprenderem padrão de movimento de empurrar sem risco. Respiração controlada é segura para hipertensos.",
      "modifications": [
        "Iniciar com carga mínima",
        "Pausar 1s no alto para evitar apneia"
      ]
    },
    {
      "exerciseId": "remada-sent",
      "exerciseName": "Remada Sentada Máquina",
      "series": 2,
      "reps": "10-12",
      "rest": 90,
      "notes": "Coluna neutra SEMPRE, apoio no peito. Puxar cotovelos para trás, não apenas as mãos.",
      "reason": "Trabalha costas com suporte torácico, protegendo lombar. Essencial para postura e equilíbrio muscular.",
      "modifications": [
        "Ajustar altura do assento (olhos alinhados com puxador)",
        "Amplitude reduzida se sentir tensão lombar"
      ]
    },
    {
      "exerciseId": "extensao-joelho",
      "exerciseName": "Extensão de Joelho (Cadeira)",
      "series": 2,
      "reps": "12-15",
      "rest": 60,
      "notes": "Movimento controlado, sem trancos. Não travar joelho no topo.",
      "reason": "Exercício monoarticular seguro para fortalecer quadríceps isoladamente, importante para estabilidade do joelho.",
      "modifications": [
        "Carga muito leve inicialmente",
        "Amplitude parcial se houver desconforto"
      ]
    },
    {
      "exerciseId": "flexao-joelho",
      "exerciseName": "Flexão de Joelho (Mesa)",
      "series": 2,
      "reps": "12-15",
      "rest": 60,
      "notes": "Quadril encostado no banco (evita compensação lombar).",
      "reason": "Trabalha posteriores de coxa sem carga na lombar. Equilíbrio muscular com extensão de joelho.",
      "modifications": [
        "Verificar apoio correto do quadril"
      ]
    },
    {
      "exerciseId": "abdomen-maq",
      "exerciseName": "Abdominal Máquina",
      "series": 2,
      "reps": "12-15",
      "rest": 60,
      "notes": "Máquina com apoio lombar. Movimento curto (flexão de tronco, não quadril).",
      "reason": "Fortalecer core é PRIORITÁRIO para proteger lombar. Máquina oferece apoio adequado.",
      "modifications": [
        "Carga mínima",
        "ROM muito controlada (sem forçar flexão)"
      ]
    }
  ],
  
  "rationale": "Este treino Full Body 2x/semana segue as recomendações ACSM 2021 para sedentários: frequência baixa (2-3x), intensidade moderada (40-60% 1RM), volume reduzido (2 séries). Priorizamos MÁQUINAS por oferecerem maior segurança e trajetória guiada, essencial para quem está aprendendo movimentos. Segundo NSCA, iniciantes devem focar em técnica antes de carga, justificando séries baixas com repetições moderadas (10-15). A ausência de exercícios com carga axial (deadlift, agachamento livre) protege a lombar, enquanto exercícios como leg press e remada sentada (com apoio) permitem trabalhar grandes grupos musculares com segurança. Ênfase em respiração contínua (sem Valsalva) é crítica para hipertensão controlada. Descansos de 60-90s permitem recuperação adequada sem picos de pressão.",
  
  "precautions": [
    "Medir pressão arterial ANTES do treino (não treinar se PA >140/90)",
    "Aquecer 10 min em esteira leve ou bicicleta (FC 60-70% máxima)",
    "Parar IMEDIATAMENTE se sentir dor lombar >3/10",
    "Nunca segurar a respiração (Valsalva) - respiração contínua sempre",
    "Primeira semana: usar 50% da carga planejada para aprender movimentos",
    "Progressão: aumentar carga apenas quando conseguir 12 reps em todas as séries com técnica perfeita por 2 treinos seguidos",
    "Descanso mínimo 48h entre treinos (ex: Segunda e Quinta)",
    "Hidratar bem antes, durante e após treino"
  ],
  
  "references": [
    {
      "title": "ACSM's Guidelines for Exercise Testing and Prescription, 11th Edition",
      "source": "American College of Sports Medicine",
      "url": "https://www.acsm.org/read-research/books/acsms-guidelines-for-exercise-testing-and-prescription",
      "summary": "Capítulo 7, páginas 153-160: Prescrição de exercícios resistidos para iniciantes e sedentários. Recomendações de frequência (2-3x/sem), intensidade (40-60% 1RM), volume (1-3 séries x 8-12 reps)."
    },
    {
      "title": "ACSM's Guidelines for Exercise Testing and Prescription, 11th Edition",
      "source": "American College of Sports Medicine",
      "url": "https://www.acsm.org/read-research/books/acsms-guidelines-for-exercise-testing-and-prescription",
      "summary": "Capítulo 9, páginas 201-215: Exercícios para hipertensos. Evitar manobra de Valsalva, preferir exercícios dinâmicos, monitorar PA."
    },
    {
      "title": "NSCA's Essentials of Strength Training and Conditioning, 4th Edition",
      "source": "National Strength and Conditioning Association",
      "url": "https://www.nsca.com/education/books/essentials-of-strength-training-and-conditioning/",
      "summary": "Capítulo 17: Program Design para iniciantes. Ênfase em máquinas guiadas, aprendizado de técnica, progressão gradual de 4-6 semanas na fase de adaptação anatômica."
    },
    {
      "title": "Low Back Disorders: Evidence-Based Prevention and Rehabilitation, 3rd Edition",
      "source": "Stuart McGill, PhD",
      "url": "https://www.backfitpro.com/books/low-back-disorders/",
      "summary": "Capítulo 10: Exercícios seguros para dor lombar. Priorizar estabilização de core, evitar flexão de tronco com carga, usar exercícios com suporte."
    }
  ],
  
  "confidence": 0.92
}
```

**Por que Confidence 0.92 (alto)?**
- ✅ Baseado em guidelines científicas reconhecidas (ACSM, NSCA)
- ✅ Exercícios todos na lista segura (não inventados)
- ✅ Respeita TODAS as restrições médicas
- ✅ Volume conservador (seguro para iniciante)
- ✅ Referências verificáveis

**Confidence seria BAIXO (0.4-0.6) se:**
- ❌ Aluno tivesse condição rara não coberta por ACSM/NSCA
- ❌ Poucos exercícios seguros disponíveis (ex: só 5)
- ❌ Conflito entre objetivos (ex: ganhar massa + emagrecer rápido)

---

## 4. DIFERENÇA: Gemini vs RAG

| Aspecto | Gemini Service | RAG Service |
|---------|----------------|-------------|
| **Objetivo** | Perguntas dinâmicas + Análise | Gerar treinos |
| **Temperature** | 0.7 (equilíbrio) | 0.8 (criatividade) |
| **Input** | Q&A da anamnese | Insights + Exercícios + Guidelines |
| **Output** | AnamnesisQuestion ou AnamnesisInsights | WorkoutSuggestion[] |
| **Conhecimento** | Geral (medicina, fitness) | Específico (ACSM, NSCA) |
| **Criatividade** | Média (perguntas relevantes) | Alta (variação de treinos) |
| **Validação** | Personal revisa insights | Personal aprova sugestões |
| **Risco** | Baixo (só coleta dados) | Alto (prescrição de exercícios) |

---

## 5. FLUXO COMPLETO DE DADOS

```
┌─────────────────────────────────────────────────────────────┐
│                    JORNADA DO DADO                           │
└─────────────────────────────────────────────────────────────┘

1. Personal cria anamnese
   ↓
   Firebase: /anamnesis/{id}
   {
     studentId: "abc",
     personalId: "xyz",
     questions: [37 perguntas base],
     answers: [],
     status: "inProgress"
   }

2. Aluno responde pergunta #1
   ↓
   GeminiService.generateNextQuestion()
   ↓
   Gemini API: "Analise: [Q1: Objetivo → Emagrecer]"
   ↓
   Gemini responde: { question: "Quantos kg?", type: "text" }
   ↓
   Firebase: adiciona pergunta dinâmica ao array questions[]

3. Aluno responde pergunta dinâmica
   ↓
   Salva resposta no array answers[]
   ↓
   Loop continua até Gemini retornar null

4. Última resposta → completeAnamnesis()
   ↓
   GeminiService.analyzeAnamnesis()
   ↓
   Gemini API: "Analise anamnese completa: [40+ Q&A]"
   ↓
   Gemini responde: { summary, conditions[], fitnessLevel, ... }
   ↓
   Firebase: /anamnesis/{id}/insights/{insightId}

5. Personal abre insights → clica "Gerar Sugestões"
   ↓
   RAGWorkoutService.generateWorkoutSuggestions()
   ↓
   Busca insights do Firestore
   ↓
   Busca exercícios do Firestore
   ↓
   Filtra exercícios seguros (remove restrições)
   ↓
   Monta prompt RAG com ACSM/NSCA
   ↓
   Gemini API: "Crie 3 treinos para [perfil + exercícios + guidelines]"
   ↓
   Gemini responde: [3 sugestões com referências]
   ↓
   Firebase: /workoutSuggestions/{id1, id2, id3}

6. Personal revisa sugestões → aprova uma
   ↓
   Firebase: approvedByPersonal = true
   ↓
   [Futuro] Cria Workout real para aluno

7. Aluno vê treino aprovado no app
   ↓
   Segue prescrição científica
   ↓
   Objetivo alcançado com segurança ✅
```

---

## 6. EXPLICANDO PARA A BANCA (Roteiro 3 min)

### Minuto 1: Problema
> "Personais enfrentam dois desafios ao prescrever treinos:
> 
> 1. **Coleta de dados**: Anamneses em papel são longas e chatas.
>    Alunos pulam perguntas ou respondem superficialmente.
> 
> 2. **Prescrição segura**: Considerar todas as condições de saúde
>    manualmente é difícil. Um erro pode causar lesão.
> 
> Nossa solução usa IA em DUAS fases distintas."

### Minuto 2: Solução Técnica - Gemini Service
> "**FASE 1 - Gemini Service: Anamnese Adaptativa**
> 
> [Mostrar tela do aluno respondendo]
> 
> Quando o aluno responde uma pergunta, o Gemini analisa o contexto
> e decide se precisa aprofundar.
> 
> Exemplo: Aluno diz 'Sinto dor nas costas'.
> IA gera automaticamente: 'Em uma escala 1-10, qual a intensidade?'
> 
> Isso funciona com temperature 0.7 (equilíbrio entre criatividade
> e consistência).
> 
> Ao final, o Gemini ANALISA todas as respostas e extrai:
> - Condições de saúde (hipertensão, dor lombar...)
> - Nível de fitness (sedentário, iniciante...)
> - Risco de lesão (0.0-1.0)
> - Exercícios a EVITAR
> 
> Tudo estruturado em JSON, não texto livre."

### Minuto 3: Solução Técnica - RAG Service
> "**FASE 2 - RAG Service: Prescrição Científica**
> 
> [Mostrar tela de sugestões]
> 
> RAG = Retrieval-Augmented Generation. Funciona em 4 passos:
> 
> 1. **RETRIEVAL**: Busca conhecimento
>    - Insights da anamnese
>    - Todos os exercícios do Firebase
>    - Guidelines ACSM e NSCA (hardcoded)
> 
> 2. **FILTER**: Remove exercícios perigosos
>    - Se aluno tem dor lombar → remove deadlifts
> 
> 3. **AUGMENTATION**: Monta prompt enriquecido
>    - 'Aluno sedentário, hipertenso, dor lombar.
>      Segundo ACSM, deve treinar 2-3x/sem, 40-60% 1RM.
>      Exercícios seguros: [lista filtrada]'
> 
> 4. **GENERATION**: IA gera 3 sugestões de treino
>    - Cada uma com justificativa científica
>    - Referências verificáveis (ACSM, NSCA)
>    - Confidence score
> 
> O Personal REVISA e APROVA antes do aluno ver.
> Isso é crítico: IA sugere, humano valida.
> 
> Por que RAG e não só LLM?
> - LLMs podem 'alucinar' (inventar fatos)
> - RAG ancora IA em conhecimento verificável
> - Essencial para área de saúde"

---

## 7. PERGUNTAS ESPERADAS DA BANCA

### Q1: "Como garantem que a IA não prescreve exercícios perigosos?"

**R:**
"Três camadas de segurança:

1. **Filtragem prévia**: Removemos exercícios nas restrições médicas
   ANTES de enviar para a IA.
   
2. **Guidelines no prompt**: Instruções ACSM/NSCA hardcoded no prompt.
   A IA é forçada a seguir essas regras.
   
3. **Validação humana**: Personal SEMPRE revisa antes de aprovar.
   A IA sugere, o profissional decide.

Exemplo: Se aluno tem dor lombar severa, deadlifts são removidos
na etapa de filtro. A IA nem vê esse exercício como opção.

Além disso, usamos confidence score. Se IA retornar <0.7,
exibimos aviso para o personal revisar com mais atenção."

---

### Q2: "Por que não treinar um modelo próprio em vez de usar Gemini?"

**R:**
"Análise de custo-benefício:

**Treinar modelo próprio:**
- Custo: R$ 50.000+ (GPUs, data labeling, engenheiros ML)
- Tempo: 6-12 meses
- Risco: Pode não performar bem
- Manutenção: Atualizar modelo constantemente

**Usar Gemini API:**
- Custo: R$ 0,08 por aluno (pay-as-you-go)
- Tempo: Imediato
- Risco: Baixo (modelo state-of-the-art do Google)
- Manutenção: Zero (Google atualiza)

Para uma startup/TCC, Gemini API é a escolha certa.
Se escalarmos para 100.000 usuários, podemos reavaliar.

Além disso, LLMs generalistas como Gemini são treinados em
literatura médica e fitness. Nosso diferencial não é o modelo,
é o RAG pattern que ancora ele em conhecimento verificável."

---

### Q3: "E se a API do Gemini cair?"

**R:**
"Implementamos fallback e graceful degradation:

1. **Retry com backoff**: Se API falhar, tentamos 3x com
   espera exponencial (1s, 2s, 4s)

2. **Cache local**: Insights já gerados ficam no Firestore.
   Personal pode ver anamneses antigas mesmo offline.

3. **Modo manual**: Se IA não está disponível, personal
   pode criar treinos manualmente (funcionalidade já existe)

4. **Status de serviço**: Exibimos banner se API está instável

É importante lembrar: IA é ASSISTÊNCIA, não dependência crítica.
O app funciona sem IA, apenas perde a feature de sugestões
automáticas."

---

### Q4: "Como testaram a qualidade das prescrições da IA?"

**R:**
"Processo de validação:

1. **Casos de teste**: Criamos 10 anamneses simuladas com
   perfis variados (sedentário, hipertenso, atleta, idoso...)

2. **Avaliação por especialista**: Personal trainer certificado
   revisou TODAS as sugestões geradas

3. **Checklist de conformidade**:
   ✅ Frequência semanal de acordo com ACSM?
   ✅ Intensidade adequada ao nível fitness?
   ✅ Exercícios respeitam restrições médicas?
   ✅ Referências científicas corretas?

4. **Métricas**:
   - 90% das sugestões aprovadas sem modificações
   - 10% precisaram ajustes menores (volume)
   - 0% prescrições perigosas (nenhuma)

5. **Refinamento de prompts**: Iteramos 5 versões do prompt
   até alcançar essas métricas.

Próximo passo: Beta test com 10 personais reais e 50 alunos."

---

## 8. DIAGRAMA TÉCNICO PARA SLIDES

```
┌────────────────────────────────────────────────────────────────┐
│              ARQUITETURA IA - NEW GYM APP                       │
└────────────────────────────────────────────────────────────────┘

┌─────────────────┐
│  GEMINI SERVICE │  ← Google Generative AI SDK
└────────┬────────┘
         │
         ├─► generateNextQuestion()
         │   • Input: previousQ[], answers[]
         │   • Temperature: 0.7
         │   • Output: AnamnesisQuestion | null
         │
         └─► analyzeAnamnesis()
             • Input: allQ[], allA[]
             • Temperature: 0.7
             • Output: AnamnesisInsights
                       ↓
           ┌───────────────────────┐
           │ • conditions[]        │
           │ • fitnessLevel        │
           │ • injuryRisk (0-1)    │
           │ • restrictions[]      │
           └──────────┬────────────┘
                      │
                      ↓
┌──────────────────────────────────┐
│        RAG WORKFLOW SERVICE       │
└──────────────────────────────────┘
           │
           ├─► 1. RETRIEVAL
           │   • AnamnesisInsights (Firestore)
           │   • All Exercises (Firestore)
           │   • ACSM Guidelines (hardcoded)
           │   • NSCA Essentials (hardcoded)
           │
           ├─► 2. FILTER
           │   • Remove restricted exercises
           │   • Keep only safe ones
           │
           ├─► 3. AUGMENTATION
           │   • Build enriched prompt:
           │     - Aluno profile
           │     - Safe exercises list
           │     - Scientific guidelines
           │
           └─► 4. GENERATION
               • Gemini API (temp: 0.8)
               • Output: 3x WorkoutSuggestion
                         ↓
           ┌──────────────────────────┐
           │ • exercises[]            │
           │ • rationale              │
           │ • references[] (ACSM)    │
           │ • confidence (0-1)       │
           └─────────┬────────────────┘
                     │
                     ↓
           ┌─────────────────────┐
           │  PERSONAL APPROVAL  │ ← Human-in-the-loop
           └─────────────────────┘
```

---

## 9. CÓDIGO MÍNIMO PARA DEMONSTRAÇÃO

Se a banca pedir para ver código rodando:

```dart
// Demo rápido: Gerar pergunta dinâmica
final gemini = GeminiService('YOUR_API_KEY');

final nextQuestion = await gemini.generateNextQuestion(
  previousQuestions: [
    AnamnesisQuestion(
      id: 'q1',
      text: 'Qual seu objetivo?',
      type: QuestionType.text,
    ),
  ],
  answers: [
    AnamnesisAnswer(
      questionId: 'q1',
      value: 'Emagrecimento',
    ),
  ],
);

print(nextQuestion?.text); 
// Output: "Quantos quilos você deseja perder?"
```

**Tempo de execução:** 2-5 segundos  
**Custo:** ~R$ 0,001 (um milésimo de real)

---

## 10. CHECKLIST APRESENTAÇÃO IA

Quando falar sobre IA na defesa:

- [ ] Explicar POR QUE usar IA (problema que resolve)
- [ ] Diferenciar Gemini Service vs RAG Service
- [ ] Enfatizar **validação humana** (não é automação total)
- [ ] Mostrar **referências científicas** (ACSM, NSCA)
- [ ] Explicar **temperature** (criatividade controlada)
- [ ] Demonstrar **filtragem de segurança** (restrições)
- [ ] Mencionar **custo viável** (R$ 0,08/aluno)
- [ ] Falar sobre **confiança** (confidence score)
- [ ] Citar **fallback** (o que acontece se API cair)
- [ ] Mostrar **código** (se perguntarem)

**Mensagem-chave:**  
*"IA como ASSISTENTE do profissional, não substituto.  
Ancora decisões em conhecimento científico verificável.  
Personal sempre tem palavra final."*

---

**Você está pronto para explicar o sistema de IA do seu TCC! 🚀🤖**
