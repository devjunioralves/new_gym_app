# Arquitetura do New Gym App

## Índice
- [Visão Geral do Sistema](#visão-geral-do-sistema)
- [C4 Model](#c4-model)
- [Arquitetura de Pastas](#arquitetura-de-pastas)
- [Fluxo da Anamnese com IA](#fluxo-da-anamnese-com-ia)
- [Modelo de Dados (Firestore)](#modelo-de-dados-firestore)
- [Gerenciamento de Estado](#gerenciamento-de-estado)
- [Decisões Arquiteturais](#decisões-arquiteturais)

---

## Visão Geral do Sistema

O New Gym App é uma aplicação Flutter com backend Firebase e integração com IA (Google Gemini). A arquitetura é organizada em **feature-first** com três camadas bem definidas: Presentation, Domain e Data.

---

## C4 Model

### Nível 1 — Contexto do Sistema

```mermaid
graph TD
    PT["👨‍💼 Personal Trainer\nGerencia alunos,\napprova treinos"]
    ALU["🏃 Aluno\nResponde anamnese,\nvisualiza treinos"]
    APP["🏋️ New Gym App\nSistema de gestão de treinos\ncom Inteligência Artificial"]
    GEM["🤖 Google Gemini API\nAnálise de saúde e\ngeração de sugestões\n(ACSM/NSCA)"]
    FB["🔥 Firebase\nAuth + Firestore\n(Backend as a Service)"]

    PT -->|"Cria anamneses,\naprova treinos"| APP
    ALU -->|"Responde anamnese,\nvê treinos"| APP
    APP -->|"Envia contexto clínico,\nrecebe análise e sugestões"| GEM
    APP -->|"Autentica usuários,\nlê e escreve dados"| FB
```

### Nível 2 — Containers

```mermaid
graph TD
    subgraph Usuários
        PT["👨‍💼 Personal Trainer"]
        ALU["🏃 Aluno"]
    end

    subgraph "New Gym App (Flutter)"
        UI["📱 Interface Flutter\nDart / Material Design 3"]
        STATE["⚡ Gerenciamento de Estado\nRiverpod 3.0"]
        NAV["🧭 Navegação\nGoRouter 16"]
    end

    subgraph "Firebase (BaaS)"
        AUTH["🔐 Firebase Auth\nAutenticação de usuários"]
        DB["🗄️ Cloud Firestore\nBanco de dados NoSQL\nem tempo real"]
    end

    subgraph "Google AI"
        GEMINI["🤖 Gemini gemini-3.5-flash\nAnálise de anamnese\ne RAG de treinos"]
    end

    PT --> UI
    ALU --> UI
    UI <--> STATE
    UI --> NAV
    STATE -->|"Login / Cadastro"| AUTH
    STATE -->|"CRUD de dados"| DB
    STATE -->|"Análise + Sugestões"| GEMINI
```

### Nível 3 — Componentes principais

```mermaid
graph LR
    subgraph "Feature: Anamnesis"
        ANS["AnswerAnamnesisScreen"]
        INS["AnamnesisInsightsScreen"]
        LST["AnamnesisListScreen"]
        PROV["AnamnesisProviders\n(Riverpod)"]
    end

    subgraph "Core: Services"
        GS["GeminiService\nPerguntas dinâmicas\ne análise"]
        RS["RAGWorkoutService\nSugestões ACSM/NSCA"]
        FS["FirebaseAnamnesisService\nCRUD Firestore"]
        ES["FirebaseExerciseService\nFindOrCreate exercícios"]
    end

    subgraph "Core: Models"
        AM["Anamnesis"]
        IM["AnamnesisInsights"]
        WM["WorkoutSuggestion"]
        EM["Exercise"]
    end

    ANS --> PROV
    INS --> PROV
    LST --> PROV
    PROV --> GS
    PROV --> RS
    PROV --> FS
    PROV --> ES
    GS --> AM
    RS --> WM
    FS --> AM
    FS --> IM
    ES --> EM
```

---

## Arquitetura de Pastas

O projeto segue **Feature-First**: cada funcionalidade é um módulo independente com suas próprias telas, providers e lógica.

```
lib/
├── core/                          # Código compartilhado entre features
│   ├── config/
│   │   ├── app_router.dart        # Rotas declarativas (GoRouter)
│   │   └── app_theme.dart         # Tema Material Design 3
│   ├── models/                    # Entidades de domínio
│   │   ├── user_model.dart
│   │   ├── user_role.dart
│   │   ├── exercise_model.dart
│   │   ├── anamnesis_model.dart
│   │   ├── anamnesis_insights_model.dart
│   │   └── workout_suggestion_model.dart
│   ├── services/                  # Acesso a dados e APIs externas
│   │   ├── firebase_auth_service.dart
│   │   ├── firebase_anamnesis_service.dart
│   │   ├── firebase_exercise_service.dart
│   │   ├── firebase_workout_service.dart
│   │   ├── gemini_service.dart        # Análise de anamnese (IA)
│   │   └── rag_workout_service.dart   # Sugestões de treino (IA + RAG)
│   ├── shared_widgets/
│   │   ├── app_footer.dart        # Navegação inferior (role-aware)
│   │   └── user_avatar.dart       # Avatar com iniciais
│   └── utils/
│       └── anamnesis_template.dart  # Perguntas base + por sexo
│
├── features/
│   ├── auth/                      # Login e cadastro
│   ├── home/                      # Home diferente por role (PT vs aluno)
│   ├── anamnesis/                 # ⭐ Fluxo central do app
│   ├── students/                  # Gestão de alunos (PT)
│   ├── profile/                   # Perfil e troca de senha
│   └── exercise_detail/           # Biblioteca de exercícios
│
├── app.dart                       # MaterialApp.router + localizations
└── main.dart                      # Firebase init + ProviderScope
```

---

## Fluxo da Anamnese com IA

Este é o fluxo mais complexo do sistema, envolvendo injeção dinâmica de perguntas e duas chamadas à API Gemini.

```mermaid
sequenceDiagram
    actor PT as Personal Trainer
    actor ALU as Aluno
    participant APP as Flutter App
    participant GEM as Gemini API
    participant DB as Firestore

    PT->>APP: Cria anamnese para aluno
    APP->>DB: Salva 22 perguntas base (q1–qh5)
    APP-->>ALU: Anamnese disponível

    ALU->>APP: Inicia anamnese

    loop Perguntas base (q1–qh5)
        APP->>ALU: Exibe pergunta
        ALU->>APP: Responde
        APP->>DB: Salva resposta

        alt Pergunta q2 (sexo biológico)
            APP->>DB: Injeta qf1–qf7 (Feminino) ou qm1–qm3 (Masculino)
        end
    end

    Note over APP,GEM: Todas as perguntas base respondidas

    APP->>GEM: Envia respostas base + data atual
    GEM-->>APP: Retorna 3–5 perguntas diagnósticas personalizadas
    APP->>DB: Adiciona perguntas dinâmicas à anamnese

    loop Perguntas diagnósticas (IA)
        ALU->>APP: Responde
        APP->>DB: Salva resposta
    end

    APP->>GEM: Envia anamnese completa para análise
    GEM-->>APP: Retorna AnamnesisInsights (condições, nível, risco, recomendações)
    APP->>DB: Salva insights + status = analyzed

    PT->>APP: Visualiza insights do aluno
    PT->>APP: Solicita sugestões de treino

    APP->>GEM: Envia insights (RAG com ACSM/NSCA)
    GEM-->>APP: Retorna WorkoutSuggestion com justificativas científicas
    APP->>DB: Salva sugestão

    PT->>APP: Revisa e edita sugestão (opcional)
    PT->>APP: Aprova sugestão

    loop Para cada exercício
        APP->>DB: findOrCreate exercício na biblioteca
        APP->>DB: Adiciona ao treino do aluno
    end

    APP-->>ALU: Treino disponível para visualização
```

### Injeção de Perguntas por Sexo Biológico

```mermaid
flowchart TD
    Q2["q2: Sexo biológico?"]
    Q2 -->|Feminino| FEM["Injeta qf1–qf7\n- Gravidez / amamentação\n- Ciclo menstrual\n- Anticoncepcionais / TRH\n- SOP / endometriose\n- Osteoporose / densitometria\n- Complicações gestacionais"]
    Q2 -->|Masculino| MAS["Injeta qm1–qm3\n- Hérnia inguinal/abdominal\n- Anabolizantes / TRT\n- Sintomas de alteração hormonal"]
    Q2 -->|Prefiro não informar| NEU["Sem injeção adicional\nIA gera diagnóstico\ncompleto sem dados sexo-específicos"]
    FEM --> AI["IA recebe perfil completo\ne gera diagnóstico"]
    MAS --> AI
    NEU --> AI
```

---

## Modelo de Dados (Firestore)

```mermaid
erDiagram
    users {
        string uid PK
        string name
        string email
        string role "personalTrainer ou student"
        string cref "somente PT"
        string photoUrl
    }

    anamneses {
        string id PK
        string studentId FK
        string personalId FK
        string status "draft | inProgress | completed | analyzed"
        array questions "AnamnesisQuestion[]"
        array answers "AnamnesisAnswer[]"
        datetime createdAt
        datetime completedAt
        datetime analyzedAt
    }

    insights {
        string id PK
        string anamnesisId FK
        string summary
        array conditions "HealthCondition[]"
        array goals
        array limitations
        string fitnessLevel
        float injuryRisk
        object recommendations
    }

    workout_suggestions {
        string id PK
        string anamnesisId FK
        string name
        array exercises "ExerciseSuggestion[]"
        string rationale
        array precautions
        array references
        float confidence
        bool approvedByPersonal
    }

    workouts {
        string id PK
        string studentId FK
        string createdBy FK
        string name
        array exercises "WorkoutExercise[]"
        datetime createdAt
    }

    exercises {
        string id PK
        string name
        string workoutType
        int series
        int reps
        string instructions
        string imageUrl
    }

    users ||--o{ anamneses : "aluno responde"
    users ||--o{ anamneses : "personal cria"
    anamneses ||--o| insights : "análise gera"
    anamneses ||--o{ workout_suggestions : "IA gera"
    workout_suggestions ||--o| workouts : "aprovação cria"
    workouts }o--o{ exercises : "contém"
```

---

## Gerenciamento de Estado

O Riverpod 3.0 é utilizado com três tipos de providers conforme o caso de uso:

```mermaid
flowchart LR
    subgraph "StreamProvider — Firestore real-time"
        SP1["studentsListProvider"]
        SP2["exerciseListProvider"]
        SP3["studentAnamnesesProvider"]
    end

    subgraph "FutureProvider — Leitura única"
        FP1["anamnesisProvider(id)"]
        FP2["anamnesisInsightsProvider(id)"]
        FP3["workoutSuggestionsProvider(id)"]
    end

    subgraph "NotifierProvider — Ações e mutações"
        NP1["AnamnesisAnswerNotifier\nsaveAnswerAndGetNext()"]
        NP2["WorkoutSuggestionNotifier\napproveSuggestion()"]
        NP3["AuthNotifier\nlogin() / register()"]
    end

    subgraph "Provider — Singletons de serviço"
        PP1["geminiServiceProvider"]
        PP2["ragWorkoutServiceProvider"]
        PP3["anamnesisServiceProvider"]
    end
```

---

## Decisões Arquiteturais

### Feature-First vs Layered

A estrutura **feature-first** foi escolhida porque cada funcionalidade (anamnese, alunos, perfil) tem ciclo de vida independente. Adicionar ou remover uma feature equivale a adicionar ou remover uma pasta, sem impacto nas demais.

### Riverpod vs BLoC

| Critério | Riverpod | BLoC |
|---|---|---|
| Boilerplate | Mínimo | Alto |
| Curva de aprendizado | Baixa | Média |
| Compile-time safety | Sim | Sim |
| Integração com Firebase | Nativa | Manual |

### Firestore vs SQL

O Firestore foi escolhido por oferecer sincronização em tempo real nativa (necessária para o progresso da anamnese), suporte offline gratuito e ausência de infraestrutura de servidor para gerenciar — essencial para um projeto de TCC.

### IA: RAG sem biblioteca prévia

As sugestões de treino são geradas livremente pela IA com base em ACSM/NSCA, **sem depender de uma biblioteca de exercícios pré-existente**. Os exercícios só são persistidos no Firestore quando o personal trainer aprova uma sugestão, via `findOrCreateByName`. Isso elimina o problema de "lista vazia" e permite que a IA prescreva o exercício mais adequado sem restrições artificiais.

---

**Última atualização:** Junho 2026 | **Versão:** 1.0.0
