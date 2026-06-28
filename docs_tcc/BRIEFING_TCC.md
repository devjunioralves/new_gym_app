# 🎯 NEW GYM APP - Briefing Técnico TCC

## Sistema de Gerenciamento de Academia com IA para Anamnese e Prescrição de Treinos

**Autor:** Junior Trindade  
**Data:** Junho 2026  
**Tempo de Apresentação:** 10 minutos

---

## 📋 1. VISÃO GERAL DO PROJETO (1 min)

### Problema Identificado

Personais trainers enfrentam dificuldades em:

- Coletar informações detalhadas de saúde dos alunos
- Identificar contraindicações e riscos
- Prescrever treinos personalizados baseados em evidências científicas
- Gerenciar múltiplos alunos simultaneamente

### Solução Proposta

**Aplicativo mobile/web multiplataforma** que integra:

- Gestão completa de alunos e treinos
- **Sistema de anamnese inteligente com IA**
- **Geração automática de sugestões de treino baseadas em ACSM e NSCA**
- Análise de risco de lesões
- Interface para Personal e Aluno

### Diferenciais Competitivos

1. **IA Generativa (Gemini 1.5-pro)** para perguntas dinâmicas
2. **RAG (Retrieval-Augmented Generation)** com base científica
3. **Custo operacional baixo** (~R$0,08 por aluno)
4. **Multiplataforma** (Android, iOS, Web)

---

## 🏗️ 2. ARQUITETURA E PADRÕES (2 min)

### Arquitetura Principal

**Feature-First com Clean Architecture Simplificada**

```
lib/
├── core/                      # Componentes compartilhados
│   ├── config/               # Rotas, temas
│   ├── models/               # Entidades de domínio
│   ├── services/             # Lógica de negócio
│   ├── shared_widgets/       # Widgets reutilizáveis
│   └── utils/                # Utilitários
│
└── features/                 # Funcionalidades (módulos)
    ├── auth/                 # Autenticação
    ├── students/             # Gestão de alunos
    ├── exercise_detail/      # Biblioteca de exercícios
    ├── anamnesis/           # Sistema de anamnese IA ⭐
    └── ...
```

### Padrões de Projeto Aplicados

**1. Repository Pattern**

- Abstração da camada de dados (Firebase)
- Facilita testes e manutenção

**2. Provider Pattern (Riverpod 3.0)**

- Gerenciamento de estado reativo
- Injeção de dependências
- Type-safe

**3. Feature-First Architecture**

- Alta coesão, baixo acoplamento
- Módulos independentes
- Escalabilidade

**4. RAG Pattern (Retrieval-Augmented Generation)**

- Combina IA com base de conhecimento científica
- Reduz alucinações da IA
- Garante precisão nas recomendações

---

## 💻 3. STACK TECNOLÓGICO (1.5 min)

### Frontend

```yaml
Framework: Flutter 3.38.2 (Dart 3.10.0)
  ✓ Multiplataforma (Android, iOS, Web, Desktop)
  ✓ Hot Reload para desenvolvimento rápido
  ✓ Performance nativa
```

### State Management

```yaml
flutter_riverpod: 3.0.1
  ✓ StreamProvider → Real-time Firestore
  ✓ FutureProvider → Operações assíncronas
  ✓ Notifier → Ações com estado
```

### Backend & Database

```yaml
Firebase Suite:
  • firebase_auth: 5.3.3       → Autenticação
  • cloud_firestore: 5.5.2     → Banco NoSQL
  • Firebase Security Rules    → Segurança

Coleções Firestore:
  • users                      → Personais e Alunos
  • exercises                  → Biblioteca de exercícios
  • workouts                   → Treinos prescritos
  • anamnesis                  → Anamneses dos alunos
  • anamnesis/{id}/insights    → Análises da IA
  • workoutSuggestions         → Sugestões de treino RAG
```

### Inteligência Artificial

```yaml
google_generative_ai: 0.4.0

Modelo: Gemini 1.5-pro
  • Temperatura 0.7  → Análise/perguntas dinâmicas
  • Temperatura 0.8  → Geração criativa de treinos

Capacidades: ✓ Geração de perguntas contextuais
  ✓ Análise de condições de saúde
  ✓ Identificação de contraindicações
  ✓ Classificação de fitness level
  ✓ Cálculo de risco de lesão
```

### Navegação

```yaml
go_router: 16.2.4
  ✓ Rotas declarativas
  ✓ Deep linking
  ✓ Navegação type-safe
```

---

## 🎨 4. INTERFACE E EXPERIÊNCIA (1 min)

### Telas Implementadas (18 telas)

**Módulo de Autenticação (2)**

- Login
- Registro (Personal/Aluno)

**Módulo de Exercícios (4)**

- Biblioteca de exercícios
- Criar exercício
- Detalhes do exercício
- Gerenciar exercícios

**Módulo de Alunos (6)**

- Lista de alunos
- Detalhes do aluno
- Registrar aluno
- Criar treino
- Editar treino
- Detalhes do treino

**Módulo de Anamnese IA (4)** ⭐

- Lista de anamneses
- Criar anamnese
- Responder anamnese (progressivo)
- Insights e sugestões

**Outras (2)**

- Home
- Perfil

### Design System

- Material Design 3
- Tema customizado com cores da marca
- Responsivo (Mobile-first)
- Componentes reutilizáveis

---

## 🤖 5. SISTEMA DE ANAMNESE INTELIGENTE (2.5 min)

### Arquitetura do Sistema IA

```
┌─────────────────────────────────────────────────────────────┐
│                   FLUXO DE ANAMNESE                         │
└─────────────────────────────────────────────────────────────┘

1. CRIAÇÃO
   Personal → Seleciona Aluno → Sistema cria 37 perguntas base

2. RESPOSTA (Aluno)
   Pergunta 1 → Resposta → IA analisa
                         ↓
                  Gera pergunta dinâmica?
                         ↓
   Pergunta 2 (base ou IA) → Resposta → ...

3. ANÁLISE (Automática)
   Gemini 1.5-pro analisa todas as respostas
   ↓
   Gera AnamnesisInsights:
     • Resumo do perfil
     • Condições de saúde (+ severidade)
     • Objetivos
     • Limitações físicas
     • Fitness Level (Sedentário→Avançado)
     • Risco de lesão (0-100%)
     • Recomendações

4. GERAÇÃO DE TREINO (RAG)
   Input: Insights + Base Científica (ACSM, NSCA)
   ↓
   RAGWorkoutService filtra exercícios seguros
   ↓
   Gemini gera 3 sugestões de treino:
     • Exercícios específicos (séries, reps, descanso)
     • Justificativa científica
     • Precauções
     • Referências (fonte + link)
     • Nível de confiança (0-100%)

5. APROVAÇÃO
   Personal revisa → Aprova → Cria treino final
```

### Base Científica Implementada

**ACSM Guidelines for Exercise Testing (2021)**

- Frequência: 2-3x/sem (iniciantes), 3-4x/sem (intermediários)
- Intensidade: 40-60% 1RM (iniciantes), 60-80% 1RM (avançados)
- Volume progressivo: incremento 2-10% semanal

**NSCA Essentials of Strength Training**

- Periodização
- Descanso muscular: 48-72h entre grupos
- Variação de estímulos

**Contraindicações Específicas**

- Hipertensão: evitar Valsalva, preferir circuitos
- Dores articulares: ROM controlado, baixa carga
- Sedentários: progressão lenta, técnica primeiro

### Modelo de Dados (Anamnese)

```dart
class Anamnesis {
  String id;
  String studentId;
  String personalId;
  List<AnamnesisQuestion> questions;  // Base + dinâmicas
  List<AnamnesisAnswer> answers;
  AnamnesisStatus status;  // draft|inProgress|completed|analyzed
  DateTime createdAt;
}

class AnamnesisQuestion {
  String text;
  QuestionType type;  // text|yesNo|multipleChoice|scale
  bool isDynamic;     // ⭐ Gerada por IA
  String? generatedReason;  // Por que a IA perguntou
}

class AnamnesisInsights {
  String summary;
  List<HealthCondition> conditions;  // Com severidade
  List<String> goals;
  List<String> limitations;
  FitnessLevel fitnessLevel;
  double injuryRisk;  // 0.0 - 1.0
  Map<String, dynamic> recommendations;
}

class WorkoutSuggestion {
  String name;
  List<ExerciseSuggestion> exercises;
  String rationale;  // Justificativa científica
  List<String> precautions;
  List<ScientificReference> references;  // ACSM, NSCA
  double confidence;  // 0.0 - 1.0
  bool approvedByPersonal;
}
```

---

## 🔒 6. SEGURANÇA E PRIVACIDADE (1 min)

### Autenticação e Autorização

```javascript
// Firebase Authentication
✓ Email/senha com validação
✓ Tokens JWT automáticos
✓ Sessões seguras

// Firestore Security Rules
match /anamnesis/{anamnesisId} {
  allow read: if request.auth != null && (
    resource.data.studentId == request.auth.uid ||
    resource.data.personalId == request.auth.uid
  );
  allow create: if request.auth != null &&
    request.resource.data.personalId == request.auth.uid;
}
```

### Conformidade LGPD/GDPR

- ✅ Dados de saúde criptografados em trânsito (HTTPS/TLS)
- ✅ Consentimento explícito do aluno
- ✅ Direito ao esquecimento (cascade delete)
- ✅ Acesso restrito (apenas personal e aluno)
- ✅ Auditoria via Firebase (logs automáticos)

### Boas Práticas Implementadas

1. **Validação de entrada** em todos os formulários
2. **Tratamento de erros** com feedback ao usuário
3. **Loading states** para operações assíncronas
4. **Offline-first** (Firestore cache)
5. **API Key** não commitada (variáveis de ambiente)

---

## 💰 7. VIABILIDADE ECONÔMICA (0.5 min)

### Custos Operacionais (Gemini API)

| Operação                 | Tokens   | Custo/Uso  | Custo/Aluno |
| ------------------------ | -------- | ---------- | ----------- |
| Perguntas dinâmicas (10) | ~3K      | $0.005     | R$ 0.03     |
| Análise completa         | ~2K      | $0.002     | R$ 0.01     |
| Geração 3 treinos        | ~5K      | $0.008     | R$ 0.04     |
| **TOTAL**                | **~10K** | **$0.015** | **R$ 0.08** |

**Escala:**

- 100 alunos/mês: R$ 8,00
- 1.000 alunos/mês: R$ 80,00

**Firebase (Firestore + Auth):**

- Tier gratuito: 50K reads/day
- Suficiente para ~500 usuários ativos/dia

---

## 🚀 8. DIFERENCIAIS TÉCNICOS (0.5 min)

### Inovações Implementadas

1. **Perguntas Dinâmicas Contextuais**
   - Primeira aplicação fitness brasileira com IA generativa para anamnese
   - Adapta questionário em tempo real

2. **RAG com Base Científica**
   - Não apenas "copia" da IA
   - Fundamentado em ACSM e NSCA
   - Referências verificáveis

3. **Firebase Secondary App**
   - Técnica avançada para evitar logout ao criar alunos
   - Solução única para multi-tenant

4. **Real-time Updates**
   - StreamProvider em toda aplicação
   - Sem necessidade de refresh manual
   - UX superior

5. **Multiplataforma desde o início**
   - Single codebase
   - Deploy em 4 plataformas
   - 80% redução de tempo de desenvolvimento

---

## 📊 9. RESULTADOS E MÉTRICAS (0.5 min)

### Código

- **18 telas** implementadas
- **12 modelos** de dados
- **8 services** (Firebase + IA)
- **15+ providers** Riverpod
- **0 erros** de compilação
- **Análise estática:** 12 warnings (apenas deprecations)

### Funcionalidades

- ✅ Autenticação completa
- ✅ CRUD de exercícios
- ✅ CRUD de alunos
- ✅ CRUD de treinos
- ✅ Sistema de anamnese completo
- ✅ IA para análise de saúde
- ✅ RAG para prescrição de treinos

### Performance

- **APK Release:** 52.6 MB
- **Tempo de build:** ~30s
- **Hot reload:** <1s
- **Resposta IA:** 2-5s (Gemini)

---

## 🔮 10. PRÓXIMOS PASSOS E ESCALABILIDADE (0.5 min)

### Roadmap Futuro

**Curto Prazo:**

- [ ] Sistema de notificações (aluno respondeu anamnese)
- [ ] Gráficos de evolução do aluno
- [ ] Exportar treino em PDF
- [ ] Modo offline completo

**Médio Prazo:**

- [ ] Integração com wearables (Smartwatch)
- [ ] Análise de vídeo para correção de postura (Computer Vision)
- [ ] Chat IA para dúvidas do aluno
- [ ] Marketplace de treinos

**Longo Prazo:**

- [ ] Plataforma multi-academia (SaaS)
- [ ] API pública para integrações
- [ ] Machine Learning para predição de resultados
- [ ] Gamificação

### Escalabilidade Técnica

- **Horizontal:** Firebase escala automaticamente
- **Vertical:** Arquitetura modular permite otimizações pontuais
- **Distribuída:** Multi-region Firebase (latência global)

---

## 📚 REFERÊNCIAS TÉCNICAS

### Livros e Papers

1. ACSM. _Guidelines for Exercise Testing and Prescription_. 11th ed. 2021
2. NSCA. _Essentials of Strength Training and Conditioning_. 4th ed. 2016
3. Martin Fowler. _Patterns of Enterprise Application Architecture_. 2002

### Documentação Oficial

- Flutter: https://flutter.dev/docs
- Firebase: https://firebase.google.com/docs
- Riverpod: https://riverpod.dev
- Google AI: https://ai.google.dev

### Repositórios Open Source

- Flutter samples: https://github.com/flutter/samples
- Firebase samples: https://github.com/firebase/quickstart-flutter

---

## 🎓 CONCLUSÃO

### Aprendizados Principais

1. **Integração de IA em aplicações móveis** é viável e economicamente acessível
2. **RAG pattern** garante qualidade em domínios especializados
3. **Flutter** entrega experiência nativa em múltiplas plataformas
4. **Firebase** acelera desenvolvimento sem comprometer escalabilidade

### Contribuições

- **Técnica:** Implementação completa de sistema RAG em Flutter
- **Científica:** Aplicação prática de guidelines ACSM/NSCA em IA
- **Social:** Democratização de prescrição segura de exercícios

### Impacto Esperado

- Redução de **70%** no tempo de criação de anamneses
- Aumento de **40%** na identificação de contraindicações
- Melhoria na **segurança** da prescrição de exercícios
- Escalabilidade para **milhares de personais** no Brasil

---

**Projeto desenvolvido como TCC - Junho 2026**  
**Tecnologias:** Flutter, Firebase, Google Gemini AI, Riverpod  
**Repositório:** [github.com/juniortrindade/new_gym_app](#)

---

## 💡 PERGUNTAS FREQUENTES (Banca)

**P: Por que Flutter e não React Native?**  
R: Performance nativa (compiled to ARM), Hot Reload superior, single codebase real (não web wrappers), comunidade em crescimento no Brasil.

**P: Por que Firebase e não backend próprio?**  
R: Time-to-market, escalabilidade automática, custo zero inicial, real-time nativo, autenticação enterprise-grade, foco na lógica de negócio.

**P: A IA não pode dar prescrições erradas?**  
R: RAG pattern mitiga isso: IA apenas combina base científica (ACSM/NSCA) com perfil do aluno. Personal sempre revisa antes de aprovar. Sistema é assistente, não substituto.

**P: Como garantir privacidade dos dados de saúde?**  
R: Firebase com Security Rules, criptografia em trânsito (TLS), acesso restrito (apenas personal e aluno), conformidade LGPD, auditoria via logs.

**P: Qual o custo real de operação?**  
R: R$0,08/aluno/mês (IA) + Firebase gratuito até 500 usuários/dia. Total: ~R$100/mês para 1000 alunos. Modelo B2B viável.

**P: Código está testado?**  
R: Validação manual em Chrome e Android. Próximo passo: testes unitários (models), integração (services) e E2E (telas). Framework de testes já disponível no Flutter.
