# Roadmap - New Gym App

## Visão Geral

Este documento descreve o planejamento de desenvolvimento do **New Gym App** em 4 fases principais, desde o MVP até a monetização completa.

---

## Fase 1 - MVP ✅ (Concluído)

**Período:** Janeiro - Março 2026  
**Status:** ✅ 100% Completo

### Objetivo
Criar a base funcional do aplicativo com gestão de alunos, exercícios e treinos.

### Funcionalidades Implementadas

#### ✅ Autenticação
- [x] Login com email/senha (Firebase Auth)
- [x] Registro de Personal Trainers (com CREF)
- [x] Registro de Alunos
- [x] Recuperação de senha
- [x] Logout
- [x] Sistema de permissões (Personal vs. Student)

#### ✅ Gestão de Alunos
- [x] Listar alunos do personal
- [x] Adicionar novo aluno
- [x] Visualizar detalhes do aluno
- [x] Editar informações do aluno
- [x] Buscar e filtrar alunos
- [x] Vincular aluno ao personal automaticamente

#### ✅ Gestão de Exercícios
- [x] Biblioteca de exercícios
- [x] Criar exercício personalizado
- [x] Editar exercício
- [x] Deletar exercício (se não usado)
- [x] Filtrar por tipo de treino
- [x] Buscar exercícios
- [x] Visualizar detalhes e instruções

#### ✅ Gestão de Treinos
- [x] Criar treino para aluno
- [x] Atribuir exercícios ao treino
- [x] Definir séries, repetições, carga
- [x] Editar treino existente
- [x] Visualizar treinos do aluno
- [x] Deletar treino

#### ✅ Interface
- [x] Navegação com go_router
- [x] Temas Material Design 3
- [x] Responsividade básica
- [x] Loading states
- [x] Error handling

#### ✅ Backend
- [x] Firestore configurado
- [x] Collections principais (users, exercises, workouts)
- [x] Regras de segurança básicas
- [x] Real-time updates com StreamProvider

---

## Fase 2 - Anamnese IA ✅ (Concluído)

**Período:** Abril - Junho 2026  
**Status:** ✅ 100% Completo

### Objetivo
Implementar sistema de anamnese inteligente com análise por IA e sugestões de treino personalizadas.

### Funcionalidades Implementadas

#### ✅ Perguntas Base
- [x] Template com 37 perguntas sobre saúde e objetivos
- [x] Tipos de pergunta: texto, sim/não, múltipla escolha, escala
- [x] Validação de respostas
- [x] Salvamento progressivo

#### ✅ IA - Perguntas Dinâmicas
- [x] Integração com Google Gemini 1.5-pro
- [x] Análise de respostas em tempo real
- [x] Geração de perguntas de follow-up inteligentes
- [x] Badge visual para perguntas geradas por IA

#### ✅ IA - Análise de Anamnese
- [x] Processamento completo ao finalizar
- [x] Geração de insights:
  - Resumo do perfil
  - Nível de condicionamento
  - Condições de saúde identificadas
  - Objetivos e limitações
  - Score de risco de lesão (0-100)
  - Recomendações personalizadas

#### ✅ IA - Sugestões de Treino (RAG)
- [x] RAG (Retrieval-Augmented Generation) implementado
- [x] Knowledge base com guidelines científicas:
  - ACSM Guidelines 2021
  - NSCA Essentials
- [x] Geração de até 3 treinos sugeridos
- [x] Justificativa científica para cada exercício
- [x] Precauções baseadas em condições do aluno
- [x] Referências bibliográficas

#### ✅ Telas
- [x] Lista de anamneses (personal)
- [x] Criação de anamnese (personal)
- [x] Resposta progressiva (aluno)
- [x] Visualização de insights (personal)
- [x] Aprovação de sugestões (personal)

#### ✅ Backend
- [x] Collections: anamnesis, insights, workoutSuggestions
- [x] Regras de segurança para dados de saúde (LGPD)
- [x] GeminiService para IA
- [x] RAGWorkoutService para sugestões
- [x] Custo estimado: ~$0.015 por aluno

#### ✅ Documentação
- [x] README completo
- [x] ANAMNESE_IA_STATUS.md
- [x] FIREBASE_SETUP.md
- [x] FIRESTORE_SECURITY_RULES.md
- [x] SISTEMA_PERMISSOES.md

---

## Fase 3 - Melhorias 🔄 (Em Andamento)

**Período:** Julho - Dezembro 2026  
**Status:** 🔄 30% Completo

### Objetivo
Aprimorar experiência do usuário, adicionar comunicação e acompanhamento de progresso.

### Funcionalidades Planejadas

#### 📱 Notificações Push
- [ ] Firebase Cloud Messaging configurado
- [ ] Notificar aluno quando treino for atribuído
- [ ] Notificar personal quando anamnese for concluída
- [ ] Notificar aluno quando insights estiverem prontos
- [ ] Lembretes de treino (configurável)
- [ ] Notificações de mensagens do personal

**Tecnologias:**
- Firebase Cloud Messaging (FCM)
- Cloud Functions para triggers
- Local notifications (flutter_local_notifications)

**Estimativa:** 3 semanas

---

#### 💬 Chat Personal-Aluno
- [ ] Tela de conversas
- [ ] Mensagens em tempo real (Firestore)
- [ ] Envio de imagens (Firebase Storage)
- [ ] Notificações de novas mensagens
- [ ] Histórico de conversas
- [ ] Indicador "online/offline"

**Tecnologias:**
- Firestore real-time
- Firebase Storage para mídias
- FCM para notificações

**Estimativa:** 4 semanas

---

#### 📊 Acompanhamento de Progresso
- [ ] Registro de medidas corporais:
  - Peso
  - Altura
  - IMC (calculado)
  - Circunferências (braço, perna, cintura, quadril)
  - Percentual de gordura (bioimpedância)
- [ ] Histórico de medidas
- [ ] Gráficos de evolução (fl_chart)
- [ ] Comparação antes/depois
- [ ] Fotos de progresso (antes/durante/depois)
- [ ] Exportação de relatório (PDF)

**Tecnologias:**
- fl_chart para gráficos
- pdf para relatórios
- Firebase Storage para fotos

**Estimativa:** 5 semanas

---

#### 📸 Registro de Execução de Treinos
- [ ] Aluno marca exercício como concluído
- [ ] Registro de carga utilizada por exercício
- [ ] Registro de séries completadas
- [ ] Comentários sobre dificuldade
- [ ] Foto/vídeo da execução (opcional)
- [ ] Personal vê progresso de carga ao longo do tempo
- [ ] Gráfico de progressão de carga por exercício

**Tecnologias:**
- Firestore para registros
- Firebase Storage para mídias
- fl_chart para gráficos de progressão

**Estimativa:** 4 semanas

---

#### 📈 Gráficos e Analytics
- [ ] Dashboard do personal:
  - Total de alunos ativos
  - Anamneses pendentes
  - Taxa de adesão aos treinos
  - Alunos mais engajados
- [ ] Dashboard do aluno:
  - Treinos concluídos no mês
  - Streak de dias consecutivos
  - Objetivos alcançados
- [ ] Gráficos de evolução

**Tecnologias:**
- fl_chart
- Firebase Analytics

**Estimativa:** 3 semanas

---

#### 📄 Exportação de Relatórios
- [ ] Personal exporta PDF com:
  - Anamnese completa do aluno
  - Insights da IA
  - Histórico de treinos
  - Evolução de medidas
  - Gráficos de progresso
- [ ] Aluno exporta PDF com:
  - Treino atual
  - Histórico de execuções
  - Evolução pessoal
- [ ] Envio por email

**Tecnologias:**
- pdf package
- printing package
- Firebase Storage

**Estimativa:** 2 semanas

---

#### 🎨 Melhorias de UI/UX
- [ ] Animações de transição
- [ ] Skeleton screens (loading)
- [ ] Pull-to-refresh
- [ ] Bottom sheets para ações
- [ ] Snackbars para feedback
- [ ] Dark mode
- [ ] Onboarding para novos usuários
- [ ] Tour guiado das funcionalidades
- [ ] Acessibilidade (screen readers)

**Tecnologias:**
- Animations API do Flutter
- shimmer para skeleton
- introduction_screen para onboarding

**Estimativa:** 4 semanas

---

**Total Fase 3:** ~25 semanas (6 meses)

---

## Fase 4 - Monetização 📅 (Planejado)

**Período:** Janeiro - Junho 2027  
**Status:** 📅 Planejado

### Objetivo
Transformar o app em um negócio sustentável com planos de assinatura e recursos premium.

### Modelo de Negócio

#### 💰 Planos de Assinatura (Personal Trainers)

| Plano | Preço/mês | Alunos | Features |
|-------|-----------|--------|----------|
| **Free** | R$ 0 | Até 5 | Treinos básicos, 1 anamnese/mês |
| **Starter** | R$ 49 | Até 20 | Anamnese ilimitada, Chat, Analytics básico |
| **Pro** | R$ 99 | Até 50 | Tudo do Starter + Relatórios PDF, Sugestões IA ilimitadas |
| **Enterprise** | R$ 199 | Ilimitado | Tudo do Pro + API access, White-label, Suporte prioritário |

#### ⭐ Features Premium

**Alunos (opcionais):**
- [ ] Acesso a biblioteca de exercícios com vídeos HD
- [ ] Planos de nutrição (integração futura)
- [ ] Treinos em grupo
- [ ] Gamificação (badges, conquistas)

**Preço:** R$ 9,90/mês (opcional, aluno decide)

---

### Funcionalidades Planejadas

#### 💳 Sistema de Pagamentos
- [ ] Integração com Stripe
- [ ] Planos de assinatura
- [ ] Período de teste grátis (7 dias)
- [ ] Upgrade/downgrade de planos
- [ ] Gerenciamento de faturas
- [ ] Cancelamento de assinatura
- [ ] Webhooks para renovação automática

**Tecnologias:**
- Stripe SDK
- Cloud Functions para webhooks
- Firestore para gerenciar assinaturas

**Estimativa:** 6 semanas

---

#### 📊 Dashboard de Métricas (Personal)
- [ ] Receita mensal
- [ ] Taxa de retenção de alunos
- [ ] Anamneses criadas vs. concluídas
- [ ] Engajamento por aluno
- [ ] Tempo médio de resposta (chat)
- [ ] Exercícios mais utilizados
- [ ] Exportação de dados (CSV)

**Tecnologias:**
- Firebase Analytics
- Cloud Functions para agregações
- fl_chart para gráficos

**Estimativa:** 4 semanas

---

#### 📱 Aplicativo Mobile Nativo (iOS)
- [ ] Build para App Store
- [ ] Otimizações de performance
- [ ] Push notifications nativas
- [ ] Apple Sign-In
- [ ] In-App Purchase (assinaturas)
- [ ] Widgets iOS

**Tecnologias:**
- Flutter iOS build
- Apple Developer Account
- StoreKit para IAP

**Estimativa:** 6 semanas

---

#### ⌚ Integração com Wearables
- [ ] Sincronização com Google Fit (Android)
- [ ] Sincronização com Apple Health (iOS)
- [ ] Importar dados de atividades
- [ ] Mostrar calorias queimadas
- [ ] Passos diários
- [ ] Frequência cardíaca durante treino

**Tecnologias:**
- health package
- HealthKit (iOS)
- Google Fit API (Android)

**Estimativa:** 5 semanas

---

#### 🌐 API Pública (Plano Enterprise)
- [ ] REST API para integrações
- [ ] Autenticação com API keys
- [ ] Webhooks para eventos:
  - Treino criado
  - Anamnese concluída
  - Aluno adicionado
- [ ] Rate limiting
- [ ] Documentação completa (Swagger)

**Tecnologias:**
- Cloud Functions para API
- Firebase Extensions
- Swagger/OpenAPI

**Estimativa:** 8 semanas

---

#### 🏷️ White-label (Plano Enterprise)
- [ ] Personal pode customizar:
  - Logo do app
  - Cores do tema
  - Nome do app
  - URL customizada
- [ ] Build personalizado para cada cliente
- [ ] Deploy isolado

**Tecnologias:**
- Firebase dynamic links
- Cloud Build para builds customizados
- Firebase Hosting custom domain

**Estimativa:** 10 semanas

---

#### 📧 Marketing e Retenção
- [ ] Email marketing (SendGrid/Mailchimp)
  - Boas-vindas
  - Lembrete de treino
  - Dicas semanais
- [ ] SMS notifications (Twilio)
- [ ] Programa de indicação (referral)
- [ ] Cupons de desconto
- [ ] A/B testing de features

**Tecnologias:**
- SendGrid API
- Twilio SMS
- Firebase Remote Config para A/B testing
- Cloud Functions para automações

**Estimativa:** 6 semanas

---

**Total Fase 4:** ~45 semanas (11 meses)

---

## Backlog de Ideias 💡

Features que podem ser implementadas no futuro:

### 🍎 Nutrição
- Planos alimentares
- Contagem de calorias
- Receitas saudáveis
- Integração com apps de nutrição

### 🎮 Gamificação
- Sistema de pontos
- Badges e conquistas
- Ranking entre alunos
- Desafios semanais
- Recompensas por constância

### 🧘 Bem-estar
- Meditação guiada
- Dicas de sono
- Gestão de estresse
- Diário de humor

### 👥 Social
- Feed de atividades (estilo rede social)
- Curtir/comentar treinos
- Comunidade de alunos
- Grupos de treino

### 🤖 IA Avançada
- Análise de vídeo de execução
- Correção de postura em tempo real
- Previsão de lesões
- Ajuste automático de carga

### 📹 Conteúdo
- Biblioteca de vídeos de exercícios
- Lives de treino
- Cursos online para personals
- Certificações

---

## Cronograma Resumido

| Fase | Período | Duração | Status |
|------|---------|---------|--------|
| **Fase 1 - MVP** | Jan-Mar 2026 | 3 meses | ✅ Concluído |
| **Fase 2 - Anamnese IA** | Abr-Jun 2026 | 3 meses | ✅ Concluído |
| **Fase 3 - Melhorias** | Jul-Dez 2026 | 6 meses | 🔄 Em andamento |
| **Fase 4 - Monetização** | Jan-Jun 2027 | 6 meses | 📅 Planejado |

**Total:** 18 meses do início ao lançamento comercial

---

## Métricas de Sucesso

### Fase 3
- [ ] 80% dos alunos completam anamnese
- [ ] Tempo médio de resposta de chat < 1h
- [ ] 90% dos alunos registram pelo menos 1 treino/semana
- [ ] NPS (Net Promoter Score) > 50

### Fase 4
- [ ] 100 personal trainers pagantes no primeiro mês
- [ ] Taxa de conversão Free → Starter > 15%
- [ ] Churn rate < 10%/mês
- [ ] MRR (Monthly Recurring Revenue) > R$ 10.000

---

## Próximos Passos Imediatos

### Curto Prazo (Próximas 2 semanas)
1. [ ] Implementar notificações push
2. [ ] Criar tela de chat
3. [ ] Configurar Firebase Cloud Messaging

### Médio Prazo (Próximo mês)
1. [ ] Implementar registro de medidas
2. [ ] Criar gráficos de evolução
3. [ ] Adicionar dark mode

### Longo Prazo (Próximos 3 meses)
1. [ ] Finalizar Fase 3
2. [ ] Começar planejamento detalhado da Fase 4
3. [ ] Validar modelo de negócio com beta testers

---

## Contribuições

Quer sugerir uma feature? Abra uma issue no GitHub com a tag `feature-request`!

---

**Última atualização:** Junho 2026  
**Versão do Roadmap:** 1.0.0
