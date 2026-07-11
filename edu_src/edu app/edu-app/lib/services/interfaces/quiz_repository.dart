import '../../models/quiz_model.dart';

abstract class QuizRepository {
  Future<List<QuizModel>> getQuizzesByCourse(String courseId);
  Future<QuizModel?> getQuizById(String id);
  Future<void> upsertQuiz(QuizModel quiz);

  Future<void> recordAttempt(QuizAttempt attempt);
  Future<List<QuizAttempt>> getAttemptsForStudent(String studentId);
}
