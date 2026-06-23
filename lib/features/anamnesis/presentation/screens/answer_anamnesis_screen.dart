import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/core/models/anamnesis_model.dart';
import 'package:new_gym_app/features/anamnesis/presentation/providers/anamnesis_providers.dart';

/// Tela para Aluno responder anamnese (fluxo progressivo)
class AnswerAnamnesisScreen extends ConsumerStatefulWidget {
  final String anamnesisId;

  const AnswerAnamnesisScreen({super.key, required this.anamnesisId});

  @override
  ConsumerState<AnswerAnamnesisScreen> createState() =>
      _AnswerAnamnesisScreenState();
}

class _AnswerAnamnesisScreenState extends ConsumerState<AnswerAnamnesisScreen> {
  final TextEditingController _answerController = TextEditingController();
  int _currentQuestionIndex = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anamnesisAsync = ref.watch(anamnesisProvider(widget.anamnesisId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder Anamnese'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: anamnesisAsync.when(
        data: (anamnesis) {
          if (anamnesis == null) {
            return const Center(child: Text('Anamnese não encontrada'));
          }

          // Verifica se já foi completada
          if (anamnesis.status == AnamnesisStatus.completed ||
              anamnesis.status == AnamnesisStatus.analyzed) {
            return _buildCompletedView();
          }

          final questions = anamnesis.questions;
          final answers = anamnesis.answers;

          // Encontra próxima pergunta não respondida
          _currentQuestionIndex = answers.length;

          if (_currentQuestionIndex >= questions.length) {
            return _buildCompletedView();
          }

          final currentQuestion = questions[_currentQuestionIndex];
          final progress = (_currentQuestionIndex / questions.length);

          return Column(
            children: [
              // Barra de progresso
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                minHeight: 8,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Pergunta ${_currentQuestionIndex + 1} de ${questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Pergunta atual
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pergunta
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (currentQuestion.isDynamic)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '✨ Pergunta IA',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                currentQuestion.text,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (currentQuestion.isRequired)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    '* Obrigatório',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Campo de resposta
                      _buildAnswerField(currentQuestion),
                    ],
                  ),
                ),
              ),

              // Botões
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_currentQuestionIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _currentQuestionIndex--;
                              _answerController.clear();
                            });
                          },
                          child: const Text('Anterior'),
                        ),
                      ),
                    if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _submitAnswer(anamnesis, currentQuestion),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _currentQuestionIndex == questions.length - 1
                                    ? 'Finalizar'
                                    : 'Próxima',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Erro ao carregar anamnese: $error')),
      ),
    );
  }

  Widget _buildAnswerField(AnamnesisQuestion question) {
    switch (question.type) {
      case QuestionType.text:
        return TextField(
          controller: _answerController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Digite sua resposta...',
            border: OutlineInputBorder(),
          ),
        );

      case QuestionType.yesNo:
        return Column(
          children: [
            _buildOptionButton('Sim', question),
            const SizedBox(height: 12),
            _buildOptionButton('Não', question),
          ],
        );

      case QuestionType.multipleChoice:
        if (question.options == null || question.options!.isEmpty) {
          return TextField(
            controller: _answerController,
            decoration: const InputDecoration(
              hintText: 'Digite sua resposta...',
              border: OutlineInputBorder(),
            ),
          );
        }
        return Column(
          children: question.options!.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionButton(option, question),
            );
          }).toList(),
        );

      case QuestionType.scale:
        return Column(
          children: List.generate(10, (index) {
            final value = (index + 1).toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildOptionButton(value, question),
            );
          }),
        );

      default:
        return TextField(
          controller: _answerController,
          decoration: const InputDecoration(
            hintText: 'Digite sua resposta...',
            border: OutlineInputBorder(),
          ),
        );
    }
  }

  Widget _buildOptionButton(String option, AnamnesisQuestion question) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _answerController.text = option;
          _submitAnswer(null, question);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Text(option),
      ),
    );
  }

  Future<void> _submitAnswer(
    Anamnesis? anamnesis,
    AnamnesisQuestion question,
  ) async {
    final answer = _answerController.text.trim();

    if (answer.isEmpty && question.isRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta pergunta é obrigatória'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Cria resposta
      final anamnesisAnswer = AnamnesisAnswer(
        questionId: question.id,
        value: answer,
        answeredAt: DateTime.now(),
      );

      // Salva e busca próxima pergunta
      final anamnesisData = await ref.read(
        anamnesisProvider(widget.anamnesisId).future,
      );

      if (anamnesisData == null) {
        throw Exception('Anamnese não encontrada');
      }

      final nextQuestion = await ref
          .read(anamnesisAnswerNotifierProvider.notifier)
          .saveAnswerAndGetNext(
            anamnesisId: widget.anamnesisId,
            answer: anamnesisAnswer,
            allQuestions: anamnesisData.questions,
            allAnswers: anamnesisData.answers,
          );

      // Se não há próxima pergunta, finaliza
      if (nextQuestion == null &&
          _currentQuestionIndex >= anamnesisData.questions.length - 1) {
        await _completeAnamnesis(anamnesisData);
      } else {
        // Limpa campo e avança
        _answerController.clear();
        setState(() {
          _currentQuestionIndex++;
        });

        // Invalida provider para recarregar
        ref.invalidate(anamnesisProvider(widget.anamnesisId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar resposta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _completeAnamnesis(Anamnesis anamnesis) async {
    if (!mounted) return;

    // Mostra loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '🤖 IA analisando suas respostas...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      // Finaliza e analisa
      await ref
          .read(anamnesisAnswerNotifierProvider.notifier)
          .completeAndAnalyze(
            anamnesisId: widget.anamnesisId,
            questions: anamnesis.questions,
            answers: anamnesis.answers,
          );

      if (!mounted) return;

      // Fecha loading
      Navigator.of(context).pop();

      // Mostra sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Anamnese concluída!'),
          backgroundColor: Colors.green,
        ),
      );

      // Volta para tela anterior
      context.pop();
    } catch (e) {
      if (!mounted) return;

      // Fecha loading
      Navigator.of(context).pop();

      // Mostra erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao finalizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCompletedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Anamnese Concluída!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Suas respostas foram enviadas para análise.\n'
              'Seu personal irá avaliar e criar seu treino personalizado.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }
}
