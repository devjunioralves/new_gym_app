/// Status da anamnese
enum AnamnesisStatus {
  draft, // Criada mas não enviada ao aluno
  inProgress, // Aluno está respondendo
  completed, // Aluno finalizou respostas
  analyzed, // IA já analisou e gerou insights
}

extension AnamnesisStatusExtension on AnamnesisStatus {
  String toFirestore() {
    return toString().split('.').last;
  }

  static AnamnesisStatus fromFirestore(String value) {
    return AnamnesisStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => AnamnesisStatus.draft,
    );
  }
}

/// Modelo principal de Anamnese
class Anamnesis {
  final String id;
  final String studentId;
  final String personalId;
  final List<AnamnesisQuestion> questions;
  final List<AnamnesisAnswer> answers;
  final AnamnesisStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? analyzedAt;

  const Anamnesis({
    required this.id,
    required this.studentId,
    required this.personalId,
    required this.questions,
    required this.answers,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.analyzedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'personalId': personalId,
      'questions': questions.map((q) => q.toMap()).toList(),
      'answers': answers.map((a) => a.toMap()).toList(),
      'status': status.toFirestore(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'analyzedAt': analyzedAt?.toIso8601String(),
    };
  }

  factory Anamnesis.fromMap(Map<String, dynamic> map) {
    return Anamnesis(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      personalId: map['personalId'] ?? '',
      questions: (map['questions'] as List<dynamic>?)
              ?.map((q) => AnamnesisQuestion.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      answers: (map['answers'] as List<dynamic>?)
              ?.map((a) => AnamnesisAnswer.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      status: AnamnesisStatusExtension.fromFirestore(map['status'] ?? 'draft'),
      createdAt: DateTime.parse(map['createdAt']),
      completedAt:
          map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      analyzedAt:
          map['analyzedAt'] != null ? DateTime.parse(map['analyzedAt']) : null,
    );
  }

  Anamnesis copyWith({
    String? id,
    String? studentId,
    String? personalId,
    List<AnamnesisQuestion>? questions,
    List<AnamnesisAnswer>? answers,
    AnamnesisStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? analyzedAt,
  }) {
    return Anamnesis(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      personalId: personalId ?? this.personalId,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }
}

/// Tipo de pergunta
enum QuestionType {
  text, // Resposta livre
  multipleChoice, // Múltipla escolha (uma opção)
  multiSelect, // Múltipla escolha (várias opções)
  yesNo, // Sim/Não
  scale, // Escala (1-10)
  date, // Data
}

extension QuestionTypeExtension on QuestionType {
  String toFirestore() {
    return toString().split('.').last;
  }

  static QuestionType fromFirestore(String value) {
    return QuestionType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => QuestionType.text,
    );
  }
}

/// Pergunta da anamnese
class AnamnesisQuestion {
  final String id;
  final String text;
  final QuestionType type;
  final List<String>? options; // Para multipleChoice e multiSelect
  final bool isRequired;
  final bool isDynamic; // true se foi gerada pela IA
  final String? generatedReason; // Por que a IA gerou essa pergunta
  final int order; // Ordem de exibição

  const AnamnesisQuestion({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.isRequired = true,
    this.isDynamic = false,
    this.generatedReason,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type.toFirestore(),
      'options': options,
      'isRequired': isRequired,
      'isDynamic': isDynamic,
      'generatedReason': generatedReason,
      'order': order,
    };
  }

  factory AnamnesisQuestion.fromMap(Map<String, dynamic> map) {
    return AnamnesisQuestion(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      type: QuestionTypeExtension.fromFirestore(map['type'] ?? 'text'),
      options: (map['options'] as List<dynamic>?)?.cast<String>(),
      isRequired: map['isRequired'] ?? true,
      isDynamic: map['isDynamic'] ?? false,
      generatedReason: map['generatedReason'],
      order: map['order'] ?? 0,
    );
  }
}

/// Resposta do aluno
class AnamnesisAnswer {
  final String questionId;
  final dynamic value; // Pode ser String, List<String>, int, bool, DateTime
  final DateTime answeredAt;

  const AnamnesisAnswer({
    required this.questionId,
    required this.value,
    required this.answeredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'value': value is DateTime ? (value as DateTime).toIso8601String() : value,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  factory AnamnesisAnswer.fromMap(Map<String, dynamic> map) {
    dynamic parsedValue = map['value'];
    
    // Tenta parsear como DateTime se for string de data
    if (parsedValue is String && parsedValue.contains('T')) {
      try {
        parsedValue = DateTime.parse(parsedValue);
      } catch (_) {
        // Se falhar, mantém como string
      }
    }

    return AnamnesisAnswer(
      questionId: map['questionId'] ?? '',
      value: parsedValue,
      answeredAt: DateTime.parse(map['answeredAt']),
    );
  }
}
