# New Gym App 💪

![Flutter](https://img.shields.io/badge/Flutter-3.38.2-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10.0-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Cloud-FFCA28?logo=firebase)
![AI](https://img.shields.io/badge/AI-Gemini_1.5_Pro-4285F4?logo=google)
![Status](https://img.shields.io/badge/Status-Em_Desenvolvimento-green)
![License](https://img.shields.io/badge/License-MIT-blue)

> **Sistema inteligente de gestão de treinos** que conecta personal trainers e alunos com o poder da **Inteligência Artificial** para personalização científica.

---

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Demo e Screenshots](#demo-e-screenshots)
- [Principais Funcionalidades](#principais-funcionalidades)
- [Quick Start](#quick-start)
- [Documentação](#documentação)
- [Status do Projeto](#status-do-projeto)
- [Tecnologias](#tecnologias)
- [Contribuindo](#contribuindo)
- [Licença](#licença)
- [Contato](#contato)

## 🎯 Sobre o Projeto

O **New Gym App** revoluciona a gestão de treinos ao combinar tecnologia moderna com ciência do exercício. Personal trainers podem criar, gerenciar e otimizar treinos para seus alunos, enquanto a **Inteligência Artificial** (Google Gemini) analisa anamneses de saúde e sugere exercícios personalizados baseados em guidelines científicas (ACSM, NSCA).

### 💡 Diferenciais

- 🤖 **IA Adaptativa**: Anamnese com perguntas dinâmicas que se adaptam às respostas do aluno
- 📊 **Base Científica**: Sugestões de treino fundamentadas em ACSM Guidelines 2021 e NSCA Essentials
- ⚡ **Real-time**: Sincronização instantânea com Firebase
- 📱 **Multiplataforma**: Web, Android, iOS - um único código
- 🔒 **Segurança**: Conformidade com LGPD para dados de saúde
- 💰 **Custo-benefício**: ~R$ 0,08 por anamnese completa

### 🎯 Objetivos

| Para Personal Trainers | Para Alunos |
|------------------------|-------------|
| ⚡ Reduzir tempo de planejamento | 📝 Anamnese digital intuitiva |
| 🎯 Treinos baseados em evidências | 💪 Treinos personalizados |
| 📊 Acompanhar progresso em tempo real | 📱 Acesso fácil aos treinos |
| 🤖 Insights automáticos de saúde | ✨ Experiência guiada |

---

## 🎬 Demo e Screenshots

> 🚧 **Em desenvolvimento** - Screenshots e vídeos serão adicionados em breve!

<!-- Seção para adicionar GIFs e imagens quando disponíveis -->

---

## ✨ Principais Funcionalidades

### 👨‍💼 Para Personal Trainers

<table>
<tr>
<td width="50%">

**👥 Gestão de Alunos**
- Cadastrar e gerenciar alunos
- Buscar e filtrar
- Visualizar histórico completo
- Vincular automaticamente

**💪 Gestão de Exercícios**
- Biblioteca completa
- Criar exercícios customizados
- Filtrar por tipo de treino
- Instruções detalhadas

</td>
<td width="50%">

**📋 Gestão de Treinos**
- Criar treinos personalizados
- Atribuir exercícios
- Definir séries, reps, carga
- Editar e duplicar treinos

**🤖 Anamnese Inteligente (IA)**
- 37 perguntas base + dinâmicas
- Análise automática de saúde
- Insights sobre condicionamento
- **3 sugestões de treino com base científica**

</td>
</tr>
</table>

### 🏃 Para Alunos

- 📝 **Responder anamnese** progressivamente (uma pergunta por vez)
- 💪 **Visualizar treinos** atribuídos pelo personal
- 📊 **Acompanhar progresso** (em desenvolvimento)
- 💬 **Chat com personal** (planejado)

### 🤖 Destaques da IA

| Feature | Descrição |
|---------|----------|
| **Perguntas Dinâmicas** | IA gera perguntas de follow-up baseadas em respostas anteriores |
| **Análise de Saúde** | Identifica condições, limitações e risco de lesão (0-100) |
| **Sugestões Científicas** | RAG com ACSM Guidelines 2021 + NSCA Essentials |
| **Justificativa Completa** | Cada exercício sugerido vem com embasamento científico |
| **Precauções** | Lista automática de exercícios a evitar por condição |

📖 **[Ver funcionalidades completas →](docs/FEATURES.md)**

---

## 🚀 Quick Start

### Pré-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.38.2 ou superior
- [Firebase CLI](https://firebase.google.com/docs/cli) instalado
- [Gemini API Key](https://ai.google.dev/) (gratuita)
- Git

### Instalação em 5 Passos

```bash
# 1. Clonar o repositório
git clone https://github.com/seu-usuario/new_gym_app.git
cd new_gym_app

# 2. Instalar dependências
flutter pub get

# 3. Configurar Firebase
flutterfire configure

# 4. Configurar Gemini API Key
# Edite lib/features/anamnesis/presentation/providers/anamnesis_providers.dart
# Linha 15: const apiKey = 'SUA_CHAVE_AQUI';

# 5. Executar
flutter run -d chrome
```

### Primeiro Acesso

1. Crie uma conta de **Personal Trainer** (inclua CREF)
2. Adicione alguns **exercícios** na biblioteca
3. Cadastre um **aluno** de teste
4. Crie uma **anamnese** e teste o fluxo completo
5. Veja os **insights da IA** e as **sugestões de treino**!

📖 **[Guia completo de instalação →](docs/INSTALLATION.md)**

---

## 📚 Documentação

### 📝 Documentação Principal

| Documento | Descrição |
|-----------|----------|
| **[Arquitetura](docs/ARCHITECTURE.md)** | Estrutura do projeto, padrões, fluxos de dados, modelo de dados Firestore |
| **[Funcionalidades](docs/FEATURES.md)** | Lista completa de features, permissões, regras de segurança |
| **[Instalação](docs/INSTALLATION.md)** | Guia passo a passo, configuração Firebase/Gemini, troubleshooting |
| **[Roadmap](docs/ROADMAP.md)** | Planejamento de desenvolvimento, 4 fases, features futuras |
| **[Stack Técnica](docs/TECH_STACK.md)** | Tecnologias utilizadas, justificativas, comparações, custos |

### 🔥 Documentação Técnica Específica

| Documento | Descrição |
|-----------|----------|
| [ANAMNESE_IA_STATUS.md](ANAMNESE_IA_STATUS.md) | Status completo da implementação, guia de uso, análise de custos |
| [FIREBASE_SETUP.md](FIREBASE_SETUP.md) | Configuração do Firebase, estrutura do banco |
| [FIRESTORE_SECURITY_RULES.md](FIRESTORE_SECURITY_RULES.md) | Regras de segurança detalhadas, proteção LGPD |
| [SISTEMA_PERMISSOES.md](SISTEMA_PERMISSOES.md) | Sistema de roles (Personal/Student), controle de acesso |
| [SISTEMA_TREINOS_CONCLUIDO.md](SISTEMA_TREINOS_CONCLUIDO.md) | Sistema completo de treinos, fluxos, providers |

---

## 📈 Status do Projeto

### Fases Concluídas

| Fase | Período | Status |
|------|---------|--------|
| **Fase 1 - MVP** | Jan-Mar 2026 | ✅ 100% Concluído |
| **Fase 2 - Anamnese IA** | Abr-Jun 2026 | ✅ 100% Concluído |

### Fase 1 - MVP ✅
- ✅ Autenticação (Firebase Auth)
- ✅ Gestão de alunos
- ✅ CRUD de exercícios
- ✅ Criação de treinos
- ✅ Visualização de treinos

### Fase 2 - Anamnese IA ✅
- ✅ 37 perguntas base estruturadas
- ✅ Integração Gemini 1.5-pro
- ✅ Perguntas dinâmicas adaptativas
- ✅ Análise automática de insights
- ✅ Sugestões de treino com RAG
- ✅ Base científica (ACSM, NSCA)
- ✅ 4 telas completas implementadas
- ✅ Documentação completa

### Fase 3 - Melhorias 🔄 (Em Andamento)

**Próximos passos:**
- [ ] Notificações push (Firebase Cloud Messaging)
- [ ] Chat personal-aluno (Firestore real-time)
- [ ] Acompanhamento de progresso (medidas, gráficos)
- [ ] Registro de execução de treinos
- [ ] Exportação de relatórios (PDF)
- [ ] Melhorias de UI/UX (dark mode, animações)

📖 **[Ver roadmap completo →](docs/ROADMAP.md)**

### Análise Estática

```bash
flutter analyze
```

**Resultado atual:**
- ✅ **0 erros**
- ⚠️ 12 info warnings (avoid_print, deprecated withOpacity)
- 🟢 Sistema pronto para produção

---

## 🛠️ Tecnologias

### Core Stack

<table>
<tr>
<td align="center" width="20%">
<img src="https://storage.googleapis.com/cms-storage-bucket/ec64036b4eacc9f3fd73.svg" width="50" height="50" alt="Flutter"/><br>
<b>Flutter</b><br>
3.38.2
</td>
<td align="center" width="20%">
<img src="https://upload.wikimedia.org/wikipedia/commons/7/7e/Dart-logo.png" width="50" height="50" alt="Dart"/><br>
<b>Dart</b><br>
3.10.0
</td>
<td align="center" width="20%">
<img src="https://firebase.google.com/static/downloads/brand-guidelines/SVG/logo-logomark.svg" width="50" height="50" alt="Firebase"/><br>
<b>Firebase</b><br>
Auth + Firestore
</td>
<td align="center" width="20%">
<img src="https://www.gstatic.com/lamda/images/gemini_sparkle_v002_d4735304ff6292a690345.svg" width="50" height="50" alt="Gemini"/><br>
<b>Gemini</b><br>
1.5-pro
</td>
<td align="center" width="20%">
<img src="https://riverpod.dev/img/logo.svg" width="50" height="50" alt="Riverpod"/><br>
<b>Riverpod</b><br>
3.0.1
</td>
</tr>
</table>

### Principais Dependências

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^3.0.1
  
  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  
  # IA
  google_generative_ai: ^0.4.0
  
  # Navegação
  go_router: ^16.2.4
  
  # Utils
  http: ^1.2.0
  intl: ^0.19.0
```

### Custos Estimados (1000 alunos/mês)

| Serviço | Uso | Custo |
|---------|-----|-------|
| **Firestore** | 500k leituras + 200k escritas | $5 |
| **Gemini API** | 1000 anamneses completas | $15 |
| **Firebase Hosting** | 10 GB transferência | Grátis |
| **Firebase Auth** | 1000 usuários | Grátis |
| **Total** | | **~$20/mês** |

**Custo por aluno:** $0.02/mês (R$ 0,10/mês)

📖 **[Detalhes da stack técnica →](docs/TECH_STACK.md)**

---

## 🤝 Contribuindo

Contribuições são muito bem-vindas! Siga os passos abaixo:

### 1. Fork o Projeto

Clique no botão **Fork** no topo da página.

### 2. Crie uma Branch

```bash
git checkout -b feature/MinhaFeature
```

### 3. Commit suas Mudanças

Use [Conventional Commits](https://www.conventionalcommits.org/):

```bash
git commit -m 'feat: adiciona nova funcionalidade X'
git commit -m 'fix: corrige bug Y'
git commit -m 'docs: atualiza documentação Z'
```

### 4. Push para a Branch

```bash
git push origin feature/MinhaFeature
```

### 5. Abra um Pull Request

- Descreva as mudanças claramente
- Adicione screenshots se aplicável
- Referencie issues relacionadas

### Diretrizes

- ✅ Siga os padrões de código Flutter/Dart
- ✅ Execute `flutter analyze` antes de commitar
- ✅ Documente novas funcionalidades
- ✅ Adicione testes quando possível
- ✅ Mantenha commits pequenos e focados

---

## 📜 Licença

Este projeto está sob a licença **MIT**. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

```
MIT License

Copyright (c) 2026 Junior Trindade

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 📞 Contato

**Desenvolvedor:** Junior Trindade

- 📧 Email: [seu-email@example.com](mailto:seu-email@example.com)
- 🐔 LinkedIn: [seu-linkedin](https://linkedin.com/in/seu-linkedin)
- 🐛 GitHub: [@seu-usuario](https://github.com/seu-usuario)
- 🌐 Portfolio: [seu-portfolio.com](https://seu-portfolio.com)

### Links do Projeto

- 🐛 **Repositório:** [github.com/seu-usuario/new_gym_app](https://github.com/seu-usuario/new_gym_app)
- 🐞 **Issues:** [github.com/seu-usuario/new_gym_app/issues](https://github.com/seu-usuario/new_gym_app/issues)
- 💬 **Discussões:** [github.com/seu-usuario/new_gym_app/discussions](https://github.com/seu-usuario/new_gym_app/discussions)

---

## 🚀 Agradecimentos

Este projeto não seria possível sem:

- **[Google Gemini](https://ai.google.dev/)** - API de IA generativa
- **[Firebase](https://firebase.google.com/)** - Backend as a Service
- **[Flutter](https://flutter.dev/)** - Framework multiplataforma
- **[ACSM](https://www.acsm.org/)** & **[NSCA](https://www.nsca.com/)** - Guidelines científicas
- **Flutter Community** - Packages e suporte incríveis

---

<div align="center">

**🏋️ New Gym App** - Transformando treinos com IA

**Status:** 🟢 Em Desenvolvimento Ativo | **Versão:** 1.0.0 | **Última atualização:** Junho 2026

Feito com ❤️ e ☕ por [Junior Trindade](https://github.com/seu-usuario)

[Documentação](docs/) • [Issues](https://github.com/seu-usuario/new_gym_app/issues) • [Roadmap](docs/ROADMAP.md)

</div>
