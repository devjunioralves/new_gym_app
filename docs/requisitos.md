# Requisitos e Casos de Uso — New Gym App

## Índice
- [Requisitos Funcionais](#requisitos-funcionais)
- [Requisitos Não Funcionais](#requisitos-não-funcionais)
- [Casos de Uso](#casos-de-uso)

---

## Requisitos Funcionais

| ID | Descrição | Ator | Status |
|----|-----------|------|--------|
| RF01 | O sistema deve permitir cadastro e autenticação de Personal Trainers (com CREF) e Alunos | Ambos | ✅ |
| RF02 | O sistema deve diferenciar permissões de acesso por perfil (Personal vs. Aluno) | Sistema | ✅ |
| RF03 | O Personal deve poder cadastrar, editar e remover alunos vinculados ao seu perfil | Personal | ✅ |
| RF04 | O Personal deve poder gerenciar uma biblioteca de exercícios (criar, editar, remover) | Personal | ✅ |
| RF05 | O Personal deve poder criar e atribuir treinos personalizados aos alunos | Personal | ✅ |
| RF06 | O Personal deve poder criar uma anamnese e atribuí-la a um aluno | Personal | ✅ |
| RF07 | O sistema deve apresentar a anamnese ao aluno de forma progressiva (uma pergunta por vez) | Aluno | ✅ |
| RF08 | O sistema deve injetar perguntas específicas por sexo biológico após a resposta da questão correspondente | Sistema | ✅ |
| RF09 | Ao concluir as perguntas base, a IA deve gerar de 3 a 5 perguntas diagnósticas personalizadas | IA | ✅ |
| RF10 | Ao finalizar a anamnese, a IA deve gerar insights de saúde e condicionamento do aluno | IA | ✅ |
| RF11 | O Personal deve poder solicitar sugestões de treino geradas pela IA com base nos insights | Personal | ✅ |
| RF12 | As sugestões de treino devem incluir justificativa científica (ACSM/NSCA) e precauções | IA | ✅ |
| RF13 | O Personal deve poder revisar, editar e aprovar uma sugestão antes de atribuí-la ao aluno | Personal | ✅ |
| RF14 | Os exercícios sugeridos pela IA devem ser criados automaticamente na biblioteca ao serem aprovados | Sistema | ✅ |
| RF15 | O Aluno deve poder visualizar os treinos atribuídos pelo seu Personal | Aluno | ✅ |

---

## Requisitos Não Funcionais

| ID | Categoria | Descrição | Status |
|----|-----------|-----------|--------|
| RNF01 | Segurança | Autenticação via Firebase Auth com sessão persistente | ✅ |
| RNF02 | Segurança | Regras de acesso no Firestore garantem que cada usuário acessa apenas seus dados | ✅ |
| RNF03 | Privacidade | Dados de saúde coletados na anamnese são armazenados exclusivamente no Firestore do projeto | ✅ |
| RNF04 | Portabilidade | O sistema deve rodar em Android, iOS e Web a partir de um único código-base (Flutter) | ✅ |
| RNF05 | Usabilidade | A interface deve seguir Material Design 3 e ser navegável sem treinamento prévio | ✅ |
| RNF06 | Confiabilidade | Erros de comunicação com a API Gemini devem ser tratados com mensagem amigável, sem interromper o fluxo do usuário | ✅ |
| RNF07 | Eficiência | O custo por anamnese completa deve se manter abaixo de R$ 0,15, com no máximo 2 chamadas à API Gemini por ciclo | ✅ |
| RNF08 | Manutenibilidade | O código deve seguir arquitetura feature-first com separação clara entre presentation, domain e data | ✅ |

---

## Casos de Uso

### UC01 — Criar e atribuir anamnese

**Ator principal:** Personal Trainer

**Pré-condição:** Personal autenticado com pelo menos um aluno cadastrado.

**Fluxo:**
1. Personal acessa a lista de anamneses e cria uma nova
2. Seleciona o aluno destinatário
3. O sistema cria a anamnese com as 22 perguntas base e disponibiliza ao aluno

**Pós-condição:** Anamnese com status `draft` criada e visível para o aluno.

---

### UC02 — Responder anamnese

**Ator principal:** Aluno

**Pré-condição:** Aluno autenticado com anamnese disponível.

**Fluxo:**
1. Aluno acessa a anamnese e responde as perguntas progressivamente
2. Ao responder a questão de sexo biológico (q2), perguntas específicas são injetadas automaticamente (qf1–qf7 para feminino; qm1–qm3 para masculino)
3. Após as perguntas base, a IA gera de 3 a 5 perguntas diagnósticas adicionais
4. Aluno responde as perguntas da IA e finaliza
5. O sistema aciona a análise completa pelo Gemini

**Pós-condição:** Anamnese com status `analyzed` e insights salvos no Firestore.

---

### UC03 — Visualizar insights e gerar sugestões

**Ator principal:** Personal Trainer

**Pré-condição:** Anamnese com status `analyzed`.

**Fluxo:**
1. Personal acessa os insights da anamnese (resumo, nível de condicionamento, condições de saúde, risco de lesão)
2. Solicita geração de sugestões de treino
3. A IA retorna um plano com exercícios, justificativas científicas e precauções

**Pós-condição:** Sugestão salva com status `pending`, disponível para revisão.

---

### UC04 — Aprovar sugestão e criar treino

**Ator principal:** Personal Trainer

**Pré-condição:** Sugestão com status `pending`.

**Fluxo:**
1. Personal revisa a sugestão e pode editar exercícios, séries e repetições
2. Aprova a sugestão
3. O sistema cria ou encontra cada exercício na biblioteca via `findOrCreateByName`
4. O treino é salvo no Firestore e vinculado ao aluno

**Pós-condição:** Treino criado e visível para o aluno.

---

### UC05 — Visualizar treinos atribuídos

**Ator principal:** Aluno

**Pré-condição:** Aluno autenticado com pelo menos um treino atribuído.

**Fluxo:**
1. Aluno acessa a tela de treinos
2. Visualiza os exercícios, séries, repetições e instruções de cada treino atribuído

**Pós-condição:** Nenhum — operação somente de leitura.

---

**Última atualização:** Junho 2026
