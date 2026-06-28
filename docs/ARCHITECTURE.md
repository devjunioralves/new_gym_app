# Arquitetura do New Gym App

## Índice
- [Estrutura de Pastas](#estrutura-de-pastas)
- [Padrões Arquiteturais](#padrões-arquiteturais)
- [Fluxo de Dados](#fluxo-de-dados)
- [Modelo de Dados](#modelo-de-dados)
- [Padrões de Projeto](#padrões-de-projeto)

---

## Estrutura de Pastas

O projeto segue a arquitetura **Feature-First**, onde cada funcionalidade é um módulo independente:

```
lib/
├── core/                      # Código compartilhado
│   ├── config/               # Router, tema, constantes
│   │   ├── app_router.dart
│   │   ├── theme.dart
│   │   └── constants.dart
│   ├── models/               # Entidades de domínio
│   │   ├── user.dart
│   │   ├── exercise.dart
│   │   ├── workout.dart
│   │   ├── anamnesis.dart
│   │   ├── anamnesis_insight.dart
│   │   └── workout_suggestion.dart
│   ├── services/             # Serviços compartilhados
│   │   ├── firebase_service.dart
│   │   ├── gemini_service.dart
│   │   └── rag_workout_service.dart
│   ├── shared_widgets/       # Componentes reutilizáveis
│   │   ├── custom_button.dart
│   │   ├── loading_indicator.dart
│   │   └── error_message.dart
│   └── utils/                # Helpers, extensões
│       ├── validators.dart
│       └── formatters.dart
│
├── features/                  # Módulos de funcionalidades
│   ├── auth/                 # Autenticação
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   └── providers/
│   │   │       └── auth_provider.dart
│   │   └── README.md
│   │
│   ├── students/             # Gestão de alunos
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── students_list_screen.dart
│   │   │   │   ├── student_detail_screen.dart
│   │   │   │   └── add_student_screen.dart
│   │   │   └── providers/
│   │   │       └── students_provider.dart
│   │   └── README.md
│   │
│   ├── exercises/            # Biblioteca de exercícios
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── exercises_list_screen.dart
│   │   │   │   └── exercise_detail_screen.dart
│   │   │   └── providers/
│   │   │       └── exercise_provider.dart
│   │   └── README.md
│   │
│   ├── manage_exercises/     # CRUD de exercícios
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── manage_exercises_screen.dart
│   │   │   │   └── edit_exercise_screen.dart
│   │   │   └── providers/
│   │   │       └── manage_exercises_provider.dart
│   │   └── README.md
│   │
│   ├── anamnesis/            # ⭐ Sistema de Anamnese IA
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── anamnesis_list_screen.dart       # Lista todas anamneses
│   │   │   │   ├── create_anamnesis_screen.dart     # Personal cria anamnese
│   │   │   │   ├── answer_anamnesis_screen.dart     # Aluno responde
│   │   │   │   └── anamnesis_insights_screen.dart   # Personal vê insights + sugestões
│   │   │   └── providers/
│   │   │       └── anamnesis_providers.dart
│   │   └── README.md
│   │
│   ├── home/                 # Tela inicial
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   └── providers/
│   │   │       └── home_provider.dart
│   │   └── README.md
│   │
│   └── profile/              # Perfil do usuário
│       ├── presentation/
│       │   ├── screens/
│       │   │   └── profile_screen.dart
│       │   └── providers/
│       │       └── profile_provider.dart
│       └── README.md
│
├── app.dart                  # Widget root do app
└── main.dart                 # Entry point
```

---

## Padrões Arquiteturais

### 1. Clean Architecture (Simplificada)

Adaptamos a Clean Architecture para um escopo menor, mantendo separação de responsabilidades:

```
┌─────────────────────────────────────┐
│         PRESENTATION                │
│  (Screens + Riverpod Providers)     │
│  - UI Components                    │
│  - State Management                 │
│  - Navigation                       │
└──────────────┬──────────────────────┘
               │ uses
               ▼
┌─────────────────────────────────────┐
│           DOMAIN                    │
│         (Models)                    │
│  - Entities                         │
│  - Business Rules                   │
└──────────────┬──────────────────────┘
               │ uses
               ▼
┌─────────────────────────────────────┐
│            DATA                     │
│      (Services)                     │
│  - Firebase Service                 │
│  - Gemini Service                   │
│  - RAG Service                      │
└─────────────────────────────────────┘
```

**Benefícios:**
- ✅ Testabilidade: Cada camada pode ser testada isoladamente
- ✅ Manutenibilidade: Mudanças em uma camada não afetam outras
- ✅ Escalabilidade: Fácil adicionar novas features
- ✅ Reutilização: Services e models compartilhados

---

### 2. State Management com Riverpod 3.0

Utilizamos diferentes tipos de providers para casos de uso específicos:

#### **StreamProvider** - Dados em tempo real (Firestore)
```dart
final studentsProvider = StreamProvider<List<Student>>((ref) {
  return FirebaseFirestore.instance
    .collection('users')
    .where('isStudent', isEqualTo: true)
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList());
});
```

#### **FutureProvider** - Carregamento assíncrono único
```dart
final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final snapshot = await FirebaseFirestore.instance.collection('exercises').get();
  return snapshot.docs.map((doc) => Exercise.fromFirestore(doc)).toList();
});
```

#### **NotifierProvider** - Ações e mutações
```dart
class AnamnesisAnswerNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> saveAnswerAndGetNext(String anamnesisId, Answer answer) async {
    state = const AsyncValue.loading();
    try {
      await _anamnesisService.saveAnswer(anamnesisId, answer);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
```

#### **Provider** - Dependências singleton
```dart
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService(apiKey: 'YOUR_API_KEY');
});
```

---

## Fluxo de Dados - Anamnese IA

### Diagrama Completo

```
┌─────────────────────────────────────────────────────────────────┐
│                     FLUXO DE ANAMNESE IA                        │
└─────────────────────────────────────────────────────────────────┘

1. CRIAÇÃO (Personal Trainer)
   ┌──────────────────┐
   │ CreateAnamnesis  │
   │    Screen        │
   └────────┬─────────┘
            │ Personal seleciona aluno
            ▼
   ┌──────────────────┐
   │ AnamnesisService │
   └────────┬─────────┘
            │ Cria documento com 37 perguntas base
            ▼
   ┌──────────────────┐
   │   Firestore      │
   │  /anamnesis/     │
   │  {anamnesisId}   │
   │  status: draft   │
   └──────────────────┘

2. RESPOSTA (Aluno)
   ┌──────────────────┐
   │ AnswerAnamnesis  │
   │    Screen        │
   └────────┬─────────┘
            │ Aluno acessa via link
            ▼
   ┌──────────────────┐
   │ Mostra pergunta  │
   │   progressiva    │
   └────────┬─────────┘
            │ Aluno responde
            ▼
   ┌──────────────────┐
   │  GeminiService   │
   │  analyzeAnswer() │
   └────────┬─────────┘
            │ IA analisa resposta
            ▼
   ┌──────────────────────────────┐
   │ Gera próxima pergunta?       │
   ├─────────────┬────────────────┤
   │ SIM         │ NÃO            │
   │ (dinâmica)  │ (próxima base) │
   └─────┬───────┴────────┬───────┘
         │                │
         ▼                ▼
   ┌──────────┐    ┌──────────┐
   │ Pergunta │    │ Pergunta │
   │ IA ✨    │    │ Base     │
   └────┬─────┘    └────┬─────┘
        │               │
        └───────┬───────┘
                │ Salva resposta
                ▼
   ┌──────────────────┐
   │   Firestore      │
   │  answers: [...]  │
   └──────────────────┘
                │
                │ Repete até completar
                ▼

3. ANÁLISE (IA)
   ┌──────────────────┐
   │ Aluno completa   │
   │ última pergunta  │
   └────────┬─────────┘
            │ Trigger análise
            ▼
   ┌──────────────────┐
   │  GeminiService   │
   │  analyzeComplete │
   │   Anamnesis()    │
   └────────┬─────────┘
            │ IA processa todas respostas
            ▼
   ┌──────────────────────────────────┐
   │ Gera insights:                   │
   │ • Summary                        │
   │ • Fitness Level                  │
   │ • Health Conditions              │
   │ • Goals & Limitations            │
   │ • Injury Risk Score              │
   │ • Recommendations                │
   └────────┬─────────────────────────┘
            │ Salva insights
            ▼
   ┌──────────────────┐
   │   Firestore      │
   │  /insights/{id}  │
   │  status: analyzed│
   └──────────────────┘

4. SUGESTÕES (Personal + IA + RAG)
   ┌──────────────────┐
   │ InsightsScreen   │
   │ Tab: Sugestões   │
   └────────┬─────────┘
            │ Personal clica "Gerar Sugestões"
            ▼
   ┌──────────────────┐
   │ RAGWorkoutService│
   └────────┬─────────┘
            │ 1. Busca insights
            │ 2. Busca exercícios do Firestore
            │ 3. Carrega guidelines (ACSM, NSCA)
            ▼
   ┌──────────────────────────────────┐
   │  GeminiService                   │
   │  generateWorkoutSuggestions()    │
   │                                  │
   │  Contexto:                       │
   │  • Insights do aluno             │
   │  • Exercícios disponíveis        │
   │  • Guidelines científicas        │
   └────────┬─────────────────────────┘
            │ IA gera 3 sugestões completas
            ▼
   ┌──────────────────────────────────┐
   │ Sugestão de Treino:              │
   │ • Nome do treino                 │
   │ • Exercises[] (séries, reps)     │
   │ • Rationale (justificativa)      │
   │ • Precautions (precauções)       │
   │ • References (ACSM, NSCA)        │
   └────────┬─────────────────────────┘
            │ Salva sugestões
            ▼
   ┌──────────────────┐
   │   Firestore      │
   │  /workoutSugg... │
   │  status: pending │
   └──────────────────┘

5. APROVAÇÃO (Personal)
   ┌──────────────────┐
   │ Personal revisa  │
   │ sugestões        │
   └────────┬─────────┘
            │ Aprova sugestão
            ▼
   ┌──────────────────┐
   │ Cria workout     │
   │ baseado na       │
   │ sugestão         │
   └────────┬─────────┘
            │
            ▼
   ┌──────────────────┐
   │   Firestore      │
   │  /workouts/{id}  │
   │  studentId: ...  │
   └──────────────────┘
```

---

## Modelo de Dados (Firestore)

### Collections Principais

#### 1. **users** (usuários)
```json
{
  "id": "user123",
  "name": "João Silva",
  "email": "joao@email.com",
  "isStudent": true,
  "personalId": "personal456",  // Se isStudent
  "cref": "12345-G/SP",         // Se personal
  "phone": "+5511999999999",
  "createdAt": "2026-01-15T10:00:00Z"
}
```

#### 2. **exercises** (biblioteca de exercícios)
```json
{
  "id": "ex789",
  "name": "Supino Reto",
  "workoutType": "Peito",
  "series": 3,
  "reps": 12,
  "instructions": "Deitado no banco...",
  "imageUrl": "https://...",
  "createdBy": "personal456"
}
```

#### 3. **workouts** (treinos atribuídos)
```json
{
  "id": "workout101",
  "name": "Treino A - Peito e Tríceps",
  "studentId": "user123",
  "personalId": "personal456",
  "exercises": [
    {
      "exerciseId": "ex789",
      "series": 4,
      "reps": 10,
      "weight": 60,
      "rest": "90s"
    }
  ],
  "createdAt": "2026-06-01T08:00:00Z"
}
```

#### 4. **anamnesis** (anamneses)
```json
{
  "id": "anam202",
  "studentId": "user123",
  "personalId": "personal456",
  "status": "completed",  // draft | inProgress | completed | analyzed
  "questions": [
    {
      "id": "q1",
      "text": "Qual seu principal objetivo?",
      "type": "multipleChoice",
      "options": ["Emagrecimento", "Hipertrofia", "Condicionamento"],
      "isDynamic": false
    },
    {
      "id": "q38",
      "text": "Você mencionou dor no joelho. Com que frequência?",
      "type": "text",
      "isDynamic": true  // ✨ Gerada pela IA
    }
  ],
  "answers": [
    {
      "questionId": "q1",
      "value": "Hipertrofia",
      "answeredAt": "2026-06-10T14:30:00Z"
    }
  ],
  "progress": 95.5,  // Porcentagem
  "createdAt": "2026-06-10T10:00:00Z",
  "completedAt": "2026-06-10T15:00:00Z"
}
```

#### 5. **insights** (subcollection de anamnesis)
```json
{
  "id": "insight303",
  "anamnesisId": "anam202",
  "summary": "Aluno com objetivo de hipertrofia, nível intermediário...",
  "fitnessLevel": "intermediate",
  "conditions": [
    {
      "name": "Dor no joelho direito",
      "severity": "moderate",
      "restrictions": ["Leg Press", "Agachamento Profundo"],
      "notes": "Histórico de lesão no LCA"
    }
  ],
  "goals": ["Hipertrofia", "Aumento de força"],
  "limitations": ["Mobilidade limitada no joelho"],
  "injuryRisk": 35,  // 0-100
  "recommendations": [
    "Fortalecer quadríceps com amplitude reduzida",
    "Incluir exercícios de mobilidade"
  ],
  "createdAt": "2026-06-10T15:05:00Z"
}
```

#### 6. **workoutSuggestions** (sugestões de treino)
```json
{
  "id": "sugg404",
  "anamnesisId": "anam202",
  "insightId": "insight303",
  "name": "Treino Hipertrofia - Adaptado",
  "exercises": [
    {
      "exerciseId": "ex789",
      "name": "Supino Reto",
      "series": 4,
      "reps": "8-10",
      "notes": "Amplitude completa, controle na descida"
    },
    {
      "exerciseId": "ex790",
      "name": "Cadeira Extensora",
      "series": 3,
      "reps": "12-15",
      "notes": "Substituição do leg press devido à limitação no joelho"
    }
  ],
  "rationale": "Treino focado em hipertrofia com exercícios que minimizam stress no joelho...",
  "precautions": [
    "Evitar agachamento profundo",
    "Monitorar dor durante execução"
  ],
  "references": [
    "ACSM Guidelines 2021 - Resistance Training Adaptations",
    "NSCA - Exercise Selection for Knee Injuries"
  ],
  "status": "pending",  // pending | approved | rejected
  "createdAt": "2026-06-11T09:00:00Z"
}
```

---

## Padrões de Projeto

### 1. **Repository Pattern**
Services abstraem completamente o Firebase, permitindo trocar implementação:

```dart
abstract class ExerciseRepository {
  Stream<List<Exercise>> watchExercises();
  Future<void> createExercise(Exercise exercise);
  Future<void> updateExercise(String id, Exercise exercise);
  Future<void> deleteExercise(String id);
}

class FirebaseExerciseRepository implements ExerciseRepository {
  final FirebaseFirestore _firestore;
  
  @override
  Stream<List<Exercise>> watchExercises() {
    return _firestore.collection('exercises')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Exercise.fromFirestore(doc)).toList());
  }
}
```

### 2. **RAG (Retrieval-Augmented Generation)**
Combina recuperação de dados (exercícios, guidelines) com geração de IA:

```dart
class RAGWorkoutService {
  Future<List<WorkoutSuggestion>> generateSuggestions(String anamnesisId) async {
    // 1. RETRIEVAL - Busca contexto
    final insights = await _getInsights(anamnesisId);
    final exercises = await _getAllExercises();
    final guidelines = await _getScientificGuidelines();
    
    // 2. AUGMENTATION - Enriquece prompt
    final context = _buildContext(insights, exercises, guidelines);
    
    // 3. GENERATION - IA gera sugestões
    final suggestions = await _geminiService.generateWorkouts(context);
    
    return suggestions;
  }
}
```

### 3. **Secondary App Pattern (Firebase)**
Isolamento de operações específicas sem afetar autenticação principal:

```dart
class FirebaseSecondaryApp {
  static FirebaseApp? _secondaryApp;
  
  static Future<FirebaseApp> getSecondaryApp() async {
    if (_secondaryApp != null) return _secondaryApp!;
    
    _secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    return _secondaryApp!;
  }
}
```

### 4. **Observer Pattern (Riverpod)**
Estado reativo que notifica automaticamente widgets:

```dart
// Provider observa Firestore
final anamnesisProvider = StreamProvider.family<Anamnesis, String>((ref, id) {
  return FirebaseFirestore.instance
    .collection('anamnesis')
    .doc(id)
    .snapshots()
    .map((doc) => Anamnesis.fromFirestore(doc));
});

// Widget consome e reage a mudanças
class AnamnesisScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anamnesisAsync = ref.watch(anamnesisProvider(anamnesisId));
    
    return anamnesisAsync.when(
      data: (anamnesis) => Text(anamnesis.status),
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('Erro: $e'),
    );
  }
}
```

---

## Decisões Arquiteturais

### Por que Feature-First ao invés de Layered?

**Layered (tradicional):**
```
lib/
├── presentation/
│   ├── screens/
│   └── widgets/
├── domain/
│   ├── models/
│   └── repositories/
└── data/
    ├── services/
    └── sources/
```

**Feature-First (escolhido):**
```
lib/
├── features/
│   ├── anamnesis/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   └── students/
└── core/
```

**Vantagens:**
- ✅ **Escalabilidade**: Adicionar nova feature não afeta outras
- ✅ **Manutenibilidade**: Toda lógica de uma feature em um lugar
- ✅ **Trabalho em equipe**: Desenvolvedores podem trabalhar em features isoladas
- ✅ **Remoção fácil**: Deletar uma feature = deletar uma pasta

### Por que Riverpod ao invés de BLoC/MobX?

| Critério | Riverpod | BLoC | MobX |
|----------|----------|------|------|
| Curva de aprendizado | ⭐⭐⭐ | ⭐ | ⭐⭐ |
| Boilerplate | Mínimo | Alto | Médio |
| Performance | Excelente | Excelente | Boa |
| Testabilidade | Excelente | Excelente | Boa |
| Type-safety | Sim | Sim | Limitado |
| Comunidade | Grande | Grande | Média |

**Riverpod venceu por:**
- Menos boilerplate
- Syntax moderna e limpa
- Integração perfeita com Flutter
- Compile-time safety

### Por que Firestore ao invés de SQL?

| Critério | Firestore | PostgreSQL |
|----------|-----------|------------|
| Real-time | ✅ Nativo | ⚠️ Complexo |
| Escalabilidade | ✅ Auto | ⚠️ Manual |
| Custo inicial | ✅ Grátis | 💰 Servidor |
| Queries complexas | ⚠️ Limitado | ✅ SQL completo |
| Offline support | ✅ Nativo | ❌ |

**Firestore escolhido porque:**
- MVP precisa de velocidade
- Real-time é requisito (progresso de anamnese)
- Sem infraestrutura para gerenciar
- Offline support gratuito

---

## Próximos Passos

1. **Refatoração**: Mover `services` de `core/` para dentro de cada `feature/`
2. **Testes**: Implementar testes unitários para cada service
3. **CI/CD**: GitHub Actions para build e deploy automático
4. **Monitoramento**: Firebase Performance + Crashlytics

---

**Última atualização:** Junho 2026  
**Versão:** 1.0.0
