import 'package:new_gym_app/core/models/anamnesis_model.dart';

/// Template de anamnese base
/// Baseado em anamnese profissional fornecida por personal trainer
class AnamnesisTemplate {
  /// Retorna lista de perguntas base para anamnese inicial
  static List<AnamnesisQuestion> getBaseQuestions() {
    return [
      // ========== DADOS PESSOAIS ==========
      AnamnesisQuestion(
        id: 'q1',
        text: 'Qual é o seu nome completo?',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 1,
      ),
      AnamnesisQuestion(
        id: 'q2',
        text: 'Qual é a sua data de nascimento?',
        type: QuestionType.date,
        isRequired: true,
        isDynamic: false,
        order: 2,
      ),
      AnamnesisQuestion(
        id: 'q3',
        text: 'Qual é a sua altura? (em cm)',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 3,
      ),
      AnamnesisQuestion(
        id: 'q4',
        text: 'Qual é o seu peso atual? (em kg)',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 4,
      ),
      AnamnesisQuestion(
        id: 'q5',
        text: 'Qual é o seu gênero?',
        type: QuestionType.multipleChoice,
        options: ['Masculino', 'Feminino', 'Outro', 'Prefiro não informar'],
        isRequired: true,
        isDynamic: false,
        order: 5,
      ),
      AnamnesisQuestion(
        id: 'q6',
        text: 'Se do sexo feminino, está grávida?',
        type: QuestionType.yesNo,
        isRequired: false,
        isDynamic: false,
        order: 6,
      ),

      // ========== ROTINA ==========
      AnamnesisQuestion(
        id: 'q7',
        text: 'Qual é o seu trabalho? Em qual horário trabalha?',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 7,
      ),
      AnamnesisQuestion(
        id: 'q8',
        text: 'Você estuda? Se sim, em qual horário?',
        type: QuestionType.text,
        isRequired: false,
        isDynamic: false,
        order: 8,
      ),
      AnamnesisQuestion(
        id: 'q9',
        text: 'Que horas você normalmente dorme e acorda?',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 9,
      ),
      AnamnesisQuestion(
        id: 'q10',
        text: 'Você se sente cansado(a) frequentemente?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 10,
      ),

      // ========== SAÚDE E CONDICIONAMENTO ==========
      AnamnesisQuestion(
        id: 'q11',
        text: 'Você sabe sua pressão arterial? Se sim, qual é?',
        type: QuestionType.text,
        isRequired: false,
        isDynamic: false,
        order: 11,
      ),
      AnamnesisQuestion(
        id: 'q12',
        text:
            'Você está inativo fisicamente? (faz menos que 90 min por semana de atividade vigorosa ou 120 min por semana de atividades moderadas)',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 12,
      ),
      AnamnesisQuestion(
        id: 'q13',
        text: 'Você fuma ou parou de fumar há menos de 6 meses?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 13,
      ),
      AnamnesisQuestion(
        id: 'q14',
        text: 'Faz uso de bebida alcoólica? Com que frequência?',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 14,
      ),

      // ========== HISTÓRICO DE ATIVIDADE FÍSICA ==========
      AnamnesisQuestion(
        id: 'q15',
        text:
            'Pratica alguma atividade física diária ou de fim-de-semana, além da musculação? (corrida, artes marciais, etc.)',
        type: QuestionType.text,
        isRequired: false,
        isDynamic: false,
        order: 15,
      ),
      AnamnesisQuestion(
        id: 'q16',
        text: 'Treina musculação há quanto tempo?',
        type: QuestionType.multipleChoice,
        options: [
          'Nunca treinei',
          'Menos de 3 meses',
          '3 a 6 meses',
          '6 meses a 1 ano',
          '1 a 2 anos',
          'Mais de 2 anos',
        ],
        isRequired: true,
        isDynamic: false,
        order: 16,
      ),

      // ========== OBJETIVOS ==========
      AnamnesisQuestion(
        id: 'q17',
        text: 'Qual é o seu objetivo principal com o treino?',
        type: QuestionType.multipleChoice,
        options: [
          'Emagrecimento',
          'Ganho de massa muscular',
          'Condicionamento físico',
          'Saúde e bem-estar',
          'Reabilitação',
          'Performance esportiva',
          'Outro',
        ],
        isRequired: true,
        isDynamic: false,
        order: 17,
      ),
      AnamnesisQuestion(
        id: 'q18',
        text:
            'Descreva sua meta para daqui 1 mês e sua disponibilidade semanal para atividade física extra',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 18,
      ),

      // ========== ALIMENTAÇÃO ==========
      AnamnesisQuestion(
        id: 'q19',
        text:
            'Você geralmente segue alguma rotina alimentar em suas refeições?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 19,
      ),
      AnamnesisQuestion(
        id: 'q20',
        text: 'Quais refeições você normalmente realiza ao dia?',
        type: QuestionType.multiSelect,
        options: [
          'Café da manhã',
          'Lanche da manhã',
          'Almoço',
          'Lanche da tarde',
          'Jantar',
          'Ceia',
        ],
        isRequired: true,
        isDynamic: false,
        order: 20,
      ),

      // ========== MOTIVAÇÃO E COMPROMETIMENTO ==========
      AnamnesisQuestion(
        id: 'q21',
        text:
            'De 0 a 10, quanto você gosta de frequentar a academia e/ou treinar?',
        type: QuestionType.scale,
        isRequired: true,
        isDynamic: false,
        order: 21,
      ),
      AnamnesisQuestion(
        id: 'q22',
        text:
            'De 0 a 10, quanto você acha que precisa mudar na sua rotina para alcançar seu objetivo?',
        type: QuestionType.scale,
        isRequired: true,
        isDynamic: false,
        order: 22,
      ),
      AnamnesisQuestion(
        id: 'q23',
        text:
            'De 0 a 10, quanto está disposto a se dedicar para realizar sua frequência semanal predeterminada?',
        type: QuestionType.scale,
        isRequired: true,
        isDynamic: false,
        order: 23,
      ),
      AnamnesisQuestion(
        id: 'q24',
        text: 'Você tem dúvidas quanto à segurança de se exercitar?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 24,
      ),

      // ========== RISCOS CARDÍACOS E CONTRAINDICAÇÕES ==========
      AnamnesisQuestion(
        id: 'q25',
        text:
            'Alguma vez um médico lhe disse que você possui um problema do coração e recomendou atividade física apenas sob supervisão médica?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 25,
      ),
      AnamnesisQuestion(
        id: 'q26',
        text:
            'Você sente dor no peito causada pela prática de atividade física?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 26,
      ),
      AnamnesisQuestion(
        id: 'q27',
        text: 'Você sentiu dor no peito no último mês?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 27,
      ),
      AnamnesisQuestion(
        id: 'q28',
        text:
            'Você tende a perder a consciência ou cair, como resultado de tontura ou desmaio?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 28,
      ),

      // ========== PROBLEMAS MUSCULOESQUELÉTICOS ==========
      AnamnesisQuestion(
        id: 'q29',
        text:
            'Foi referido pelo seu médico algum problema ósseo, articular ou muscular que possa ser agravado pela prática de atividades físicas?',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 29,
      ),
      AnamnesisQuestion(
        id: 'q30',
        text: 'Você já se lesionou praticando exercícios? Descreva.',
        type: QuestionType.text,
        isRequired: false,
        isDynamic: false,
        order: 30,
      ),
      AnamnesisQuestion(
        id: 'q31',
        text:
            'Você tem algum problema ósseo ou muscular que poderia ser agravado com a prática de atividade física?',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 31,
      ),

      // ========== MEDICAMENTOS E SUPLEMENTOS ==========
      AnamnesisQuestion(
        id: 'q32',
        text:
            'Algum médico já lhe recomendou o uso de medicamentos para pressão arterial, circulação ou coração?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 32,
      ),
      AnamnesisQuestion(
        id: 'q33',
        text: 'Toma algum medicamento? Qual(is)?',
        type: QuestionType.text,
        isRequired: false,
        isDynamic: false,
        order: 33,
      ),
      AnamnesisQuestion(
        id: 'q34',
        text: 'Toma algum suplemento? Qual(is)?',
        type: QuestionType.text,
        isRequired: false,
        isDynamic: false,
        order: 34,
      ),

      // ========== OUTRAS CONTRAINDICAÇÕES ==========
      AnamnesisQuestion(
        id: 'q35',
        text:
            'Você tem consciência, através da sua própria experiência ou aconselhamento médico, de alguma outra razão física que impeça sua prática de atividade física sem supervisão médica?',
        type: QuestionType.text,
        isRequired: true,
        isDynamic: false,
        order: 35,
      ),

      // ========== AUTORIZAÇÃO DE IMAGENS ==========
      AnamnesisQuestion(
        id: 'q36',
        text:
            'Você concorda com o uso de imagem para melhora da sua performance ou divulgação?',
        type: QuestionType.yesNo,
        isRequired: true,
        isDynamic: false,
        order: 36,
      ),
      AnamnesisQuestion(
        id: 'q37',
        text:
            'Qual o seu pensamento sobre utilização de imagens para realização de avaliação? (fotos não divulgadas, apenas para adequar o treinamento)',
        type: QuestionType.multipleChoice,
        options: [
          'Concordo totalmente',
          'Concordo parcialmente',
          'Indiferente',
          'Não concordo',
        ],
        isRequired: true,
        isDynamic: false,
        order: 37,
      ),
    ];
  }

  /// Agrupa perguntas por categoria para exibição organizada
  static Map<String, List<AnamnesisQuestion>> getGroupedQuestions() {
    final allQuestions = getBaseQuestions();

    return {
      'Dados Pessoais': allQuestions.sublist(0, 6),
      'Rotina Diária': allQuestions.sublist(6, 10),
      'Saúde Geral': allQuestions.sublist(10, 14),
      'Atividade Física': allQuestions.sublist(14, 16),
      'Objetivos': allQuestions.sublist(16, 18),
      'Alimentação': allQuestions.sublist(18, 20),
      'Motivação': allQuestions.sublist(20, 24),
      'Saúde Cardíaca': allQuestions.sublist(24, 28),
      'Saúde Musculoesquelética': allQuestions.sublist(28, 31),
      'Medicamentos': allQuestions.sublist(31, 34),
      'Outras Informações': allQuestions.sublist(34, 35),
      'Autorização': allQuestions.sublist(35, 37),
    };
  }

  /// Retorna perguntas críticas que sempre devem ser respondidas
  static List<String> getCriticalQuestionIds() {
    return [
      'q25', // Problema cardíaco
      'q26', // Dor no peito ao exercitar
      'q27', // Dor no peito recente
      'q28', // Desmaios
      'q29', // Problemas ósseos/articulares
      'q32', // Medicamentos cardíacos
      'q35', // Outras contraindicações
    ];
  }
}
