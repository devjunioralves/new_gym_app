# Stack Tecnológica - New Gym App

## Índice
- [Visão Geral](#visão-geral)
- [Front-end](#front-end)
- [Back-end / Serviços](#back-end--serviços)
- [IA / Machine Learning](#ia--machine-learning)
- [DevOps e Infraestrutura](#devops-e-infraestrutura)
- [Ferramentas de Desenvolvimento](#ferramentas-de-desenvolvimento)
- [Dependências do Projeto](#dependências-do-projeto)

---

## Visão Geral

O **New Gym App** é construído com tecnologias modernas priorizando:
- 🚀 **Performance** - Flutter com rendering nativo
- 🔄 **Real-time** - Firestore para sincronização instantânea
- 🤖 **IA** - Google Gemini para análise inteligente
- 🔒 **Segurança** - Firebase Auth + Regras de segurança rigorosas
- 📱 **Multiplataforma** - Um código para Web, Android, iOS

---

## Front-end

### Flutter Framework

**Versão:** 3.38.2  
**Dart:** 3.10.0

**Por que Flutter?**
- ✅ Performance nativa em todas as plataformas
- ✅ Hot reload para desenvolvimento rápido
- ✅ UI consistente (Material Design 3)
- ✅ Comunidade ativa e grande ecossistema de packages
- ✅ Suporte oficial do Google

**Recursos utilizados:**
- Material Design 3
- Stateful e Stateless Widgets
- Custom Painters (futuro - gráficos)
- Animations API

---

### State Management

#### Riverpod

**Versão:** 3.0.1  
**Package:** `flutter_riverpod`

**Por que Riverpod?**
- ✅ Compile-time safety (detecta erros em tempo de compilação)
- ✅ Menos boilerplate que BLoC
- ✅ Testabilidade excelente
- ✅ Suporte a família de providers (parametrizados)
- ✅ DevTools integration

**Tipos de Providers utilizados:**

1. **Provider** - Dependências singleton
```dart
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService(apiKey: apiKey);
});
```

2. **StreamProvider** - Dados em tempo real
```dart
final studentsProvider = StreamProvider<List<Student>>((ref) {
  return FirebaseFirestore.instance
    .collection('users')
    .where('isStudent', isEqualTo: true)
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList());
});
```

3. **FutureProvider** - Carregamento assíncrono
```dart
final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final snapshot = await FirebaseFirestore.instance.collection('exercises').get();
  return snapshot.docs.map((doc) => Exercise.fromFirestore(doc)).toList();
});
```

4. **NotifierProvider** - Ações e mutações
```dart
class AnamnesisAnswerNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> saveAnswer(String id, Answer answer) async {
    state = const AsyncValue.loading();
    try {
      await _service.saveAnswer(id, answer);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

---

### Navegação

#### go_router

**Versão:** 16.2.4

**Por que go_router?**
- ✅ Navegação declarativa (tipo-safe)
- ✅ Deep linking nativo
- ✅ URL-based routing (perfeito para web)
- ✅ Parâmetros de rota
- ✅ Redirects e guards

**Exemplo de rotas:**
```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/anamnesis-list',
      builder: (context, state) => const AnamnesisListScreen(),
    ),
    GoRoute(
      path: '/answer-anamnesis/:anamnesisId',
      builder: (context, state) {
        final id = state.pathParameters['anamnesisId']!;
        return AnswerAnamnesisScreen(anamnesisId: id);
      },
    ),
  ],
);
```

---

## Back-end / Serviços

### Firebase

**Plataforma:** Firebase (Google Cloud)  
**Plano:** Blaze (Pay-as-you-go)

#### Firebase Core

**Versão:** 3.8.1

Inicialização da plataforma Firebase.

---

#### Firebase Authentication

**Versão:** 5.3.3

**Features utilizadas:**
- Email/Password authentication
- User management
- Password reset
- Session persistence

**Benefícios:**
- ✅ Segurança robusta (hash bcrypt)
- ✅ Tokens JWT automáticos
- ✅ Refresh tokens
- ✅ Multi-device support

**Exemplo:**
```dart
final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

---

#### Cloud Firestore

**Versão:** 5.5.2

**Por que Firestore?**
- ✅ NoSQL escalável automaticamente
- ✅ Real-time listeners (StreamProvider)
- ✅ Offline support com cache local
- ✅ Queries poderosos
- ✅ Regras de segurança granulares

**Collections:**
```
- users/
  - {userId}/
- exercises/
  - {exerciseId}/
- workouts/
  - {workoutId}/
- anamnesis/
  - {anamnesisId}/
    - insights/ (subcollection)
      - {insightId}/
- workoutSuggestions/
  - {suggestionId}/
```

**Real-time exemplo:**
```dart
FirebaseFirestore.instance
  .collection('users')
  .where('isStudent', isEqualTo: true)
  .snapshots()  // Stream<QuerySnapshot>
  .map((snapshot) => snapshot.docs.map((doc) => Student.fromDoc(doc)).toList());
```

**Custo estimado:**
- Leituras: $0.06 / 100k
- Escritas: $0.18 / 100k
- Storage: $0.18 / GB/mês

Para ~1000 alunos ativos: **< $10/mês**

---

#### Firebase Storage (Futuro)

**Versão:** Planejado

**Uso planejado:**
- Upload de imagens de exercícios
- Fotos de progresso de alunos
- Vídeos de demonstração
- PDFs de relatórios

---

#### Cloud Functions (Futuro)

**Versão:** Planejado

**Uso planejado:**
- Triggers de notificação push
- Webhooks de pagamento (Stripe)
- Agregações de dados para analytics
- Tarefas agendadas (cron jobs)

---

### HTTP Client

#### http

**Versão:** 1.2.0

**Uso:**
- Requisições REST para APIs externas
- Backup para chamadas Gemini (se SDK falhar)

---

## IA / Machine Learning

### Google Generative AI (Gemini)

**Versão:** 0.4.0  
**Package:** `google_generative_ai`

**Modelo:** gemini-1.5-pro

**Por que Gemini?**
- ✅ Contexto longo (1M tokens)
- ✅ Multimodal (texto, imagem - futuro)
- ✅ Preço competitivo ($0.00025/1k tokens input)
- ✅ Qualidade de resposta superior
- ✅ Safety settings configuráveis

**Usos no projeto:**

1. **Perguntas Dinâmicas** (temperature: 0.7)
```dart
final response = await model.generateContent([
  Content.text('''
Anamnese em progresso. Baseado nas respostas anteriores:
${previousAnswers}

Precisa de uma pergunta de follow-up? Se sim, gere. Se não, retorne null.
''')
]);
```

2. **Análise de Anamnese** (temperature: 0.7)
```dart
final response = await model.generateContent([
  Content.text('''
Analise esta anamnese completa e retorne insights estruturados:
${fullAnamnesis}

Formato JSON esperado:
{
  "summary": "...",
  "fitnessLevel": "sedentary|beginner|intermediate|advanced",
  "conditions": [...],
  "injuryRisk": 0-100,
  "recommendations": [...]
}
''')
]);
```

3. **Sugestões de Treino - RAG** (temperature: 0.8)
```dart
final response = await model.generateContent([
  Content.text('''
CONTEXTO DO ALUNO:
${insights}

EXERCÍCIOS DISPONÍVEIS:
${availableExercises}

GUIDELINES CIENTÍFICAS:
${acsmGuidelines}
${nscaGuidelines}

Gere 3 treinos personalizados com justificativa científica.
''')
]);
```

**Custo estimado:**
- Perguntas dinâmicas: ~500 tokens/pergunta = $0.000125
- Análise completa: ~3000 tokens = $0.00075
- Sugestões RAG: ~5000 tokens = $0.00125
- **Total por aluno:** ~$0.015 (R$ 0,08)

**Rate Limits:**
- 60 requests/min (Free tier)
- 1000 requests/min (Paid tier)

---

### Retrieval-Augmented Generation (RAG)

**Padrão:** RAG (Retrieval-Augmented Generation)

**Implementação:**
```dart
class RAGWorkoutService {
  Future<List<WorkoutSuggestion>> generateSuggestions(String anamnesisId) async {
    // 1. RETRIEVAL - Busca contexto relevante
    final insights = await _getInsights(anamnesisId);
    final exercises = await _getAllExercises();
    final guidelines = await _getScientificGuidelines();
    
    // 2. AUGMENTATION - Enriquece o prompt
    final enrichedContext = '''
INSIGHTS DO ALUNO:
${insights.toJson()}

EXERCÍCIOS DISPONÍVEIS:
${exercises.map((e) => e.toJson()).join('\n')}

GUIDELINES CIENTÍFICAS:
ACSM 2021 - Resistance Training:
${acsmGuidelines}

NSCA - Exercise Selection:
${nscaGuidelines}
''';
    
    // 3. GENERATION - IA gera resposta
    final suggestions = await _geminiService.generateWorkouts(enrichedContext);
    
    return suggestions;
  }
}
```

**Knowledge Base:**
- ACSM Guidelines 2021 (American College of Sports Medicine)
- NSCA Essentials (National Strength and Conditioning Association)
- Exercícios do banco de dados (Firestore)
- Insights do aluno (gerados pela IA)

**Vantagens do RAG:**
- ✅ Respostas baseadas em evidências científicas
- ✅ Reduz alucinações da IA
- ✅ Personalizadas para contexto do aluno
- ✅ Atualização fácil da knowledge base

---

## DevOps e Infraestrutura

### Controle de Versão

**Git + GitHub**
- Commits semânticos (Conventional Commits)
- Branches: `main`, `develop`, `feature/*`
- Pull Requests obrigatórios
- Code review

---

### CI/CD (Planejado)

**GitHub Actions**

Workflow planejado:
```yaml
name: CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.2'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

  build-web:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build web --release
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: new-gym-app
```

---

### Hospedagem

**Firebase Hosting** (Web)
- CDN global
- SSL automático
- Custom domain support
- Rollbacks fáceis

**Google Play Store** (Android - Futuro)
**Apple App Store** (iOS - Futuro)

---

### Monitoramento (Planejado)

**Firebase Performance Monitoring**
- Tempo de carregamento de telas
- Latência de APIs
- Network traces

**Firebase Crashlytics**
- Rastreamento de crashes
- Stack traces
- Alertas por email

**Firebase Analytics**
- Eventos de usuário
- Funis de conversão
- Retention cohorts

---

## Ferramentas de Desenvolvimento

### IDE / Editor

**Visual Studio Code**
- Extensions:
  - Flutter
  - Dart
  - Firebase
  - GitLens
  - Error Lens
  - Prettier

**Android Studio** (alternativa)

---

### Análise de Código

**flutter_lints**
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    avoid_print: true
    prefer_const_constructors: true
    use_key_in_widget_constructors: true
```

**Comandos:**
```bash
flutter analyze        # Análise estática
flutter format .       # Formatação de código
dart fix --apply       # Aplicar quick fixes
```

---

### Testes (Planejado)

**Unit Tests:**
```dart
// test/services/gemini_service_test.dart
void main() {
  group('GeminiService', () {
    test('generateQuestion should return Question', () async {
      final service = GeminiService(apiKey: 'test-key');
      final question = await service.generateQuestion(context);
      expect(question, isA<Question>());
    });
  });
}
```

**Widget Tests:**
```dart
testWidgets('AnswerAnamnesisScreen displays question', (tester) async {
  await tester.pumpWidget(AnswerAnamnesisScreen(anamnesisId: 'test-id'));
  expect(find.text('Qual seu principal objetivo?'), findsOneWidget);
});
```

**Integration Tests:**
```dart
// integration_test/anamnesis_flow_test.dart
testWidgets('Complete anamnesis flow', (tester) async {
  // 1. Personal cria anamnese
  // 2. Aluno responde
  // 3. IA analisa
  // 4. Sugestões geradas
});
```

---

### Debug

**Flutter DevTools**
- Widget Inspector
- Performance profiler
- Network inspector
- Memory profiler
- Logging

**Firebase Console**
- Firestore data viewer
- Authentication users
- Analytics dashboard

---

## Dependências do Projeto

### pubspec.yaml

```yaml
name: new_gym_app
description: Sistema de gestão de treinos com IA
version: 1.0.0+1

environment:
  sdk: '>=3.10.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^3.0.1
  
  # Navigation
  go_router: ^16.2.4
  
  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  
  # IA
  google_generative_ai: ^0.4.0
  
  # HTTP
  http: ^1.2.0
  
  # Utils
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

---

## Comparação de Alternativas

### State Management

| Critério | Riverpod | BLoC | MobX | Provider |
|----------|----------|------|------|----------|
| Curva de aprendizado | ⭐⭐⭐ | ⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| Boilerplate | Baixo | Alto | Médio | Baixo |
| Performance | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| Type-safety | ✅ | ✅ | ⚠️ | ⚠️ |
| DevTools | ✅ | ✅ | ✅ | ✅ |
| Comunidade | Grande | Enorme | Média | Grande |

**Escolha:** Riverpod (melhor custo-benefício)

---

### Backend

| Critério | Firebase | Supabase | AWS Amplify |
|----------|----------|----------|-------------|
| Real-time | ✅ Nativo | ✅ Postgres | ⚠️ AppSync |
| Custo inicial | Grátis | Grátis | Grátis |
| Escalabilidade | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Facilidade setup | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| SQL support | ❌ | ✅ | ⚠️ |
| Offline support | ✅ | ⚠️ | ✅ |

**Escolha:** Firebase (velocidade de MVP)

---

### IA

| Modelo | Custo (1M tokens) | Contexto | Qualidade | Latência |
|--------|-------------------|----------|-----------|----------|
| Gemini 1.5-pro | $0.25 | 1M tokens | ⭐⭐⭐⭐⭐ | ~2s |
| GPT-4o | $2.50 | 128k tokens | ⭐⭐⭐⭐⭐ | ~3s |
| Claude 3.5 Sonnet | $3.00 | 200k tokens | ⭐⭐⭐⭐⭐ | ~2.5s |
| GPT-3.5 Turbo | $0.50 | 16k tokens | ⭐⭐⭐⭐ | ~1s |

**Escolha:** Gemini 1.5-pro (melhor custo-benefício + contexto)

---

## Custos Estimados (Produção)

### Para 1000 alunos ativos/mês

| Serviço | Uso | Custo |
|---------|-----|-------|
| **Firestore** | 500k leituras, 200k escritas | $5 |
| **Firebase Auth** | 1000 usuários | Grátis |
| **Firebase Hosting** | 10 GB/mês | Grátis |
| **Gemini API** | 1000 anamneses completas | $15 |
| **Firebase Storage** (futuro) | 50 GB | $1 |
| **Cloud Functions** (futuro) | 1M invocações | $0.40 |
| **Total** | | **~$21.40/mês** |

**Por aluno:** $0.021/mês (R$ 0,11/mês)

**Sustentável com plano Starter (R$ 49/mês) a partir de 10 alunos!**

---

**Última atualização:** Junho 2026  
**Versão:** 1.0.0
