import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/quiz_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/repository_providers.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String quizId;
  const QuizScreen({super.key, required this.quizId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final Map<String, int> _answers = {}; // questionId -> selected option index
  bool _submitted = false;
  int _score = 0;

  Future<void> _submit(QuizModel quiz) async {
    int score = 0;
    for (final q in quiz.questions) {
      if (_answers[q.id] == q.correctOptionIndex) score++;
    }
    final user = ref.read(authControllerProvider).value;
    if (user != null) {
      await ref.read(quizRepositoryProvider).recordAttempt(
            QuizAttempt(
              id: const Uuid().v4(),
              studentId: user.id,
              quizId: quiz.id,
              courseId: quiz.courseId,
              score: score,
              totalQuestions: quiz.questions.length,
              takenAt: DateTime.now(),
            ),
          );
      ref.invalidate(subjectProgressProvider);
      ref.invalidate(laggingSubjectsProvider);
    }
    setState(() {
      _submitted = true;
      _score = score;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: FutureBuilder<QuizModel?>(
        future: ref.watch(quizRepositoryProvider).getQuizById(widget.quizId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final quiz = snapshot.data;
          if (quiz == null) return const Center(child: Text('Quiz not found'));

          if (_submitted) {
            return Center(
              child: Text(
                'You scored $_score / ${quiz.questions.length}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...quiz.questions.map((q) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q.question,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          ...List.generate(q.options.length, (i) {
                            return RadioListTile<int>(
                              value: i,
                              groupValue: _answers[q.id],
                              title: Text(q.options[i]),
                              onChanged: (v) => setState(() => _answers[q.id] = v!),
                            );
                          }),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _answers.length == quiz.questions.length
                    ? () => _submit(quiz)
                    : null,
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }
}
