import 'package:new_gym_app/core/services/firebase_exercise_service.dart';

Future<void> initializeFirestoreData() async {
  try {
    print('Iniciando população do banco de dados...');

    final exerciseService = FirebaseExerciseService();

    await exerciseService.seedExercises();

    print('Banco de dados inicializado com sucesso!');
  } catch (e) {
    print('Erro ao inicializar banco de dados: $e');
    rethrow;
  }
}
