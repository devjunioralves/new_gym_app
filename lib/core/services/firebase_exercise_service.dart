import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_gym_app/core/models/exercise_model.dart';
import 'package:new_gym_app/core/models/user_exercise_model.dart';
import 'package:new_gym_app/core/models/user_model.dart';

class FirebaseExerciseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'exercises';

  // Buscar todos os exercícios
  Future<List<Exercise>> getAllExercises() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs
          .map((doc) => Exercise.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar exercícios: $e');
    }
  }

  // Buscar exercício por nome
  Future<Exercise> getExerciseByName(String name) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Exercício não encontrado!');
      }

      final doc = snapshot.docs.first;
      return Exercise.fromMap(doc.data(), doc.id);
    } catch (e) {
      throw Exception('Erro ao buscar exercício: $e');
    }
  }

  // Buscar exercício por ID
  Future<Exercise> getExerciseById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();

      if (!doc.exists) {
        throw Exception('Exercício não encontrado!');
      }

      return Exercise.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Erro ao buscar exercício: $e');
    }
  }

  // Buscar exercícios por categoria (com stream para atualizações em tempo real)
  Stream<List<Exercise>> getExercisesByCategory(String? category) {
    Query query = _firestore.collection(_collectionName);

    if (category != null && category.isNotEmpty) {
      query = query.where('workoutType', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                Exercise.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }

  // Adicionar exercício (útil para popular o banco inicialmente)
  Future<String> addExercise(Exercise exercise) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(exercise.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar exercício: $e');
    }
  }

  // Criar novo exercício (simplificado para criação via formulário)
  Future<String> createExercise({
    required String name,
    required String workoutType,
    required int series,
    required int reps,
    required String imageUrl,
    required String instructions,
  }) async {
    try {
      final exercise = Exercise(
        id: '', // Será gerado pelo Firestore
        name: name,
        workoutType: workoutType,
        series: series,
        reps: reps,
        imageUrl: imageUrl,
        instructions: instructions,
      );

      final docRef = await _firestore
          .collection(_collectionName)
          .add(exercise.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar exercício: $e');
    }
  }

  // Atualizar exercício
  Future<void> updateExercise(String id, Exercise exercise) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .update(exercise.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar exercício: $e');
    }
  }

  // Deletar exercício
  Future<void> deleteExercise(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar exercício: $e');
    }
  }

  // Popular banco com exercícios iniciais
  Future<void> seedExercises() async {
    try {
      // Verifica se já existem exercícios
      final snapshot = await _firestore
          .collection(_collectionName)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        print('Exercícios já existem no banco');
        return;
      }

      // Lista de exercícios iniciais
      final exercises = [
        Exercise(
          id: '',
          name: 'Supino Inclinado',
          workoutType: 'Peito',
          series: 3,
          reps: 10,
          imageUrl: 'assets/images/profile.png',
          instructions:
              'Deite-se no banco inclinado e empurre a barra para cima...',
        ),
        Exercise(
          id: '',
          name: 'Rosca Direta',
          workoutType: 'Bíceps',
          series: 4,
          reps: 12,
          imageUrl: 'assets/images/profile.png',
          instructions: 'Segure a barra com as palmas para cima e levante...',
        ),
        Exercise(
          id: '',
          name: 'Tríceps Corda',
          workoutType: 'Tríceps',
          series: 3,
          reps: 15,
          imageUrl: 'assets/images/profile.png',
          instructions:
              'Use a polia alta com a corda e estenda os cotovelos...',
        ),
        Exercise(
          id: '',
          name: 'Elevação Lateral',
          workoutType: 'Ombro',
          series: 4,
          reps: 12,
          imageUrl: 'assets/images/profile.png',
          instructions:
              'Levante os halteres lateralmente até a altura dos ombros...',
        ),
        Exercise(
          id: '',
          name: 'Crucifixo',
          workoutType: 'Peito',
          series: 3,
          reps: 12,
          imageUrl: 'assets/images/profile.png',
          instructions: 'Deite-se no banco e abra os braços com os halteres...',
        ),
        Exercise(
          id: '',
          name: 'Rosca Martelo',
          workoutType: 'Bíceps',
          series: 3,
          reps: 10,
          imageUrl: 'assets/images/profile.png',
          instructions:
              'Segure os halteres com as palmas viradas uma para a outra...',
        ),
        Exercise(
          id: '',
          name: 'Agachamento Livre',
          workoutType: 'Perna',
          series: 4,
          reps: 12,
          imageUrl: 'assets/images/profile.png',
          instructions:
              'Coloque a barra nas costas e agache até as coxas ficarem paralelas ao chão...',
        ),
        Exercise(
          id: '',
          name: 'Levantamento Terra',
          workoutType: 'Costas',
          series: 3,
          reps: 8,
          imageUrl: 'assets/images/profile.png',
          instructions:
              'Segure a barra no chão e levante mantendo as costas retas...',
        ),
      ];

      // Adiciona cada exercício
      for (final exercise in exercises) {
        await addExercise(exercise);
      }

      print('${exercises.length} exercícios adicionados com sucesso!');
    } catch (e) {
      throw Exception('Erro ao popular exercícios: $e');
    }
  }

  // ===== Métodos para gerenciar atribuição de exercícios a alunos =====

  // Atribuir exercício a um aluno
  Future<void> assignExerciseToStudent({
    required String studentId,
    required String exerciseId,
    required String personalTrainerId,
    int? customSeries,
    int? customReps,
    String? notes,
  }) async {
    try {
      final userExercise = UserExercise(
        id: '',
        userId: studentId,
        exerciseId: exerciseId,
        assignedBy: personalTrainerId,
        assignedAt: DateTime.now(),
        customSeries: customSeries,
        customReps: customReps,
        notes: notes,
      );

      await _firestore.collection('user_exercises').add(userExercise.toMap());
    } catch (e) {
      throw Exception('Erro ao atribuir exercício: $e');
    }
  }

  // Buscar exercícios de um aluno específico
  Future<List<Exercise>> getStudentExercises(String studentId) async {
    try {
      // Busca os IDs dos exercícios atribuídos ao aluno
      final userExercisesSnapshot = await _firestore
          .collection('user_exercises')
          .where('userId', isEqualTo: studentId)
          .get();

      if (userExercisesSnapshot.docs.isEmpty) {
        return [];
      }

      // Extrai os IDs dos exercícios
      final exerciseIds = userExercisesSnapshot.docs
          .map((doc) => doc.data()['exerciseId'] as String)
          .toList();

      // Busca os exercícios completos
      final exercises = <Exercise>[];
      for (final exerciseId in exerciseIds) {
        final exerciseDoc = await _firestore
            .collection(_collectionName)
            .doc(exerciseId)
            .get();
        if (exerciseDoc.exists) {
          exercises.add(Exercise.fromMap(exerciseDoc.data()!, exerciseDoc.id));
        }
      }

      return exercises;
    } catch (e) {
      throw Exception('Erro ao buscar exercícios do aluno: $e');
    }
  }

  // Buscar atribuições de exercícios de um aluno com detalhes
  Future<List<UserExercise>> getStudentExerciseAssignments(
    String studentId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('user_exercises')
          .where('userId', isEqualTo: studentId)
          .get();

      return snapshot.docs
          .map((doc) => UserExercise.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar atribuições: $e');
    }
  }

  // Remover atribuição de exercício
  Future<void> removeExerciseAssignment(String assignmentId) async {
    try {
      await _firestore.collection('user_exercises').doc(assignmentId).delete();
    } catch (e) {
      throw Exception('Erro ao remover atribuição: $e');
    }
  }

  // Buscar alunos de um personal trainer específico
  Future<List<User>> getStudentsByPersonal(String personalId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('personalTrainerId', isEqualTo: personalId)
          .get();

      return snapshot.docs
          .map((doc) => User.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar alunos: $e');
    }
  }

  // Buscar todos os alunos (DEPRECATED - usar getStudentsByPersonal)
  Future<List<User>> getAllStudents() async {
    try {
      final snapshot = await _firestore.collection('users').get();

      // Filtra apenas alunos no código (evita necessidade de índice)
      return snapshot.docs
          .where((doc) => doc.data()['role'] == 'student')
          .map((doc) => User.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar alunos: $e');
    }
  }

  // Stream de exercícios de um aluno (atualização em tempo real)
  Stream<List<Exercise>> studentExercisesStream(String studentId) {
    return _firestore
        .collection('user_exercises')
        .where('userId', isEqualTo: studentId)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) return [];

          final exerciseIds = snapshot.docs
              .map((doc) => doc.data()['exerciseId'] as String)
              .toList();

          final exercises = <Exercise>[];
          for (final exerciseId in exerciseIds) {
            final exerciseDoc = await _firestore
                .collection(_collectionName)
                .doc(exerciseId)
                .get();
            if (exerciseDoc.exists) {
              exercises.add(
                Exercise.fromMap(exerciseDoc.data()!, exerciseDoc.id),
              );
            }
          }

          return exercises;
        });
  }
}
