import '../../models/doubt_chat_model.dart';

abstract class DoubtChatRepository {
  /// Returns the existing thread for this student+teacher+course, or
  /// creates one. Enforces the "private 1:1 thread per student" rule.
  Future<DoubtThread> getOrCreateThread({
    required String studentId,
    required String teacherId,
    required String courseId,
  });

  Future<List<DoubtThread>> getThreadsForStudent(String studentId);
  Future<List<DoubtThread>> getThreadsForTeacher(String teacherId);

  Future<List<DoubtMessage>> getMessages(String threadId);
  Future<void> sendMessage(DoubtMessage message);
}
