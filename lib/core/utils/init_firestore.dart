import 'package:new_gym_app/core/services/firebase_exercise_service.dart';

/// Script de inicialização para popular o Firestore com dados iniciais
/// Execute uma vez chamando initializeFirestoreData() no main.dart
Future<void> initializeFirestoreData() async {
  try {
    print('🔄 Iniciando população do banco de dados...');

    final exerciseService = FirebaseExerciseService();

    // Popular exercícios
    await exerciseService.seedExercises();

    print('✅ Banco de dados inicializado com sucesso!');
  } catch (e) {
    print('❌ Erro ao inicializar banco de dados: $e');
    rethrow;
  }
}
