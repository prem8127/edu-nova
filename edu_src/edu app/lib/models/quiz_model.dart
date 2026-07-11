class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String,
        question: json['question'] as String,
        options:
            (json['options'] as List<dynamic>).map((e) => e as String).toList(),
        correctOptionIndex: json['correctOptionIndex'] as int,
      );
}

class QuizModel {
  final String id;
  final String courseId;
  final String title;
  final List<QuizQuestion> questions;

  const QuizModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.questions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'title': title,
        'questions': questions.map((q) => q.toJson()).toList(),
      };

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
        id: json['id'] as String,
        courseId: json['courseId'] as String,
        title: json['title'] as String,
        questions: (json['questions'] as List<dynamic>)
            .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
            .toList(),
      );
}

/// Result of one attempt. This is what the lagging-area tracker aggregates
/// over, per subject, to flag weak topics on the dashboard.
class QuizAttempt {
  final String id;
  final String studentId;
  final String quizId;
  final String courseId;
  final int score; // number correct
  final int totalQuestions;
  final DateTime takenAt;

  const QuizAttempt({
    required this.id,
    required this.studentId,
    required this.quizId,
    required this.courseId,
    required this.score,
    required this.totalQuestions,
    required this.takenAt,
  });

  double get percentage =>
      totalQuestions == 0 ? 0 : (score / totalQuestions) * 100;

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'quizId': quizId,
        'courseId': courseId,
        'score': score,
        'totalQuestions': totalQuestions,
        'takenAt': takenAt.toIso8601String(),
      };

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        quizId: json['quizId'] as String,
        courseId: json['courseId'] as String,
        score: json['score'] as int,
        totalQuestions: json['totalQuestions'] as int,
        takenAt: DateTime.parse(json['takenAt'] as String),
      );
}
