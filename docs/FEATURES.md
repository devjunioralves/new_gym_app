# Funcionalidades — New Gym App

## Visão Geral

O sistema possui dois perfis de usuário com experiências distintas:

| Perfil | Acesso |
|--------|--------|
| **Personal Trainer** | Gestão completa de alunos, exercícios, treinos e anamneses com IA |
| **Aluno** | Resposta à anamnese e visualização dos treinos atribuídos |

---

## Personal Trainer

| Funcionalidade | Descrição | Status |
|----------------|-----------|--------|
| Autenticação | Cadastro com CREF, login e logout | ✅ |
| Gestão de alunos | Cadastrar, visualizar, buscar e filtrar alunos vinculados | ✅ |
| Biblioteca de exercícios | Criar, editar e remover exercícios com instruções e grupo muscular | ✅ |
| Criação de treinos | Montar treinos personalizados e atribuí-los aos alunos | ✅ |
| Criação de anamnese | Criar e atribuir anamnese a um aluno específico | ✅ |
| Visualização de insights | Acessar resumo de saúde, nível de condicionamento, risco de lesão e recomendações gerados pela IA | ✅ |
| Sugestões de treino (RAG) | Solicitar planos de treino gerados com base em ACSM/NSCA, com justificativa científica | ✅ |
| Revisão e aprovação | Editar exercícios, séries e repetições da sugestão antes de aprovar e criar o treino | ✅ |

---

## Aluno

| Funcionalidade | Descrição | Status |
|----------------|-----------|--------|
| Autenticação | Cadastro e login via conta criada pelo personal | ✅ |
| Resposta à anamnese | Interface progressiva com uma pergunta por vez e barra de progresso | ✅ |
| Perguntas dinâmicas | Perguntas específicas por sexo biológico e diagnósticas geradas pela IA | ✅ |
| Visualização de treinos | Consultar exercícios, séries, repetições e instruções dos treinos atribuídos | ✅ |

---

## Sistema de Anamnese com IA

O fluxo completo está detalhado em [ARCHITECTURE.md](ARCHITECTURE.md). Resumo das etapas:

1. **Perguntas base** — 22 perguntas fixas cobrindo saúde geral, histórico clínico e objetivos
2. **Injeção por sexo** — Após q2, perguntas específicas são adicionadas automaticamente (feminino: qf1–qf7; masculino: qm1–qm3)
3. **Perguntas diagnósticas** — A IA gera de 3 a 5 perguntas personalizadas com base nas respostas anteriores
4. **Análise e insights** — Ao finalizar, a IA analisa a anamnese completa e gera o relatório de saúde
5. **Sugestão de treino** — RAG com ACSM/NSCA gera plano personalizado com exercícios livres
6. **Aprovação** — Personal revisa, edita e aprova; exercícios são persistidos na biblioteca via `findOrCreateByName`

---

**Última atualização:** Junho 2026
