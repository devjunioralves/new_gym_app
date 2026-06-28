# 🏗️ DIAGRAMAS E ARQUITETURA - NEW GYM APP

## 1. ARQUITETURA GERAL DO SISTEMA

```
┌──────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                               │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Android   │  │     iOS     │  │     Web     │             │
│  │   (APK)     │  │   (IPA)     │  │  (Chrome)   │             │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘             │
│         │                │                │                      │
│         └────────────────┴────────────────┘                      │
│                          │                                       │
│                ┌─────────▼─────────┐                            │
│                │   FLUTTER APP     │                            │
│                │   (Dart 3.10)     │                            │
│                └─────────┬─────────┘                            │
│                          │                                       │
└──────────────────────────┼───────────────────────────────────────┘
                           │
┌──────────────────────────┼───────────────────────────────────────┐
│                 PRESENTATION LAYER                                │
├──────────────────────────┼───────────────────────────────────────┤
│                          │                                        │
│  ┌───────────┐  ┌───────┴────────┐  ┌──────────────┐           │
│  │  Screens  │  │   Widgets      │  │   Providers  │           │
│  │           │  │                │  │  (Riverpod)  │           │
│  │ • Login   │  │ • AppBar       │  │              │           │
│  │ • Home    │  │ • Cards        │  │ • Auth       │           │
│  │ • Alunos  │  │ • Forms        │  │ • Students   │           │
│  │ • Anamnese│  │ • Dialogs      │  │ • Anamnesis  │           │
│  └───────────┘  └────────────────┘  └──────────────┘           │
│                                                                   │
└──────────────────────────┬───────────────────────────────────────┘
                           │
┌──────────────────────────┼───────────────────────────────────────┐
│                   SERVICE LAYER                                   │
├──────────────────────────┼───────────────────────────────────────┤
│                          │                                        │
│  ┌──────────────────┐   │   ┌──────────────────┐                │
│  │ Firebase Services│   │   │  AI Services     │                │
│  │                  │   │   │                  │                │
│  │ • Auth Service   │   │   │ • Gemini Service │                │
│  │ • Exercise Svc   │   │   │ • RAG Service    │                │
│  │ • Student Svc    │   │   │ • Analysis Svc   │                │
│  │ • Anamnesis Svc  │   │   │                  │                │
│  └────────┬─────────┘   │   └────────┬─────────┘                │
│           │             │            │                           │
└───────────┼─────────────┼────────────┼───────────────────────────┘
            │             │            │
┌───────────┼─────────────┼────────────┼───────────────────────────┐
│                   EXTERNAL SERVICES                               │
├───────────┼─────────────┼────────────┼───────────────────────────┤
│           │             │            │                           │
│  ┌────────▼─────────┐  │   ┌────────▼──────────┐               │
│  │    FIREBASE      │  │   │   GOOGLE GEMINI   │               │
│  │                  │  │   │                   │               │
│  │ • Authentication │  │   │ • LLM 1.5-pro     │               │
│  │ • Firestore DB   │  │   │ • Text Generation │               │
│  │ • Security Rules │  │   │ • Analysis        │               │
│  │ • Cloud Storage  │  │   │                   │               │
│  └──────────────────┘  │   └───────────────────┘               │
│                        │                                         │
└────────────────────────┴─────────────────────────────────────────┘
```

---

## 2. ESTRUTURA DE DADOS (FIRESTORE)

```
FIRESTORE DATABASE
├── users/                              (Coleção)
│   ├── {userId}/                       (Documento)
│   │   ├── uid: string
│   │   ├── name: string
│   │   ├── email: string
│   │   ├── isStudent: boolean
│   │   ├── personalId: string?         (se for aluno)
│   │   └── createdAt: timestamp
│
├── exercises/                          (Coleção)
│   ├── {exerciseId}/                   (Documento)
│   │   ├── name: string
│   │   ├── workoutType: string
│   │   ├── series: number
│   │   ├── reps: number
│   │   ├── imageUrl: string
│   │   └── instructions: string
│
├── workouts/                           (Coleção)
│   ├── {workoutId}/                    (Documento)
│   │   ├── studentId: string
│   │   ├── personalId: string
│   │   ├── name: string
│   │   ├── exercises: array
│   │   └── createdAt: timestamp
│
├── anamnesis/                          (Coleção) ⭐
│   ├── {anamnesisId}/                  (Documento)
│   │   ├── studentId: string
│   │   ├── personalId: string
│   │   ├── questions: array[           ← Dinâmico!
│   │   │   {
│   │   │     id: string,
│   │   │     text: string,
│   │   │     type: enum,
│   │   │     isDynamic: boolean,      ← Pergunta IA
│   │   │     generatedReason: string?
│   │   │   }
│   │   │ ]
│   │   ├── answers: array
│   │   ├── status: enum
│   │   ├── createdAt: timestamp
│   │   └── completedAt: timestamp?
│   │
│   └── insights/                       (Subcoleção) ⭐
│       └── {insightId}/                (Documento)
│           ├── summary: string
│           ├── conditions: array
│           ├── goals: array
│           ├── limitations: array
│           ├── fitnessLevel: enum
│           ├── injuryRisk: number
│           └── recommendations: map
│
└── workoutSuggestions/                 (Coleção) ⭐
    └── {suggestionId}/                 (Documento)
        ├── anamnesisId: string
        ├── name: string
        ├── exercises: array[
        │   {
        │     exerciseId: string,
        │     series: number,
        │     reps: string,
        │     rest: number,
        │     reason: string,           ← Base científica
        │     modifications: array
        │   }
        │ ]
        ├── rationale: string           ← Justificativa
        ├── precautions: array
        ├── references: array[          ← ACSM, NSCA
        │   {
        │     title: string,
        │     source: string,
        │     url: string,
        │     summary: string
        │   }
        │ ]
        ├── confidence: number           ← 0.0 - 1.0
        └── approvedByPersonal: boolean
```

---

## 3. FLUXO DE ANAMNESE INTELIGENTE (Detalhado)

```
┌─────────────────────────────────────────────────────────────────┐
│                    FASE 1: CRIAÇÃO                               │
└─────────────────────────────────────────────────────────────────┘

Personal (Web/App)
    │
    ├─► Seleciona Aluno
    │
    ├─► Clica "Criar Anamnese"
    │
    └─► Firebase Service
            │
            ├─► Cria documento em /anamnesis/
            │     • studentId
            │     • personalId
            │     • questions: getBaseQuestions() → 37 perguntas
            │     • status: 'inProgress'
            │
            └─► Retorna anamnesisId


┌─────────────────────────────────────────────────────────────────┐
│              FASE 2: RESPOSTA PROGRESSIVA                        │
└─────────────────────────────────────────────────────────────────┘

Aluno (App)
    │
    ├─► Abre tela /answer-anamnesis/:id
    │
    ├─► Sistema mostra Pergunta 1 (Base)
    │     "Qual seu objetivo principal?"
    │
    ├─► Aluno responde: "Emagrecimento"
    │
    ├─► saveAnswerAndGetNext()
    │       │
    │       ├─► Salva resposta no Firestore
    │       │
    │       └─► Chama Gemini Service
    │             │
    │             ├─► generateNextQuestion()
    │             │
    │             │   Prompt para IA:
    │             │   ───────────────
    │             │   "Contexto: Aluno quer emagrecer.
    │             │    Perguntas anteriores: [...]
    │             │    Respostas: [...]
    │             │
    │             │    Você é especialista em avaliação física.
    │             │    Gere UMA pergunta relevante para entender
    │             │    melhor o perfil do aluno, ou retorne null
    │             │    se já tem informação suficiente."
    │             │
    │             └─► Gemini responde:
    │                   {
    │                     "question": "Quantos kg deseja perder?",
    │                     "type": "text",
    │                     "reason": "Quantificar objetivo"
    │                   }
    │
    ├─► addDynamicQuestion() salva no Firestore
    │     • isDynamic: true
    │     • generatedReason: "Quantificar objetivo"
    │
    ├─► Sistema mostra Pergunta Dinâmica (com badge ✨IA)
    │
    ├─► Aluno responde: "10kg"
    │
    └─► Ciclo continua até completar todas


┌─────────────────────────────────────────────────────────────────┐
│                FASE 3: ANÁLISE AUTOMÁTICA                        │
└─────────────────────────────────────────────────────────────────┘

Quando última pergunta respondida:
    │
    ├─► completeAnamnesis()
    │     • status: 'completed'
    │     • completedAt: now()
    │
    └─► analyzeAnamnesis()
          │
          ├─► Gemini Service
          │
          │   Prompt Complexo:
          │   ───────────────
          │   "Analise a anamnese abaixo:
          │
          │    Q1: Objetivo? → Emagrecimento, 10kg
          │    Q2: Pratica atividade? → Não, sedentário há 2 anos
          │    Q3: Dor nas costas? → Sim
          │    Q4: Intensidade dor? → 7/10 (pergunta IA)
          │    Q5: Hipertensão? → Sim, controlada com medicação
          │    [... 40+ perguntas]
          │
          │    Retorne JSON:
          │    {
          │      summary: string resumindo perfil,
          │      conditions: [
          │        {
          │          name: string,
          │          severity: 'mild'|'moderate'|'severe',
          │          restrictions: [exercícios a evitar]
          │        }
          │      ],
          │      goals: [],
          │      limitations: [],
          │      fitnessLevel: 'sedentary'|'beginner'|...,
          │      injuryRisk: 0.0-1.0,
          │      recommendations: {}
          │    }"
          │
          └─► Gemini retorna:
                {
                  "summary": "Homem, 35 anos, sedentário...",
                  "conditions": [
                    {
                      "name": "Dor lombar crônica",
                      "severity": "moderate",
                      "restrictions": [
                        "Deadlift convencional",
                        "Agachamento livre",
                        "Flexão de tronco com carga"
                      ]
                    },
                    {
                      "name": "Hipertensão controlada",
                      "severity": "mild",
                      "restrictions": [
                        "Exercícios isométricos prolongados",
                        "Manobra de Valsalva"
                      ]
                    }
                  ],
                  "fitnessLevel": "beginner",
                  "injuryRisk": 0.65,
                  "goals": ["Emagrecimento -10kg"],
                  "recommendations": {
                    "Frequência": "2-3x/semana inicialmente",
                    "Progressão": "Aumentar 5% carga a cada 2 sem"
                  }
                }
          │
          └─► Salva em /anamnesis/{id}/insights/


┌─────────────────────────────────────────────────────────────────┐
│            FASE 4: GERAÇÃO DE TREINO (RAG)                       │
└─────────────────────────────────────────────────────────────────┘

Personal (App)
    │
    ├─► Visualiza Insights
    │
    ├─► Clica "Gerar Sugestões com IA"
    │
    └─► generateWorkoutSuggestions()
          │
          ├─► RAG Workflow Service
          │
          │   PASSO 1: Recuperar Contexto
          │   ─────────────────────────
          │   • Busca insights da anamnese
          │   • Busca TODOS exercícios do Firebase
          │   • Carrega guidelines ACSM/NSCA (hardcoded)
          │
          │   PASSO 2: Filtrar Exercícios Seguros
          │   ──────────────────────────────────
          │   allRestrictions = [
          │     "Deadlift", "Agachamento livre",
          │     "Flexão de tronco", "Valsalva"
          │   ]
          │
          │   safeExercises = exercises.where(
          │     !allRestrictions.any(
          │       exerciseName.contains(restriction)
          │     )
          │   )
          │
          │   → Sobram 70 exercícios seguros
          │
          │   PASSO 3: Construir Prompt RAG
          │   ────────────────────────────
          │   Prompt:
          │   "Você é um personal trainer especialista.
          │
          │    PERFIL DO ALUNO:
          │    • Objetivo: Emagrecimento -10kg
          │    • Fitness: Beginner
          │    • Risco: 65% (ALTO)
          │    • Condições: Dor lombar, Hipertensão
          │
          │    EXERCÍCIOS SEGUROS DISPONÍVEIS:
          │    - Leg Press (Pernas)
          │    - Supino máquina (Peito)
          │    - Remada sentada (Costas)
          │    [... 67 outros]
          │
          │    GUIDELINES CIENTÍFICAS:
          │
          │    ACSM 2021:
          │    • Iniciantes: 2-3x/semana
          │    • Intensidade: 40-60% 1RM
          │    • 8-12 repetições por série
          │    • 2-3 séries por exercício
          │    • Descanso: 1-2 min
          │    • Progressão: 2-10% quando conseguir
          │      12 reps com boa técnica
          │
          │    NSCA Essentials:
          │    • Descanso muscular: 48-72h
          │    • Começar com máquinas (maior segurança)
          │    • Enfatizar técnica antes de carga
          │    • Variar estímulos a cada 4-6 semanas
          │
          │    CONDIÇÕES ESPECIAIS:
          │    • Hipertensão: evitar Valsalva, circuitos
          │    • Dor lombar: ROM controlado, core estável
          │    • Iniciantes: progressão lenta e segura
          │
          │    TAREFA:
          │    Crie 3 sugestões de treino DIFERENTES.
          │    Para cada, retorne JSON:
          │    {
          │      name: string,
          │      exercises: [
          │        {
          │          exerciseId: string (da lista acima),
          │          series: number,
          │          reps: string,
          │          rest: number (segundos),
          │          reason: string (por que escolheu),
          │          modifications: [adaptações possíveis]
          │        }
          │      ],
          │      rationale: string (justificativa geral),
          │      precautions: [cuidados específicos],
          │      references: [
          │        {
          │          title: 'ACSM Guidelines 2021',
          │          source: 'ACSM',
          │          url: 'https://...',
          │          summary: 'Página 153: iniciantes...'
          │        }
          │      ],
          │      confidence: 0.0-1.0
          │    }"
          │
          │   PASSO 4: Processar Resposta IA
          │   ────────────────────────────
          │   Gemini retorna 3 sugestões:
          │
          │   Sugestão 1: "Treino Full Body Iniciante"
          │   {
          │     exercises: [
          │       {
          │         exerciseId: "leg-press",
          │         series: 2,
          │         reps: "10-12",
          │         rest: 90,
          │         reason: "Leg press é seguro para lombar,
          │                  trabalha pernas sem sobrecarga axial",
          │         modifications: [
          │           "Iniciar com carga leve (20-30kg)",
          │           "ROM parcial se houver desconforto"
          │         ]
          │       },
          │       ... 6 exercícios
          │     ],
          │     rationale: "Full body 2x/semana é ideal para
          │                  iniciantes segundo ACSM. Permite
          │                  recuperação adequada e frequência
          │                  suficiente para adaptação neural.",
          │     precautions: [
          │       "Monitorar pressão arterial antes/após",
          │       "Evitar apneia (respirar continuamente)",
          │       "Parar se sentir dor lombar"
          │     ],
          │     references: [
          │       {
          │         title: "ACSM Guidelines 2021",
          │         source: "American College Sports Medicine",
          │         url: "https://acsm.org/...",
          │         summary: "Cap 7, pág 153-160: Prescrição
          │                   para iniciantes sedentários"
          │       }
          │     ],
          │     confidence: 0.85
          │   }
          │
          │   Sugestão 2: "Treino AB Máquinas"
          │   Sugestão 3: "Treino Circuito Cardio"
          │
          └─► Salva em /workoutSuggestions/


┌─────────────────────────────────────────────────────────────────┐
│                 FASE 5: VALIDAÇÃO HUMANA                         │
└─────────────────────────────────────────────────────────────────┘

Personal (App)
    │
    ├─► Visualiza 3 sugestões
    │
    ├─► Expande Sugestão 1
    │     • Lê exercícios
    │     • Verifica justificativa
    │     • Checa referências ACSM
    │
    ├─► Aprova Sugestão 1
    │     approveSuggestion(id)
    │     • approvedByPersonal: true
    │
    └─► [FUTURO] Cria Workout real para aluno
          • Converte suggestion → workout
          • Aluno vê no app
```

---

## 4. PADRÕES DE PROJETO APLICADOS

### 4.1 Repository Pattern

```dart
// Abstração da camada de dados
abstract class UserRepository {
  Future<User?> getCurrentUser();
  Stream<User?> userStream();
}

// Implementação Firebase
class FirebaseUserRepository implements UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _firestore
      .collection('users')
      .doc(firebaseUser.uid)
      .get();

    return User.fromMap(doc.data()!);
  }
}

// Uso na aplicação
final user = await userRepository.getCurrentUser();
```

**Vantagens:**

- Desacoplamento (trocar Firebase por Supabase é fácil)
- Testabilidade (mock do repository)
- Manutenibilidade

---

### 4.2 Provider Pattern (Riverpod)

```dart
// Provider de serviço
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider de estado (Stream)
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.userStream();
});

// Provider de ação
class LoginNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authServiceProvider).login(email, password);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Uso na UI
Consumer(
  builder: (context, ref, child) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      data: (user) => Text(user?.name ?? 'Guest'),
      loading: () => CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  },
)
```

**Vantagens:**

- Type-safe (compile-time errors)
- Auto-dispose (garbage collection)
- Reactive UI (rebuild automático)
- Testável (override providers)

---

### 4.3 RAG Pattern (Retrieval-Augmented Generation)

```dart
Future<List<WorkoutSuggestion>> generateWorkoutSuggestions({
  required String anamnesisId,
  required AnamnesisInsights insights,
  required List<Exercise> availableExercises,
}) async {
  // RETRIEVAL: Busca conhecimento relevante
  final scientificGuidelines = _getScientificGuidelines();
  final safeExercises = _filterSafeExercises(
    exercises: availableExercises,
    restrictions: insights.getAllRestrictions(),
  );

  // AUGMENTATION: Monta contexto enriquecido
  final prompt = _buildRAGPrompt(
    insights: insights,
    safeExercises: safeExercises,
    guidelines: scientificGuidelines,
  );

  // GENERATION: IA gera com contexto
  final response = await _geminiModel.generateContent([
    Content.text(prompt)
  ]);

  return _parseSuggestions(response.text!);
}
```

**Por que RAG?**

- LLMs sozinhas "alucinem" (inventam fatos)
- RAG ancora IA em conhecimento verificável
- Essencial para domínios especializados (saúde)

---

## 5. SECURITY RULES (Firebase)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(uid) {
      return request.auth.uid == uid;
    }

    function isPersonal() {
      return isAuthenticated() &&
             get(/databases/$(database)/documents/users/$(request.auth.uid))
               .data.isStudent == false;
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId);
      allow delete: if false; // Soft delete only
    }

    // Exercises collection
    match /exercises/{exerciseId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isPersonal();
    }

    // Workouts collection
    match /workouts/{workoutId} {
      allow read: if isAuthenticated() && (
        isOwner(resource.data.studentId) ||
        isOwner(resource.data.personalId)
      );
      allow create, update, delete: if isPersonal();
    }

    // Anamnesis collection ⭐
    match /anamnesis/{anamnesisId} {
      allow read: if isAuthenticated() && (
        isOwner(resource.data.studentId) ||
        isOwner(resource.data.personalId)
      );
      allow create: if isPersonal() &&
        request.resource.data.personalId == request.auth.uid;
      allow update: if isAuthenticated() && (
        isOwner(resource.data.studentId) ||  // Aluno responde
        isOwner(resource.data.personalId)    // Personal edita
      );
      allow delete: if isPersonal() &&
        isOwner(resource.data.personalId);

      // Insights subcollection
      match /insights/{insightId} {
        allow read: if isAuthenticated() && (
          isOwner(get(/databases/$(database)/documents/anamnesis/$(anamnesisId)).data.studentId) ||
          isOwner(get(/databases/$(database)/documents/anamnesis/$(anamnesisId)).data.personalId)
        );
        allow write: if false; // Only backend can write
      }
    }

    // Workout Suggestions
    match /workoutSuggestions/{suggestionId} {
      allow read: if isAuthenticated();
      allow write: if isPersonal();
    }
  }
}
```

---

## 6. MÉTRICAS E KPIs

### Métricas Técnicas

```
Linhas de Código:     ~8.000 (estimado)
Arquivos Dart:        ~80
Telas:                18
Modelos:              12
Services:             8
Providers:            15+
Tempo de Build:       ~30s (release)
Tamanho APK:          52.6 MB
```

### Performance

```
Hot Reload:           <1s
Cold Start:           2-3s
Resposta IA:          2-5s (Gemini API)
Firestore Query:      100-300ms
Real-time Sync:       Instantâneo (<100ms)
```

### Cobertura

```
Plataformas:          4 (Android, iOS, Web, Desktop)
Idiomas:              1 (PT-BR)
Temas:                2 (Light, Dark)
Breakpoints:          3 (Mobile, Tablet, Desktop)
```

---

**Este documento serve como apoio técnico para a defesa do TCC.**  
**Use os diagramas para explicar visualmente a arquitetura aos professores.**
