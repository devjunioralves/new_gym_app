# Roadmap — New Gym App

## Cronograma

| Fase | Período | Status |
|------|---------|--------|
| Fase 1 — MVP | Janeiro – Março 2026 | ✅ Concluído |
| Fase 2 — Anamnese com IA | Abril – Junho 2026 | ✅ Concluído |
| Fase 3 — Melhorias | Julho – Dezembro 2026 | 🔄 Em andamento |

---

## Fase 1 — MVP ✅

Estabeleceu a base funcional do sistema:

- Autenticação de Personal Trainers (com CREF) e Alunos via Firebase Auth
- Gestão de alunos: cadastro, listagem, busca e vínculo automático ao personal
- Biblioteca de exercícios: criar, editar e remover com filtro por grupo muscular
- Criação e atribuição de treinos personalizados

---

## Fase 2 — Anamnese com IA ✅

Implementou o diferencial central do projeto:

- Template de 22 perguntas base sobre saúde, histórico clínico e objetivos
- Injeção dinâmica de perguntas por sexo biológico (qf1–qf7 / qm1–qm3)
- Integração com Google Gemini: geração de perguntas diagnósticas personalizadas
- Análise completa da anamnese: insights de saúde, nível de condicionamento, risco de lesão e recomendações
- RAG com ACSM/NSCA: geração livre de sugestões de treino com justificativa científica
- Aprovação pelo personal com edição antes de criar o treino

---

## Fase 3 — Melhorias 🔄

Funcionalidades planejadas para aprimorar a experiência:

- [ ] Notificações push (Firebase Cloud Messaging)
- [ ] Chat em tempo real entre personal e aluno
- [ ] Acompanhamento de progresso com gráficos de evolução
- [ ] Registro de execução de treinos (carga, séries concluídas)
- [ ] Exportação de relatório em PDF

---

**Última atualização:** Junho 2026
