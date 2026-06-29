import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_gym_app/core/models/anamnesis_insights_model.dart';
import 'package:new_gym_app/core/models/anamnesis_model.dart';
import 'package:new_gym_app/core/models/workout_suggestion_model.dart';

/// Service para gerenciar anamneses no Firestore
class FirebaseAnamnesisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _anamnesisCollection = 'anamnesis';
  static const String _insightsCollection = 'insights';
  static const String _suggestionsCollection = 'workoutSuggestions';

  /// Cria uma nova anamnese para um aluno
  Future<String> createAnamnesis({
    required String studentId,
    required String personalId,
    required List<AnamnesisQuestion> baseQuestions,
  }) async {
    final anamnesis = Anamnesis(
      id: '',
      studentId: studentId,
      personalId: personalId,
      questions: baseQuestions,
      answers: [],
      status: AnamnesisStatus.draft,
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection(_anamnesisCollection)
        .add(anamnesis.toMap()..remove('id'));

    // Atualiza com o ID gerado
    await docRef.update({'id': docRef.id});

    return docRef.id;
  }

  /// Busca anamnese por ID
  Future<Anamnesis?> getAnamnesis(String anamnesisId) async {
    final doc = await _firestore
        .collection(_anamnesisCollection)
        .doc(anamnesisId)
        .get();

    if (!doc.exists) return null;

    return Anamnesis.fromMap(doc.data()!);
  }

  /// Lista anamneses de um aluno (contexto do próprio aluno).
  /// A query filtra apenas por studentId, satisfazendo a regra
  /// `resource.data.studentId == request.auth.uid`.
  Stream<List<Anamnesis>> getStudentAnamneses(String studentId) {
    return _firestore
        .collection(_anamnesisCollection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Anamnesis.fromMap(doc.data()))
              .toList(),
        );
  }

  /// Lista anamneses de um aluno vistas pelo personal (contexto do PT).
  /// Inclui os dois filtros para satisfazer a regra Firestore:
  /// `resource.data.personalId == request.auth.uid`.
  Stream<List<Anamnesis>> getStudentAnamnesesByPersonal({
    required String studentId,
    required String personalId,
  }) {
    return _firestore
        .collection(_anamnesisCollection)
        .where('personalId', isEqualTo: personalId)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Anamnesis.fromMap(doc.data()))
              .toList(),
        );
  }

  /// Lista anamneses criadas por um personal
  Stream<List<Anamnesis>> getPersonalAnamneses(String personalId) {
    return _firestore
        .collection(_anamnesisCollection)
        .where('personalId', isEqualTo: personalId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Anamnesis.fromMap(doc.data()))
              .toList(),
        );
  }

  /// Envia anamnese para o aluno começar a responder
  Future<void> sendToStudent(String anamnesisId) async {
    await _firestore.collection(_anamnesisCollection).doc(anamnesisId).update({
      'status': AnamnesisStatus.inProgress.toFirestore(),
    });
  }

  /// Salva uma resposta do aluno
  Future<void> saveAnswer({
    required String anamnesisId,
    required AnamnesisAnswer answer,
  }) async {
    final anamnesis = await getAnamnesis(anamnesisId);
    if (anamnesis == null) throw Exception('Anamnese não encontrada');

    // Remove resposta anterior se existir
    final updatedAnswers = anamnesis.answers
        .where((a) => a.questionId != answer.questionId)
        .toList();
    updatedAnswers.add(answer);

    await _firestore.collection(_anamnesisCollection).doc(anamnesisId).update({
      'answers': updatedAnswers.map((a) => a.toMap()).toList(),
    });
  }

  /// Adiciona um lote de perguntas diagnósticas geradas pela IA (chamada única)
  Future<void> addDynamicQuestions({
    required String anamnesisId,
    required List<AnamnesisQuestion> questions,
  }) async {
    if (questions.isEmpty) return;
    final anamnesis = await getAnamnesis(anamnesisId);
    if (anamnesis == null) throw Exception('Anamnese não encontrada');

    final updatedQuestions = [...anamnesis.questions, ...questions];

    await _firestore.collection(_anamnesisCollection).doc(anamnesisId).update({
      'questions': updatedQuestions.map((q) => q.toMap()).toList(),
    });
  }

  /// Marca anamnese como completa (aluno finalizou respostas)
  Future<void> completeAnamnesis(String anamnesisId) async {
    await _firestore.collection(_anamnesisCollection).doc(anamnesisId).update({
      'status': AnamnesisStatus.completed.toFirestore(),
      'completedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Salva insights gerados pela IA
  Future<void> saveInsights({
    required String anamnesisId,
    required AnamnesisInsights insights,
  }) async {
    // Salva insights em subcollection
    await _firestore
        .collection(_anamnesisCollection)
        .doc(anamnesisId)
        .collection(_insightsCollection)
        .doc(insights.id)
        .set(insights.toMap());

    // Atualiza status da anamnese
    await _firestore.collection(_anamnesisCollection).doc(anamnesisId).update({
      'status': AnamnesisStatus.analyzed.toFirestore(),
      'analyzedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Busca insights de uma anamnese
  Future<AnamnesisInsights?> getInsights(String anamnesisId) async {
    final snapshot = await _firestore
        .collection(_anamnesisCollection)
        .doc(anamnesisId)
        .collection(_insightsCollection)
        .orderBy('analyzedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return AnamnesisInsights.fromMap(snapshot.docs.first.data());
  }

  /// Salva sugestão de treino gerada pela IA
  Future<String> saveSuggestion(WorkoutSuggestion suggestion) async {
    final docRef = await _firestore
        .collection(_suggestionsCollection)
        .add(suggestion.toMap()..remove('id'));

    await docRef.update({'id': docRef.id});

    return docRef.id;
  }

  /// Lista sugestões de treino para uma anamnese
  Future<List<WorkoutSuggestion>> getSuggestions(String anamnesisId) async {
    final snapshot = await _firestore
        .collection(_suggestionsCollection)
        .where('anamnesisId', isEqualTo: anamnesisId)
        .orderBy('confidence', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WorkoutSuggestion.fromMap(doc.data()))
        .toList();
  }

  /// Aprova uma sugestão de treino
  Future<void> approveSuggestion(String suggestionId) async {
    await _firestore
        .collection(_suggestionsCollection)
        .doc(suggestionId)
        .update({
          'approvedByPersonal': true,
          'approvedAt': DateTime.now().toIso8601String(),
        });
  }

  /// Deleta uma anamnese
  Future<void> deleteAnamnesis(String anamnesisId) async {
    // Deleta insights
    final insightsSnapshot = await _firestore
        .collection(_anamnesisCollection)
        .doc(anamnesisId)
        .collection(_insightsCollection)
        .get();

    for (final doc in insightsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Deleta sugestões relacionadas
    final suggestionsSnapshot = await _firestore
        .collection(_suggestionsCollection)
        .where('anamnesisId', isEqualTo: anamnesisId)
        .get();

    for (final doc in suggestionsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Deleta anamnese
    await _firestore.collection(_anamnesisCollection).doc(anamnesisId).delete();
  }
}
