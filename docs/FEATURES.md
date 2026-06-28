# Funcionalidades do New Gym App

## Índice
- [Visão Geral](#visão-geral)
- [Personal Trainers](#personal-trainers)
- [Alunos](#alunos)
- [Sistema de Anamnese IA](#sistema-de-anamnese-ia)
- [Permissões e Segurança](#permissões-e-segurança)
- [Roadmap](#roadmap)

---

## Visão Geral

O **New Gym App** possui dois tipos de usuários com funcionalidades específicas:

| Tipo | Papel | Acesso |
|------|-------|--------|
| **Personal Trainer** | Profissional (CREF) | Gestão completa de alunos, exercícios, treinos e anamneses |
| **Aluno** | Cliente do personal | Visualização de treinos e resposta a anamneses |

---

## Personal Trainers

### 📊 Dashboard

**Tela:** `HomeScreen` (Personal)

**Funcionalidades:**
- Visão geral de todos os alunos
- Estatísticas de anamneses (pendentes, em progresso, completas)
- Acesso rápido às principais funcionalidades
- Notificações de anamneses concluídas

**Navegação:**
```
/home
├── /students (Ver todos os alunos)
├── /exercises (Biblioteca de exercícios)
├── /anamnesis-list (Anamneses)
└── /profile (Perfil)
```

---

### 👥 Gestão de Alunos

#### 1. **Listar Alunos**
**Tela:** `StudentsListScreen`  
**Rota:** `/students`

**Funcionalidades:**
- ✅ Lista todos os alunos vinculados ao personal
- ✅ Busca por nome ou email
- ✅ Filtro por status (ativo, inativo)
- ✅ Ordenação (nome, data de cadastro)
- ✅ Card com informações resumidas:
  - Nome e foto
  - Data de cadastro
  - Número de treinos ativos
  - Status da anamnese

**Provider:**
```dart
final studentsProvider = StreamProvider<List<Student>>((ref) {
  final currentUser = ref.watch(authProvider).value;
  return FirebaseFirestore.instance
    .collection('users')
    .where('isStudent', isEqualTo: true)
    .where('personalId', isEqualTo: currentUser?.uid)
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList());
});
```

#### 2. **Detalhes do Aluno**
**Tela:** `StudentDetailScreen`  
**Rota:** `/students/:studentId`

**Funcionalidades:**
- ✅ Informações completas do aluno
- ✅ Histórico de treinos
- ✅ Anamneses realizadas
- ✅ Progresso e evolução (futuro)
- ✅ Ações:
  - Editar informações
  - Criar novo treino
  - Criar anamnese
  - Visualizar insights da IA

#### 3. **Adicionar Aluno**
**Tela:** `AddStudentScreen`  
**Rota:** `/students/add`

**Funcionalidades:**
- ✅ Formulário de cadastro:
  - Nome completo
  - Email
  - Telefone
  - Data de nascimento (opcional)
- ✅ Validação de dados
- ✅ Criação de conta (email/senha)
- ✅ Vinculação automática ao personal

---

### 💪 Gestão de Exercícios

#### 1. **Biblioteca de Exercícios**
**Tela:** `ExercisesListScreen`  
**Rota:** `/exercises`

**Funcionalidades:**
- ✅ Lista de exercícios disponíveis
- ✅ Filtro por tipo de treino:
  - Peito
  - Costas
  - Pernas
  - Ombros
  - Braços
  - Abdômen
  - Cardio
- ✅ Busca por nome
- ✅ Visualização de detalhes (imagem, instruções)

#### 2. **Criar/Editar Exercícios**
**Tela:** `ManageExercisesScreen`  
**Rota:** `/manage-exercises`

**Funcionalidades:**
- ✅ Criar exercício personalizado:
  - Nome
  - Tipo de treino
  - Séries e repetições padrão
  - Instruções detalhadas
  - Upload de imagem (futuro)
- ✅ Editar exercícios existentes
- ✅ Deletar exercícios (se não estiver em uso)

---

### 📋 Gestão de Treinos

#### 1. **Criar Treino**
**Tela:** `CreateWorkoutScreen`  
**Rota:** `/workouts/create`

**Funcionalidades:**
- ✅ Selecionar aluno
- ✅ Nome do treino (ex: "Treino A - Peito e Tríceps")
- ✅ Adicionar exercícios:
  - Buscar na biblioteca
  - Definir séries, repetições
  - Definir carga (opcional)
  - Tempo de descanso
  - Observações
- ✅ Reordenar exercícios (drag and drop)
- ✅ Salvar treino

#### 2. **Editar Treino**
**Tela:** `EditWorkoutScreen`  
**Rota:** `/workouts/:workoutId/edit`

**Funcionalidades:**
- ✅ Modificar exercícios
- ✅ Ajustar séries/repetições
- ✅ Adicionar/remover exercícios
- ✅ Histórico de versões (futuro)

#### 3. **Visualizar Treinos do Aluno**
**Tela:** `StudentWorkoutsScreen`  
**Rota:** `/students/:studentId/workouts`

**Funcionalidades:**
- ✅ Lista de treinos atribuídos
- ✅ Status de cada treino (ativo, concluído)
- ✅ Ações rápidas:
  - Editar
  - Duplicar
  - Arquivar
  - Deletar

---

## Sistema de Anamnese IA

### 🤖 Para Personal Trainers

#### 1. **Listar Anamneses**
**Tela:** `AnamnesisListScreen`  
**Rota:** `/anamnesis-list`

**Funcionalidades:**
- ✅ Lista todas as anamneses criadas
- ✅ Filtro por status:
  - 📝 **Draft** - Criada, aguardando aluno
  - ⏳ **In Progress** - Aluno respondendo
  - ✅ **Completed** - Aluno finalizou
  - 🤖 **Analyzed** - IA analisou e gerou insights
- ✅ Barra de progresso visual (0-100%)
- ✅ Card com informações:
  - Nome do aluno
  - Data de criação
  - Progresso (ex: 25/37 perguntas)
  - Ações disponíveis
- ✅ FAB "Nova Anamnese"

**Provider:**
```dart
final personalAnamnesesProvider = StreamProvider.family<List<Anamnesis>, String>((ref, personalId) {
  return FirebaseFirestore.instance
    .collection('anamnesis')
    .where('personalId', isEqualTo: personalId)
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => Anamnesis.fromFirestore(doc)).toList());
});
```

#### 2. **Criar Anamnese**
**Tela:** `CreateAnamnesisScreen`  
**Rota:** `/create-anamnesis`

**Funcionalidades:**
- ✅ Lista de alunos disponíveis
- ✅ Card informativo explicando o processo:
  - 📝 37 perguntas base sobre saúde e objetivos
  - 🤖 IA gera perguntas dinâmicas baseadas em respostas
  - 📊 Sistema analisa e gera insights
  - 💪 Personal recebe sugestões de treino personalizadas
- ✅ Validação:
  - Aluno já possui anamnese ativa? → Aviso
- ✅ Dialog de confirmação antes de criar
- ✅ Navegação automática para tela de insights após criação
- ✅ Link compartilhável para o aluno responder

**Fluxo:**
```
1. Personal seleciona aluno
2. Sistema cria anamnese com 37 perguntas base
3. Status: draft
4. Personal envia link para aluno
5. Aluno acessa e começa a responder
```

#### 3. **Visualizar Insights e Sugestões**
**Tela:** `AnamnesisInsightsScreen`  
**Rota:** `/anamnesis-insights/:anamnesisId`

**Funcionalidades:**
- ✅ **Tab 1: Insights da IA**
  - 📊 **Resumo geral** do perfil do aluno
  - 💪 **Nível de condicionamento:**
    - Sedentário
    - Iniciante
    - Intermediário
    - Avançado
  - 🏥 **Condições de saúde identificadas:**
    - Nome da condição
    - Severidade (low, moderate, high)
    - Restrições de exercícios
    - Notas e observações
  - 🎯 **Objetivos** declarados pelo aluno
  - ⚠️ **Limitações** identificadas
  - 📈 **Risco de lesão** (score 0-100)
  - 💡 **Recomendações** da IA

- ✅ **Tab 2: Sugestões de Treino**
  - 🤖 Botão "Gerar Sugestões" (chama Gemini + RAG)
  - Lista de até 3 treinos sugeridos
  - Cada sugestão contém:
    - 📝 Nome do treino
    - 💪 Lista de exercícios (séries, reps, observações)
    - 📚 **Justificativa científica:**
      - Por que esses exercícios?
      - Como atendem aos objetivos?
      - Adaptações para condições específicas
    - ⚠️ **Precauções:**
      - Exercícios a evitar
      - Cuidados durante execução
    - 📖 **Referências científicas:**
      - ACSM Guidelines 2021
      - NSCA Essentials
      - Estudos específicos
  - ✅ Botão "Aprovar e Criar Treino" em cada sugestão
  - 📋 ExpansionTile para ver detalhes

**Providers:**
```dart
// Insights
final anamnesisInsightsProvider = StreamProvider.family<AnamnesisInsight?, String>((ref, anamnesisId) {
  return FirebaseFirestore.instance
    .collection('anamnesis')
    .doc(anamnesisId)
    .collection('insights')
    .limit(1)
    .snapshots()
    .map((snapshot) => snapshot.docs.isNotEmpty 
      ? AnamnesisInsight.fromFirestore(snapshot.docs.first) 
      : null);
});

// Sugestões
final workoutSuggestionsProvider = StreamProvider.family<List<WorkoutSuggestion>, String>((ref, anamnesisId) {
  return FirebaseFirestore.instance
    .collection('workoutSuggestions')
    .where('anamnesisId', isEqualTo: anamnesisId)
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => WorkoutSuggestion.fromFirestore(doc)).toList());
});
```

**Ações:**
```dart
// Gerar sugestões
class WorkoutSuggestionNotifier extends Notifier<AsyncValue<void>> {
  Future<void> generateSuggestions(String anamnesisId) async {
    state = const AsyncValue.loading();
    try {
      final ragService = ref.read(ragWorkoutServiceProvider);
      await ragService.generateSuggestions(anamnesisId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Aprovar sugestão
Future<void> approveSuggestion(String suggestionId) async {
  // 1. Busca sugestão
  // 2. Cria workout no Firestore
  // 3. Marca sugestão como approved
}
```

---

### 🏃 Para Alunos

#### 1. **Responder Anamnese**
**Tela:** `AnswerAnamnesisScreen`  
**Rota:** `/answer-anamnesis/:anamnesisId`

**Funcionalidades:**
- ✅ **Interface progressiva** (uma pergunta por vez)
- ✅ **Barra de progresso** visual com porcentagem
- ✅ **Tipos de pergunta:**
  - 📝 **Texto livre:** TextFormField multilinha
  - ✅/❌ **Sim/Não:** Botões grandes
  - 🔘 **Múltipla escolha:** Radio buttons
  - 📊 **Escala (1-10):** Slider com indicador
  - 📅 **Data:** Date picker (futuro)
- ✅ **Perguntas dinâmicas** marcadas com badge:
  - ✨ "Pergunta IA"
  - Cor diferenciada
- ✅ **Navegação:**
  - Botão "Anterior" para revisar respostas
  - Botão "Próxima" (habilitado após responder)
  - Botão "Finalizar" na última pergunta
- ✅ **Salvamento automático** de cada resposta
- ✅ **Chamada à IA** após cada resposta:
  - Analisa resposta
  - Decide se gera pergunta dinâmica ou avança para próxima base
- ✅ **Dialog de conclusão** ao finalizar
- ✅ **Trigger de análise completa** quando finaliza

**Fluxo:**
```
Aluno acessa → Pergunta 1/37 (base)
↓
Responde → IA analisa
↓
IA decide: Gerar pergunta dinâmica? 
├── SIM → Pergunta 38/38 (dinâmica ✨)
│   ↓
│   Responde → IA analisa novamente
│   ↓
│   Próxima base ou nova dinâmica
└── NÃO → Pergunta 2/37 (próxima base)
    ↓
    Repete...
    ↓
Última pergunta → "Finalizar"
↓
Trigger análise completa
↓
IA gera insights
↓
Aluno vê mensagem de conclusão
↓
Personal recebe notificação (futuro)
```

**Provider:**
```dart
// Carrega anamnese e perguntas
final anamnesisProvider = StreamProvider.family<Anamnesis, String>((ref, id) {
  return FirebaseFirestore.instance
    .collection('anamnesis')
    .doc(id)
    .snapshots()
    .map((doc) => Anamnesis.fromFirestore(doc));
});

// Ações
class AnamnesisAnswerNotifier extends Notifier<AsyncValue<void>> {
  // Salva resposta e pega próxima pergunta
  Future<void> saveAnswerAndGetNext(String anamnesisId, Answer answer) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(anamnesisServiceProvider);
      
      // 1. Salva resposta no Firestore
      await service.saveAnswer(anamnesisId, answer);
      
      // 2. Envia para IA analisar
      final gemini = ref.read(geminiServiceProvider);
      final nextQuestion = await gemini.analyzeAnswerAndGetNext(anamnesisId, answer);
      
      // 3. Se IA gerou pergunta dinâmica, adiciona à anamnese
      if (nextQuestion != null) {
        await service.addDynamicQuestion(anamnesisId, nextQuestion);
      }
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  // Finaliza e dispara análise completa
  Future<void> completeAndAnalyze(String anamnesisId) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(anamnesisServiceProvider);
      
      // 1. Marca como completa
      await service.markAsCompleted(anamnesisId);
      
      // 2. Dispara análise da IA
      final gemini = ref.read(geminiServiceProvider);
      await gemini.analyzeCompleteAnamnesis(anamnesisId);
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

#### 2. **Visualizar Treinos**
**Tela:** `StudentWorkoutsScreen`  
**Rota:** `/my-workouts`

**Funcionalidades:**
- ✅ Lista de treinos atribuídos pelo personal
- ✅ Detalhes de cada exercício:
  - Nome
  - Séries x Repetições
  - Carga (se definida)
  - Tempo de descanso
  - Instruções
  - Imagem/GIF demonstrativo
- ✅ Marcar treino como concluído (futuro)
- ✅ Registrar carga usada (futuro)
- ✅ Comentários para o personal (futuro)

---

## Alunos

### 🏠 Dashboard

**Tela:** `HomeScreen` (Student)

**Funcionalidades:**
- Treinos do dia/semana
- Anamneses pendentes
- Progresso geral
- Mensagens do personal (futuro)

---

## Permissões e Segurança

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isPersonal() {
      return isAuthenticated() && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isPersonal == true;
    }
    
    function isStudent() {
      return isAuthenticated() && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isStudent == true;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isStudentOfPersonal(personalId) {
      return isStudent() && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.personalId == personalId;
    }
    
    // Users
    match /users/{userId} {
      allow read: if isOwner(userId) || 
        (isPersonal() && get(/databases/$(database)/documents/users/$(userId)).data.personalId == request.auth.uid);
      allow create: if isAuthenticated();
      allow update: if isOwner(userId);
      allow delete: if false; // Apenas admin
    }
    
    // Exercises
    match /exercises/{exerciseId} {
      allow read: if isAuthenticated();
      allow create, update: if isPersonal();
      allow delete: if isPersonal() && 
        resource.data.createdBy == request.auth.uid;
    }
    
    // Workouts
    match /workouts/{workoutId} {
      allow read: if isOwner(resource.data.studentId) || 
        isOwner(resource.data.personalId);
      allow create, update, delete: if isPersonal() && 
        request.auth.uid == request.resource.data.personalId;
    }
    
    // Anamnesis
    match /anamnesis/{anamnesisId} {
      allow read: if isOwner(resource.data.studentId) || 
        isOwner(resource.data.personalId);
      allow create: if isPersonal();
      allow update: if isOwner(resource.data.studentId) || 
        isOwner(resource.data.personalId);
      allow delete: if isOwner(resource.data.personalId);
      
      // Insights (subcollection)
      match /insights/{insightId} {
        allow read: if isOwner(get(/databases/$(database)/documents/anamnesis/$(anamnesisId)).data.personalId) ||
          isOwner(get(/databases/$(database)/documents/anamnesis/$(anamnesisId)).data.studentId);
        allow write: if false; // Apenas IA/Cloud Functions
      }
    }
    
    // Workout Suggestions
    match /workoutSuggestions/{suggestionId} {
      allow read: if isOwner(resource.data.personalId);
      allow create: if false; // Apenas IA/Cloud Functions
      allow update: if isPersonal() && 
        request.auth.uid == resource.data.personalId;
      allow delete: if isPersonal();
    }
  }
}
```

---

## Roadmap

Ver [ROADMAP.md](ROADMAP.md) para planos futuros detalhados.

---

**Última atualização:** Junho 2026
