import 'package:new_gym_app/core/models/anamnesis_model.dart';

class AnamnesisTemplate {
  static List<AnamnesisQuestion> getBaseQuestions() {
    return [
      // ── Identificação ───────────────────────────────────────────────────────
      AnamnesisQuestion(
        id: 'q1',
        text: 'Qual é a sua data de nascimento?',
        type: QuestionType.date,
        isRequired: true,
        isDynamic: false,
        order: 1,
      ),
      AnamnesisQuestion(
        id: 'q2',
        text: 'Qual é o seu sexo biológico?',
        type: QuestionType.multipleChoice,
        options: ['Masculino', 'Feminino', 'Prefiro não informar'],
        isRequired: true,
        isDynamic: false,
        order: 2,
      ),
      AnamnesisQuestion(
        id: 'q3',
        text: 'Qual é o seu peso atual (kg) e altura (cm)?',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 3,
      ),

      // ── Objetivo e histórico de treino ───────────────────────────────────────
      AnamnesisQuestion(
        id: 'q4',
        text: 'Qual é o seu objetivo principal com o treino?',
        type: QuestionType.multipleChoice,
        options: [
          'Emagrecimento',
          'Ganho de massa muscular',
          'Condicionamento físico',
          'Saúde e bem-estar',
          'Reabilitação',
          'Performance esportiva',
        ],
        isRequired: true,
        isDynamic: false,
        order: 4,
      ),
      AnamnesisQuestion(
        id: 'q5',
        text: 'Como você descreveria seu nível atual de atividade física?',
        type: QuestionType.multipleChoice,
        options: [
          'Sedentário (não pratico nenhum exercício)',
          'Pouco ativo (exercício leve 1-2x por semana)',
          'Ativo (exercício moderado 3-4x por semana)',
          'Muito ativo (exercício intenso 5+ vezes por semana)',
        ],
        isRequired: true,
        isDynamic: false,
        order: 5,
      ),
      AnamnesisQuestion(
        id: 'q6',
        text: 'Há quanto tempo pratica musculação ou exercícios resistidos?',
        type: QuestionType.multipleChoice,
        options: [
          'Nunca pratiquei',
          'Menos de 3 meses',
          '3 a 12 meses',
          '1 a 3 anos',
          'Mais de 3 anos',
        ],
        isRequired: true,
        isDynamic: false,
        order: 6,
      ),
      AnamnesisQuestion(
        id: 'q7',
        text: 'Quantas vezes por semana você consegue treinar?',
        type: QuestionType.multipleChoice,
        options: [
          '1 a 2 vezes',
          '3 vezes',
          '4 vezes',
          '5 vezes',
          '6 ou mais vezes',
        ],
        isRequired: true,
        isDynamic: false,
        order: 7,
      ),

      // ── Estilo de vida ───────────────────────────────────────────────────────
      AnamnesisQuestion(
        id: 'q8',
        text: 'Qual é a sua ocupação principal? (Ex: trabalho sentado, em pé, trabalho físico, estudante)',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 8,
      ),
      AnamnesisQuestion(
        id: 'q9',
        text: 'Como você avalia sua qualidade de sono?',
        type: QuestionType.multipleChoice,
        options: [
          'Ruim (menos de 5 horas ou sono muito agitado)',
          'Regular (5-6 horas)',
          'Boa (7-8 horas)',
          'Excelente (mais de 8 horas e acordo descansado)',
        ],
        isRequired: true,
        isDynamic: false,
        order: 9,
      ),
      AnamnesisQuestion(
        id: 'q10',
        text: 'Como você avalia seu nível de estresse no dia a dia?',
        type: QuestionType.multipleChoice,
        options: [
          'Baixo — raramente me sinto estressado',
          'Moderado — estresso eventualmente',
          'Alto — frequentemente sob pressão',
          'Muito alto — estresse quase constante',
        ],
        isRequired: true,
        isDynamic: false,
        order: 10,
      ),
      AnamnesisQuestion(
        id: 'q11',
        text: 'Como você descreveria seus hábitos alimentares?',
        type: QuestionType.multipleChoice,
        options: [
          'Muito ruim — como mal e de forma irregular',
          'Regular — como de tudo mas sem controle',
          'Bom — tento me alimentar bem na maioria das vezes',
          'Ótimo — alimentação balanceada e controlada',
        ],
        isRequired: true,
        isDynamic: false,
        order: 11,
      ),
      AnamnesisQuestion(
        id: 'q12',
        text: 'Faz uso de suplementos alimentares? Se sim, quais?',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 12,
      ),

      // ── Saúde clínica ────────────────────────────────────────────────────────
      AnamnesisQuestion(
        id: 'q13',
        text: 'Possui alguma condição de saúde diagnosticada? (Ex: hipertensão, diabetes, problemas cardíacos, asma, tireoide, etc.) Se sim, descreva.',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 13,
      ),
      AnamnesisQuestion(
        id: 'q14',
        text: 'Sente dores ou possui lesões que possam afetar a prática de exercícios? Se sim, onde e com que frequência?',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 14,
      ),
      AnamnesisQuestion(
        id: 'q15',
        text: 'Toma algum medicamento regularmente? Se sim, qual(is) e para qual finalidade?',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 15,
      ),
      AnamnesisQuestion(
        id: 'q16',
        text: 'Tem histórico familiar de doenças cardiovasculares, diabetes ou obesidade?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 16,
      ),
      AnamnesisQuestion(
        id: 'q17',
        text: 'Algum médico já recomendou que você só pratique atividade física sob supervisão médica?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 17,
      ),

      // ── Saúde complementar (todos os sexos) ─────────────────────────────────
      AnamnesisQuestion(
        id: 'qh1',
        text: 'Fuma ou usou tabaco (cigarro, narguilé, vape) nos últimos 12 meses?',
        type: QuestionType.multipleChoice,
        options: [
          'Não, nunca fumei',
          'Não, parei há mais de 1 ano',
          'Parei recentemente (menos de 1 ano)',
          'Sim, fumo ocasionalmente',
          'Sim, fumo diariamente',
        ],
        isRequired: true,
        isDynamic: false,
        order: 18,
      ),
      AnamnesisQuestion(
        id: 'qh2',
        text: 'Com que frequência consome bebidas alcoólicas?',
        type: QuestionType.multipleChoice,
        options: [
          'Não consumo',
          'Raramente (ocasiões especiais)',
          'Moderadamente (1-2x por semana)',
          'Frequentemente (3-5x por semana)',
          'Diariamente',
        ],
        isRequired: true,
        isDynamic: false,
        order: 19,
      ),
      AnamnesisQuestion(
        id: 'qh3',
        text: 'Já realizou alguma cirurgia? Se sim, qual tipo e aproximadamente quando? (Ex: ortopédica, abdominal, cardíaca)',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 20,
      ),
      AnamnesisQuestion(
        id: 'qh4',
        text: 'Durante ou após atividade física, você já sentiu dor no peito, tontura intensa, falta de ar desproporcional ao esforço ou desmaio?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 21,
      ),
      AnamnesisQuestion(
        id: 'qh5',
        text: 'Como você avalia sua saúde mental no geral?',
        type: QuestionType.multipleChoice,
        options: [
          'Boa — sem queixas significativas',
          'Tenho ansiedade (com ou sem tratamento)',
          'Tenho depressão (com ou sem tratamento)',
          'Tenho outro transtorno diagnosticado',
          'Estou passando por um período difícil, mas sem diagnóstico',
          'Prefiro não informar',
        ],
        isRequired: true,
        isDynamic: false,
        order: 22,
      ),
    ];
  }

  /// Perguntas específicas para alunas do sexo feminino.
  /// Injetadas automaticamente quando q2 = 'Feminino'.
  static List<AnamnesisQuestion> getFemaleQuestions() {
    return [
      AnamnesisQuestion(
        id: 'qf1',
        text: 'Está grávida ou existe possibilidade de gravidez?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 23,
      ),
      AnamnesisQuestion(
        id: 'qf2',
        text: 'Está amamentando atualmente?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 24,
      ),
      AnamnesisQuestion(
        id: 'qf3',
        text: 'Como é o seu ciclo menstrual?',
        type: QuestionType.multipleChoice,
        options: [
          'Regular (ciclos de 24 a 35 dias)',
          'Irregular',
          'Pós-menopausa',
          'Uso de anticoncepcional — sem menstruação regular',
        ],
        isRequired: true,
        isDynamic: false,
        order: 25,
      ),
      AnamnesisQuestion(
        id: 'qf4',
        text: 'Faz uso de anticoncepcionais hormonais ou terapia de reposição hormonal (TRH)?',
        type: QuestionType.multipleChoice,
        options: [
          'Não',
          'Sim — anticoncepcional oral (pílula)',
          'Sim — DIU hormonal (Mirena, etc.)',
          'Sim — injeção hormonal',
          'Sim — implante subcutâneo',
          'Sim — terapia de reposição hormonal (TRH)',
        ],
        isRequired: true,
        isDynamic: false,
        order: 26,
      ),
      AnamnesisQuestion(
        id: 'qf5',
        text: 'Tem diagnóstico de SOP (Síndrome dos Ovários Policísticos), endometriose ou outro distúrbio hormonal?',
        type: QuestionType.multipleChoice,
        options: [
          'Não',
          'Sim — SOP',
          'Sim — endometriose',
          'Sim — outro distúrbio hormonal',
          'Suspeito, mas sem diagnóstico confirmado',
        ],
        isRequired: true,
        isDynamic: false,
        order: 27,
      ),
      AnamnesisQuestion(
        id: 'qf6',
        text: 'Tem histórico de osteoporose, osteopenia ou já realizou densitometria óssea?',
        type: QuestionType.multipleChoice,
        options: [
          'Não e nunca realizei densitometria',
          'Realizei — resultado normal',
          'Sim — tenho osteopenia',
          'Sim — tenho osteoporose',
        ],
        isRequired: true,
        isDynamic: false,
        order: 28,
      ),
      AnamnesisQuestion(
        id: 'qf7',
        text: 'Já teve hipertensão gestacional, pré-eclâmpsia ou alguma complicação cardiovascular durante a gravidez?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 29,
      ),
    ];
  }

  /// Perguntas específicas para alunos do sexo masculino.
  /// Injetadas automaticamente quando q2 = 'Masculino'.
  static List<AnamnesisQuestion> getMaleQuestions() {
    return [
      AnamnesisQuestion(
        id: 'qm1',
        text: 'Tem diagnóstico de hérnia (inguinal, abdominal ou hiatal)?',
        type: QuestionType.multipleChoice,
        options: [
          'Não',
          'Sim — hérnia inguinal (virilha)',
          'Sim — hérnia abdominal (umbilical ou epigástrica)',
          'Sim — hérnia hiatal (estômago/esôfago)',
          'Sim — mais de um tipo',
        ],
        isRequired: true,
        isDynamic: false,
        order: 23,
      ),
      AnamnesisQuestion(
        id: 'qm2',
        text: 'Faz ou já fez uso de testosterona, anabolizantes esteroides ou hormônio do crescimento (GH)?',
        type: QuestionType.multipleChoice,
        options: [
          'Não, nunca usei',
          'Já usei no passado, mas parei',
          'Sim, faço uso atualmente com acompanhamento médico (TRT)',
          'Sim, faço uso atualmente sem acompanhamento médico',
        ],
        isRequired: true,
        isDynamic: false,
        order: 24,
      ),
      AnamnesisQuestion(
        id: 'qm3',
        text: 'Percebe queda de energia, disposição, concentração ou libido de forma persistente nos últimos meses?',
        type: QuestionType.multipleChoice,
        options: [
          'Não, estou bem nesse aspecto',
          'Sim, levemente',
          'Sim, de forma moderada e está me incomodando',
          'Sim, de forma intensa',
        ],
        isRequired: true,
        isDynamic: false,
        order: 25,
      ),
    ];
  }

  static List<String> getCriticalQuestionIds() {
    return [
      'q13', 'q14', 'q15', 'q16', 'q17', // saúde clínica base
      'qh4', // sintomas durante exercício (triagem de segurança)
      'qf1', // gravidez
      'qf5', // SOP/endometriose
      'qm1', // hérnia (restringe exercícios)
      'qm2', // uso de hormônios exógenos
    ];
  }
}
