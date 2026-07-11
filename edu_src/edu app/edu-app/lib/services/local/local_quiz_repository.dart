import '../../models/quiz_model.dart';
import '../interfaces/quiz_repository.dart';
import 'local_storage_service.dart';

class LocalQuizRepository implements QuizRepository {
  final _storage = LocalStorageService.instance;

  @override
  Future<List<QuizModel>> getQuizzesByCourse(String courseId) async {
    final list = await _storage.readList(StorageKeys.quizzes);
    return list
        .map(QuizModel.fromJson)
        .where((q) => q.courseId == courseId)
        .toList();
  }

  @override
  Future<QuizModel?> getQuizById(String id) async {
    final list = await _storage.readList(StorageKeys.quizzes);
    final quizzes = list.map(QuizModel.fromJson);
    try {
      return quizzes.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertQuiz(QuizModel quiz) async {
    final list = await _storage.readList(StorageKeys.quizzes);
    final quizzes = list.map(QuizModel.fromJson).toList();
    final idx = quizzes.indexWhere((q) => q.id == quiz.id);
    if (idx >= 0) {
      quizzes[idx] = quiz;
    } else {
      quizzes.add(quiz);
    }
    await _storage.writeList(
      StorageKeys.quizzes,
      quizzes.map((q) => q.toJson()).toList(),
    );
  }

  @override
  Future<void> recordAttempt(QuizAttempt attempt) async {
    final list = await _storage.readList(StorageKeys.quizAttempts);
    final attempts = list.map(QuizAttempt.fromJson).toList();
    attempts.add(attempt);
    await _storage.writeList(
      StorageKeys.quizAttempts,
      attempts.map((a) => a.toJson()).toList(),
    );
  }

  @override
  Future<List<QuizAttempt>> getAttemptsForStudent(String studentId) async {
    final list = await _storage.readList(StorageKeys.quizAttempts);
    return list
        .map(QuizAttempt.fromJson)
        .where((a) => a.studentId == studentId)
        .toList();
  }
}
