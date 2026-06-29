import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gym_app/core/models/anamnesis_insights_model.dart';
import 'package:new_gym_app/core/models/anamnesis_model.dart';
import 'package:new_gym_app/core/models/workout_suggestion_model.dart';
import 'package:new_gym_app/core/services/firebase_anamnesis_service.dart';
import 'package:new_gym_app/core/services/firebase_exercise_service.dart';
import 'package:new_gym_app/core/services/gemini_service.dart';
import 'package:new_gym_app/core/services/rag_workout_service.dart';
import 'package:new_gym_app/core/utils/anamnesis_template.dart';
import 'package:new_gym_app/features/exercise_detail/presentation/providers/exercise_provider.dart';
import 'package:new_gym_app/features/students/presentation/providers/workout_provider.dart';

// ========== SERVICES ==========

/// Provider do serviço de anamnese
final anamnesisServiceProvider = Provider<FirebaseAnamnesisService>((ref) {
  return FirebaseAnamnesisService();
});

const _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

/// Provider do serviço Gemini (IA)
final geminiServiceProvider = Provider<GeminiService>((ref) {
  if (_geminiApiKey.isEmpty) {
    throw Exception(
      'GEMINI_API_KEY não configurada.\n'
      'Preencha o arquivo .env e rode via VS Code (launch.json) '
      'ou passe --dart-define-from-file=.env ao executar.',
    );
  }
  return GeminiService(apiKey: _geminiApiKey);
});

/// Provider do serviço RAG (sugestões de treino)
final ragWorkoutServiceProvider = Provider<RAGWorkoutService>((ref) {
  if (_geminiApiKey.isEmpty) {
    throw Exception(
      'GEMINI_API_KEY não configurada.\n'
      'Preencha o arquivo .env e rode via VS Code (launch.json) '
      'ou passe --dart-define-from-file=.env ao executar.',
    );
  }
  return RAGWorkoutService(apiKey: _geminiApiKey);
});

// ========== ANAMNESIS ==========

/// Stream de anamneses do aluno — usado pelo próprio aluno (home screen).
/// Query filtra apenas por studentId; regra Firestore satisfeita porque
/// request.auth.uid == studentId.
final studentAnamnesesProvider = StreamProvider.family<List<Anamnesis>, String>(
  (ref, studentId) {
    final service = ref.watch(anamnesisServiceProvider);
    return service.getStudentAnamneses(studentId);
  },
);

/// Stream de anamneses de um aluno vistas pelo PT — usado em StudentDetailScreen.
/// A query filtra por (personalId, studentId) para satisfazer a regra Firestore
/// que exige resource.data.personalId == request.auth.uid.
final ptStudentAnamnesesProvider =
    StreamProvider.family<List<Anamnesis>, (String, String)>(
      (ref, params) {
        final (studentId, personalId) = params;
        final service = ref.watch(anamnesisServiceProvider);
        return service.getStudentAnamnesesByPersonal(
          studentId: studentId,
          personalId: personalId,
        );
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

  /// Salva uma resposta. Quando a última pergunta BASE for respondida,
  /// faz UMA chamada à IA para gerar o lote de perguntas diagnósticas.
  Future<bool> saveAnswerAndGetNext({
    required String anamnesisId,
    required AnamnesisAnswer answer,
    required List<AnamnesisQuestion> allQuestions,
    required List<AnamnesisAnswer> allAnswers,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _anamnesisService.saveAnswer(
        anamnesisId: anamnesisId,
        answer: answer,
      );

      final updatedAnswers = [...allAnswers, answer];

      // Injeta perguntas sexo-específicas quando q2 é respondida (uma única vez)
      if (answer.questionId == 'q2') {
        final sexValue = answer.value?.toString() ?? '';
        final alreadyInjected = allQuestions.any(
          (q) => q.id.startsWith('qf') || q.id.startsWith('qm'),
        );

        if (!alreadyInjected) {
          List<AnamnesisQuestion> specific = [];
          if (sexValue == 'Feminino') {
            specific = AnamnesisTemplate.getFemaleQuestions();
          } else if (sexValue == 'Masculino') {
            specific = AnamnesisTemplate.getMaleQuestions();
          }

          if (specific.isNotEmpty) {
            await _anamnesisService.addDynamicQuestions(
              anamnesisId: anamnesisId,
              questions: specific,
            );
            state = const AsyncValue.data(null);
            return true;
          }
        }
      }

      final baseQuestions = allQuestions.where((q) => !q.isDynamic).toList();
      final hasDynamicAlready = allQuestions.any((q) => q.isDynamic);

      // Dispara a IA UMA única vez, após todas as perguntas base respondidas
      if (!hasDynamicAlready &&
          updatedAnswers.length >= baseQuestions.length) {
        final batch = await _geminiService.generateDiagnosticBatch(
          coreQuestions: baseQuestions,
          coreAnswers: updatedAnswers,
        );

        if (batch.isNotEmpty) {
          await _anamnesisService.addDynamicQuestions(
            anamnesisId: anamnesisId,
            questions: batch,
          );
          state = const AsyncValue.data(null);
          return true; // há mais perguntas
        }
      }

      state = const AsyncValue.data(null);
      return false; // sem novas perguntas adicionadas
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

  /// Gera sugestões de treino baseadas na anamnese.
  /// A IA sugere exercícios livremente (ACSM/NSCA). Os exercícios só são
  /// salvos na biblioteca quando o personal aprovar a sugestão.
  Future<List<WorkoutSuggestion>> generateSuggestions({
    required String anamnesisId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final insights = await _anamnesisService.getInsights(anamnesisId);
      if (insights == null) {
        throw Exception('Anamnese não foi analisada ainda');
      }

      final suggestions = await _ragService.generateWorkoutSuggestions(
        anamnesisId: anamnesisId,
        insights: insights,
      );

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

  /// Aprova sugestão, cria o treino no Firestore e retorna o workoutId.
  /// [editedExercises] permite ao personal ajustar a lista antes de aprovar.
  Future<String> approveSuggestion(
    WorkoutSuggestion suggestion, {
    List<ExerciseSuggestion>? editedExercises,
  }) async {
    state = const AsyncValue.loading();

    try {
      final anamnesis =
          await _anamnesisService.getAnamnesis(suggestion.anamnesisId);
      if (anamnesis == null) throw Exception('Anamnese não encontrada');

      await _anamnesisService.approveSuggestion(suggestion.id);

      final workoutService = ref.read(workoutServiceProvider);

      final workoutId = await workoutService.createWorkout(
        name: suggestion.name,
        studentId: anamnesis.studentId,
        createdBy: anamnesis.personalId,
      );

      final exercises = editedExercises ?? suggestion.exercises;
      for (final exercise in exercises) {
        // Garante que o exercício existe na biblioteca (cria se necessário)
        final exerciseId = exercise.exerciseId.isNotEmpty
            ? exercise.exerciseId
            : await _exerciseService.findOrCreateByName(
                name: exercise.exerciseName,
                workoutType: exercise.muscleGroup,
                series: exercise.series,
                reps: _parseReps(exercise.reps),
                instructions: exercise.notes,
              );

        await workoutService.addExerciseToWorkout(
          workoutId: workoutId,
          exerciseId: exerciseId,
          series: exercise.series,
          reps: _parseReps(exercise.reps),
          notes: exercise.notes.isNotEmpty ? exercise.notes : null,
        );
      }

      state = const AsyncValue.data(null);
      return workoutId;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Converte reps string ("10-12", "30 segundos") para int.
  int _parseReps(String repsStr) {
    final numbers = RegExp(r'\d+')
        .allMatches(repsStr)
        .map((m) => int.parse(m.group(0)!))
        .toList();
    return numbers.isEmpty ? 10 : numbers.last;
  }
}

final workoutSuggestionNotifierProvider =
    NotifierProvider<WorkoutSuggestionNotifier, AsyncValue<void>>(() {
      return WorkoutSuggestionNotifier();
    });
