![New Gym App](assets/images/profile.png)



## Índice
* [Objetivo](#objetivo)
* [Escopo](#escopo)
* [Contexto](#contexto)
* [Restrições](#restrições)
* [Trade-offs](#trade-offs)
* [C4 Model](#c4-model)
* [Requisitos e Casos de Uso](#requisitos-e-casos-de-uso)
* [Modelagem](#modelagem)
* [Instalação](#instalação)
* [Stacks](#stacks)

## Objetivo

Este projeto tem como objetivo principal ser um sistema inteligente de gestão de treinos, o **New Gym App**, com foco em conectar personal trainers e alunos por meio da **Inteligência Artificial**. A plataforma permite que personal trainers criem anamneses personalizadas, analisem o perfil de saúde dos alunos com apoio do Google Gemini e gerem sugestões de treino fundamentadas em diretrizes científicas (ACSM e NSCA), tornando o processo de prescrição mais eficiente, seguro e individualizado.

## Escopo

**Coleta de dados**

- Dados do Usuário: Coletamos informações de cadastro como nome, e-mail, senha e CREF (para personal trainers), armazenados com autenticação via Firebase Auth;
- Dados de Saúde do Aluno: Coletamos respostas da anamnese com 22 perguntas base para todos os perfis, acrescidas de perguntas específicas por sexo biológico (feminino: hormônios, gestação, saúde óssea; masculino: hérnias, uso hormonal, sintomas de alteração hormonal) e perguntas diagnósticas geradas dinamicamente pela IA;
- Dados de Treino: Registramos exercícios, séries, repetições, observações técnicas e justificativas científicas de cada sugestão aprovada pelo personal;
- Logs e Insights: A IA gera e armazena insights de saúde, nível de condicionamento, risco de lesão e recomendações de prescrição para cada anamnese analisada;
- Análise de Uso: O Firebase Analytics permite monitorar o comportamento dos usuários para futuras melhorias na plataforma.

**Pré-processamento e IA**

- O Google Gemini (modelo `gemini-3.5-flash`) analisa as respostas da anamnese e gera perguntas diagnósticas adaptadas ao perfil de cada aluno. Em seguida, uma segunda chamada à API gera sugestões de treino personalizadas com base científica (ACSM/NSCA), sem depender de uma biblioteca local de exercícios — os exercícios são criados automaticamente na base ao serem aprovados pelo personal;
- O contexto enviado à IA inclui a data atual e a idade calculada do aluno, garantindo precisão nas análises relacionadas à faixa etária e histórico de saúde.

**Design de Interface**

- Todas as telas seguem o Material Design 3 com tema personalizado. O fluxo foi desenhado separando as experiências do personal trainer (gestão, análise, aprovação) e do aluno (anamnese progressiva, visualização de treinos), com navegação por abas adaptada ao perfil do usuário.

**Desenvolvimento**

- O projeto é desenvolvido em Flutter com arquitetura feature-first, gerenciamento de estado via Riverpod e navegação com GoRouter. O backend é inteiramente gerenciado pelo Firebase (Auth + Firestore), sem necessidade de servidor dedicado.

**Qualidade**

- Para garantir a qualidade e a consistência do código, é utilizado `flutter analyze` e `flutter_lints`, assegurando que boas práticas de desenvolvimento Flutter/Dart sejam seguidas em todo o projeto.

**CI/CD**

- O controle de versão é realizado com Git e GitHub. Arquivos sensíveis como `firebase_options.dart` e `.env` (com a chave Gemini) são mantidos fora do repositório via `.gitignore`, sendo configurados manualmente em cada ambiente.

**Observabilidade**

- O Firebase é utilizado para monitoramento, incluindo rastreamento de erros e análise de eventos. Os logs gerados pelo Flutter e pelo Firestore permitem rastrear o ciclo completo de uma anamnese, desde a criação até a aprovação do treino.

## Contexto

O mercado de personal trainers enfrenta um desafio recorrente: a coleta e análise de informações de saúde dos alunos é feita de forma manual, muitas vezes por fichas físicas ou planilhas genéricas, sem personalização e sem embasamento científico sistemático. O New Gym App surge como solução a esse problema, digitalizando e inteligentemente o processo de anamnese, tornando a prescrição de treinos mais segura, rápida e fundamentada em evidências, tanto para alunos iniciantes quanto para os mais avançados.

## Restrições

- **Chave de API Gemini:** A funcionalidade de IA depende de uma chave de API do Google Gemini configurada via variável de ambiente (`--dart-define-from-file=.env`), exigindo rebuild completo do app a cada alteração;
- **Firebase:** O projeto depende de um projeto Firebase configurado manualmente (`firebase_options.dart`), o que restringe a portabilidade imediata para novos ambientes sem reconfiguração;
- **Recursos Financeiros:** Por se tratar de um TCC, o projeto opera dentro dos limites gratuitos do Firebase e da cota gratuita da API Gemini, o que pode limitar o volume de requisições em escala;
- **Modelos de IA:** O modelo `gemini-2.0-flash` foi descontinuado pelo Google durante o desenvolvimento; o projeto foi migrado para `gemini-3.5-flash`, o que demonstra a dependência da disponibilidade dos modelos externos.

## Trade-offs

- **Portabilidade:**

O aplicativo é desenvolvido em Flutter, permitindo execução em Android, iOS, Web e Desktop a partir de um único código-base. Para o contexto do TCC, o foco de testes é no Android (emulador) e Web (Chrome).

- **Funcionalidade:**

O sistema opta por perguntas dinâmicas geradas por IA em vez de um formulário estático extenso, tornando a anamnese mais conversacional e personalizada. A troca é uma dependência de chamadas à API externa, que adicionam latência e custo por requisição.

- **Confiabilidade:**

O Firestore garante sincronização em tempo real e persistência dos dados. A dependência da API Gemini representa um ponto de falha externo; por isso, erros da IA são tratados com mensagens amigáveis sem quebrar o fluxo do usuário.

- **Usabilidade:**

A anamnese é apresentada progressivamente (uma pergunta por vez) para reduzir a sobrecarga cognitiva do aluno. Perguntas específicas por sexo biológico são injetadas automaticamente sem interromper o fluxo, mantendo a experiência fluida.

- **Eficiência:**

O sistema foi otimizado para reduzir chamadas à API: uma única chamada gera o lote de perguntas diagnósticas e outra gera as sugestões de treino. Isso reduziu o custo estimado por anamnese de R$ 0,40 (37+ chamadas) para aproximadamente R$ 0,08 (2 chamadas).

- **Manutenibilidade:**

A arquitetura feature-first com Riverpod separa claramente responsabilidades por domínio (auth, anamnesis, students, profile), facilitando a manutenção e a adição de novas funcionalidades sem impacto nas existentes.

## C4 Model

Os diagramas com base no modelo C4 se encontram em [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Requisitos e Casos de Uso

Os requisitos funcionais e não funcionais se encontram [aqui.](docs/requisitos.md)

## Modelagem

O planejamento das funcionalidades e o cronograma de desenvolvimento foram organizados em fases:

- **Fase 1 — MVP:** Autenticação, gestão de alunos, CRUD de exercícios e criação de treinos;
- **Fase 2 — Anamnese IA:** Integração com Gemini, perguntas dinâmicas, insights automáticos, sugestões RAG com base ACSM/NSCA;
- **Fase 3 — Melhorias (em andamento):** Notificações push, chat personal-aluno, acompanhamento de progresso, exportação de relatórios.

A estrutura do banco de dados Firestore e os fluxos de dados estão documentados em [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Instalação

```bash
# 1. Clonar o repositório
git clone https://github.com/seu-usuario/new_gym_app.git
cd new_gym_app

# 2. Instalar dependências
flutter pub get

# 3. Configurar Firebase (criar firebase_options.dart)
flutterfire configure

# 4. Configurar Gemini API Key
# Criar arquivo .env na raiz:
# GEMINI_API_KEY=sua_chave_aqui

# 5. Executar
flutter run -d emulator-5554 --dart-define-from-file=.env
```

**Primeiro acesso:**
1. Criar conta de Personal Trainer (incluir CREF)
2. Cadastrar um aluno de teste
3. Criar uma anamnese e acompanhar o fluxo completo
4. Visualizar os insights da IA e aprovar a sugestão de treino

## Stacks

**Core:**
- [Flutter](https://flutter.dev/) 3.9.2 — framework multiplataforma
- [Dart](https://dart.dev/) 3 — linguagem de programação
- [Riverpod](https://riverpod.dev/) ^3.0.1 — gerenciamento de estado
- [GoRouter](https://pub.dev/packages/go_router) ^16.2.4 — navegação declarativa

**Backend e Autenticação:**
- [Firebase Auth](https://firebase.google.com/products/auth) ^5.3.3 — autenticação de usuários
- [Cloud Firestore](https://firebase.google.com/products/firestore) ^5.5.2 — banco de dados NoSQL em tempo real

**Inteligência Artificial:**
- [Google Gemini](https://ai.google.dev/) (`gemini-3.5-flash`) via `google_generative_ai` ^0.4.7
- Arquitetura RAG para sugestões de treino com base em ACSM Guidelines 2021 e NSCA Essentials

**Utilitários:**
- [flutter_localizations](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization) — suporte a pt_BR
- [http](https://pub.dev/packages/http) ^1.2.0 — requisições HTTP
