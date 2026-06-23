import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gym_app/core/models/anamnesis_insights_model.dart';
import 'package:new_gym_app/core/models/anamnesis_model.dart';
import 'package:new_gym_app/core/models/workout_suggestion_model.dart';
import 'package:new_gym_app/core/services/firebase_anamnesis_service.dart';
import 'package:new_gym_app/core/services/firebase_exercise_service.dart';
import 'package:new_gym_app/core/services/gemini_service.dart';
import 'package:new_gym_app/core/services/rag_workout_service.dart';
import 'package:new_gym_app/features/exercise_detail/presentation/providers/exercise_provider.dart';

// ========== SERVICES ==========

/// Provider do serviço de anamnese
final anamnesisServiceProvider = Provider<FirebaseAnamnesisService>((ref) {
  return FirebaseAnamnesisService();
});

/// Provider do serviço Gemini (IA)
/// IMPORTANTE: Configure sua API key nas variáveis de ambiente
final geminiServiceProvider = Provider<GeminiService>((ref) {
  // TODO: Adicionar API key do Gemini
  // Opção 1: Variável de ambiente
  // const apiKey = String.fromEnvironment('GEMINI_API_KEY');

  // Opção 2: Hardcoded (NÃO recomendado para produção)
  const apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
    throw Exception(
      'Configure sua API key do Gemini!\n'
      'Obtenha em: https://ai.google.dev/',
    );
  }

  return GeminiService(apiKey: apiKey);
});

/// Provider do serviço RAG (sugestões de treino)
final ragWorkoutServiceProvider = Provider<RAGWorkoutService>((ref) {
  const apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_GEMINI_API_KEY_HERE',
  );

  if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
    throw Exception('Configure sua API key do Gemini!');
  }

  return RAGWorkoutService(apiKey: apiKey);
});

// ========== ANAMNESIS ==========

/// Stream de anamneses do aluno atual
final studentAnamnesesProvider = StreamProvider.family<List<Anamnesis>, String>(
  (ref, studentId) {
    final service = ref.watch(anamnesisServiceProvider);
    return service.getStudentAnamneses(studentId);
  },
);

/// Stream de anamneses criadas pelo personal
final personalAnamnesesProvider =
    StreamProvider.family<List<Anamnesis>, String>((ref, personalId) {
      final service = ref.watch(anamnesisServiceProvider);
      return service.getPersonalAnamneses(personalId);
    });

/// Provider de uma anamnese específica
final anamnesisProvider = FutureProvider.family<Anamnesis?, String>((
  ref,
  anamnesisId,
) async {
  final service = ref.watch(anamnesisServiceProvider);
  return await service.getAnamnesis(anamnesisId);
});

// ========== INSIGHTS ==========

/// Provider dos insights de uma anamnese
final anamnesisInsightsProvider =
    FutureProvider.family<AnamnesisInsights?, String>((ref, anamnesisId) async {
      final service = ref.watch(anamnesisServiceProvider);
      return await service.getInsights(anamnesisId);
    });

// ========== SUGGESTIONS ==========

/// Provider de sugestões de treino para uma anamnese
final workoutSuggestionsProvider =
    FutureProvider.family<List<WorkoutSuggestion>, String>((
      ref,
      anamnesisId,
    ) async {
      final service = ref.watch(anamnesisServiceProvider);
      return await service.getSuggestions(anamnesisId);
    });

// ========== NOTIFIERS (para ações) ==========

/// Notifier para gerenciar processo de responder anamnese
class AnamnesisAnswerNotifier extends Notifier<AsyncValue<void>> {
  FirebaseAnamnesisService get _anamnesisService =>
      ref.read(anamnesisServiceProvider);
  GeminiService get _geminiService => ref.read(geminiServiceProvider);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Salva uma resposta e gera próxima pergunta se necessário
  Future<AnamnesisQuestion?> saveAnswerAndGetNext({
    required String anamnesisId,
    required AnamnesisAnswer answer,
    required List<AnamnesisQuestion> allQuestions,
    required List<AnamnesisAnswer> allAnswers,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Salva resposta
      await _anamnesisService.saveAnswer(
        anamnesisId: anamnesisId,
        answer: answer,
      );

      // Atualiza lista de respostas
      final updatedAnswers = [...allAnswers, answer];

      // IA gera próxima pergunta
      final nextQuestion = await _geminiService.generateNextQuestion(
        previousQuestions: allQuestions,
        answers: updatedAnswers,
      );

      if (nextQuestion != null) {
        // Adiciona pergunta dinâmica
        await _anamnesisService.addDynamicQuestion(
          anamnesisId: anamnesisId,
          question: nextQuestion,
        );
      }

      state = const AsyncValue.data(null);
      return nextQuestion;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Finaliza anamnese e gera análise
  Future<AnamnesisInsights> completeAndAnalyze({
    required String anamnesisId,
    required List<AnamnesisQuestion> questions,
    required List<AnamnesisAnswer> answers,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Marca como completa
      await _anamnesisService.completeAnamnesis(anamnesisId);

      // IA analisa
      final insights = await _geminiService.analyzeAnamnesis(
        anamnesisId: anamnesisId,
        questions: questions,
        answers: answers,
      );

      // Salva insights
      await _anamnesisService.saveInsights(
        anamnesisId: anamnesisId,
        insights: insights,
      );

      state = const AsyncValue.data(null);
      return insights;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final anamnesisAnswerNotifierProvider =
    NotifierProvider<AnamnesisAnswerNotifier, AsyncValue<void>>(() {
      return AnamnesisAnswerNotifier();
    });

/// Notifier para gerar sugestões de treino
class WorkoutSuggestionNotifier extends Notifier<AsyncValue<void>> {
  RAGWorkoutService get _ragService => ref.read(ragWorkoutServiceProvider);
  FirebaseAnamnesisService get _anamnesisService =>
      ref.read(anamnesisServiceProvider);
  FirebaseExerciseService get _exerciseService =>
      ref.read(firebaseExerciseServiceProvider);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Gera sugestões de treino baseadas na anamnese
  Future<List<WorkoutSuggestion>> generateSuggestions({
    required String anamnesisId,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Busca insights
      final insights = await _anamnesisService.getInsights(anamnesisId);
      if (insights == null) {
        throw Exception('Anamnese não foi analisada ainda');
      }

      // Busca exercícios disponíveis
      final exercises = await _exerciseService.getAllExercises();

      // Gera sugestões
      final suggestions = await _ragService.generateWorkoutSuggestions(
        anamnesisId: anamnesisId,
        insights: insights,
        availableExercises: exercises,
      );

      // Salva sugestões
      for (final suggestion in suggestions) {
        await _anamnesisService.saveSuggestion(suggestion);
      }

      state = const AsyncValue.data(null);
      return suggestions;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Aprova uma sugestão de treino
  Future<void> approveSuggestion(String suggestionId) async {
    state = const AsyncValue.loading();

    try {
      await _anamnesisService.approveSuggestion(suggestionId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final workoutSuggestionNotifierProvider =
    NotifierProvider<WorkoutSuggestionNotifier, AsyncValue<void>>(() {
      return WorkoutSuggestionNotifier();
    });
