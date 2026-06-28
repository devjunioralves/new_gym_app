# 📄 CHEAT SHEET TCC - CONSULTA RÁPIDA (1 PÁGINA)

## 🎯 PROJETO: NEW GYM APP

**Sistema de gerenciamento de academia com IA para anamnese e prescrição de treinos**

---

## 📊 NÚMEROS-CHAVE

- **18 telas** funcionais
- **12 modelos** de dados
- **8 services** (Firebase + IA)
- **R$ 0,08/aluno** custo IA
- **52.6 MB** APK release
- **4 plataformas** (Android, iOS, Web, Desktop)
- **37 perguntas** base (template real)
- **3 sugestões** de treino por anamnese

---

## 💻 STACK TECNOLÓGICO

| Camada        | Tecnologia    | Versão  | Por quê?                |
| ------------- | ------------- | ------- | ----------------------- |
| **Frontend**  | Flutter       | 3.38.2  | Multiplataforma nativo  |
| **Linguagem** | Dart          | 3.10.0  | Type-safe, performance  |
| **Estado**    | Riverpod      | 3.0.1   | Reactive, testável      |
| **Backend**   | Firebase      | -       | Real-time, escalável    |
| **DB**        | Firestore     | NoSQL   | Flexível, offline-first |
| **Auth**      | Firebase Auth | -       | Enterprise-grade        |
| **IA**        | Gemini        | 1.5-pro | LLM estado da arte      |
| **Nav**       | GoRouter      | 16.2.4  | Declarativo, type-safe  |

---

## 🏗️ ARQUITETURA

**Feature-First + Clean Architecture Simplificada**

```
lib/
├── core/           → Compartilhado (models, services, config)
└── features/       → Módulos isolados
    ├── auth/       → Login, registro
    ├── students/   → CRUD alunos + treinos
    ├── exercises/  → Biblioteca exercícios
    └── anamnesis/  → Sistema IA ⭐
        ├── models/     → Anamnesis, Insights, Suggestions
        ├── services/   → Firebase, Gemini, RAG
        ├── providers/  → Riverpod state
        └── screens/    → 4 telas UI
```

---

## 🤖 FLUXO ANAMNESE (5 PASSOS)

**1. CRIAÇÃO** → Personal seleciona aluno → 37 perguntas base  
**2. RESPOSTA** → Aluno responde → IA gera perguntas dinâmicas → Ciclo  
**3. ANÁLISE** → IA analisa tudo → Gera Insights (condições, risco, fitness level)  
**4. RAG** → Filtra exercícios seguros → IA + ACSM/NSCA → 3 sugestões treino  
**5. APROVAÇÃO** → Personal revisa → Aprova → Cria treino

---

## 📐 PADRÕES DE PROJETO

| Padrão            | Aplicação             | Benefício              |
| ----------------- | --------------------- | ---------------------- |
| **Repository**    | Abstração Firebase    | Testável, desacoplado  |
| **Provider**      | Riverpod DI           | Type-safe, reactive    |
| **RAG**           | IA + Base científica  | Reduz alucinações      |
| **Feature-First** | Módulos isolados      | Escalável, manutenível |
| **Secondary App** | Firebase multi-tenant | Evita logout           |

---

## 🔒 SEGURANÇA

### Firebase Security Rules

```javascript
// Apenas personal e aluno veem anamnese
match /anamnesis/{id} {
  allow read: if isOwner(studentId) || isOwner(personalId);
  allow create: if isPersonal();
}
```

### LGPD/GDPR

✅ Criptografia TLS  
✅ Consentimento explícito  
✅ Direito ao esquecimento  
✅ Acesso auditável  
✅ API key não commitada

---

## 💰 VIABILIDADE ECONÔMICA

| Escala        | Custo IA/mês | Custo Firebase   | Total    |
| ------------- | ------------ | ---------------- | -------- |
| 100 alunos    | R$ 8         | R$ 0 (free tier) | R$ 8     |
| 1.000 alunos  | R$ 80        | R$ 0 (free tier) | R$ 80    |
| 10.000 alunos | R$ 800       | ~R$ 200          | R$ 1.000 |

**Modelo B2B:** R$ 50-100/mês por personal → Margem 80-90%

---

## 🎨 TELAS IMPLEMENTADAS

**Autenticação (2)**  
Login | Registro

**Exercícios (4)**  
Biblioteca | Criar | Detalhes | Gerenciar

**Alunos/Treinos (6)**  
Lista | Detalhes | Criar aluno | Criar treino | Editar treino | Ver treino

**Anamnese IA (4) ⭐**  
Lista | Criar | Responder | Insights + Sugestões

**Outras (2)**  
Home | Perfil

---

## 🔬 BASE CIENTÍFICA

### ACSM Guidelines 2021

- Iniciantes: 2-3x/sem, 40-60% 1RM
- Intermediários: 3-4x/sem, 60-80% 1RM
- Progressão: 2-10% semanal

### NSCA Essentials

- Descanso: 48-72h entre grupos
- Periodização
- Variação de estímulos

### Implementação

- Hardcoded nos prompts RAG
- Referências verificáveis nas sugestões
- Personal valida antes de aprovar

---

## 🚀 DIFERENCIAIS COMPETITIVOS

1. **Perguntas Dinâmicas** → Primeira app fitness BR com IA gerativa contextual
2. **RAG Científico** → ACSM + NSCA integrados, não apenas "ChatGPT"
3. **Custo Baixo** → R$ 0,08/aluno vs. R$ 5-10 de concorrentes
4. **Multiplataforma** → Single codebase, 4 plataformas
5. **Real-time** → StreamProvider everywhere, sem reload manual

---

## 📚 REFERÊNCIAS TÉCNICAS

**Livros:**  
• ACSM. _Guidelines for Exercise Testing_. 11th ed. 2021  
• NSCA. _Essentials of Strength Training_. 4th ed. 2016  
• Fowler. _Patterns of Enterprise Application_. 2002

**Docs:**  
• flutter.dev | firebase.google.com | riverpod.dev | ai.google.dev

---

## 💡 RESPOSTAS RÁPIDAS (Banca)

**"Por que Flutter?"**  
→ Performance nativa, hot reload, multiplataforma real, comunidade crescente BR

**"IA pode errar?"**  
→ Sim. Por isso: 1) RAG com base científica, 2) Personal sempre valida, 3) Referências verificáveis

**"Por que Firebase?"**  
→ Real-time nativo, escalabilidade auto, custo zero inicial, foco em lógica de negócio

**"Custo IA?"**  
→ R$ 0,08/aluno. Escalável. Alternativas: cache, modelos open-source (LLaMA), repassar no B2B

**"Testou com usuários?"**  
→ Validação manual. Template de 37 perguntas validado por personal real. Próximo: beta 10 personais

---

## ⏱️ ESTRUTURA APRESENTAÇÃO (10 min)

| Tempo     | Tópico          | Foco                     |
| --------- | --------------- | ------------------------ |
| 1 min     | Introdução      | Problema + Solução       |
| 1.5 min   | Stack           | Tecnologias + Por quê    |
| 1.5 min   | Arquitetura     | Padrões + Estrutura      |
| 1 min     | Funcionalidades | 18 telas, visão geral    |
| **3 min** | **Anamnese IA** | **Fluxo 5 passos + RAG** |
| 1 min     | Segurança       | LGPD + Firebase Rules    |
| 0.5 min   | Viabilidade     | Custos + Modelo B2B      |
| 0.5 min   | Demo            | Mostrar telas            |

---

## ✅ CHECKLIST DEFESA

**Antes:**  
□ Cronometrar apresentação (9-10 min)  
□ App rodando (Chrome ou Android)  
□ VS Code aberto (mostrar código)  
□ Água/chá  
□ Chegar 15 min antes

**Durante:**  
□ Respirar fundo  
□ Contato visual  
□ Pausar entre slides  
□ Sorrir (confiança)

**Perguntas:**  
□ Escutar INTEIRA  
□ Repetir (ganha tempo)  
□ Responder objetivamente  
□ Se não souber: "Vou pesquisar"

---

**BOA SORTE! VOCÊ DOMINA O PROJETO! 💪**

---

## 🎓 DADOS PARA MEMORIZAR

**Gemini API:**  
• Modelo: gemini-1.5-pro  
• Temp: 0.7 (análise), 0.8 (criação)  
• ~10K tokens/aluno  
• $0.00025 input, $0.00075 output

**Firebase:**  
• Tier Free: 50K reads/day  
• Suficiente: ~500 users/dia  
• Real-time: <100ms latency

**Flutter:**  
• Release: 3.38.2  
• Dart: 3.10.0  
• Build: ~30s  
• Hot Reload: <1s

**Firestore Collections:**  
users | exercises | workouts | **anamnesis** | anamnesis/insights | workoutSuggestions
