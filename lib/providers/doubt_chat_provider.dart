import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/doubt_chat_model.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

final threadsForCurrentStudentProvider =
    FutureProvider<List<DoubtThread>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return [];
  return ref.watch(doubtChatRepositoryProvider).getThreadsForStudent(user.id);
});

final threadsForCurrentTeacherProvider =
    FutureProvider<List<DoubtThread>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return [];
  return ref.watch(doubtChatRepositoryProvider).getThreadsForTeacher(user.id);
});

final messagesForThreadProvider =
    FutureProvider.family<List<DoubtMessage>, String>((ref, threadId) async {
  return ref.watch(doubtChatRepositoryProvider).getMessages(threadId);
});

/// Student taps "Ask a doubt" on a course -> gets (or creates) their
/// private thread with that course's teacher.
final openDoubtThreadProvider = Provider((ref) {
  final repo = ref.watch(doubtChatRepositoryProvider);
  return ({
    required String studentId,
    required String teacherId,
    required String courseId,
  }) {
    return repo.getOrCreateThread(
      studentId: studentId,
      teacherId: teacherId,
      courseId: courseId,
    );
  };
});

final sendDoubtMessageProvider = Provider((ref) {
  final repo = ref.watch(doubtChatRepositoryProvider);
  final uuid = const Uuid();
  return (String threadId, String senderId, String text) async {
    await repo.sendMessage(DoubtMessage(
      id: uuid.v4(),
      threadId: threadId,
      senderId: senderId,
      text: text,
      sentAt: DateTime.now(),
    ));
    ref.invalidate(messagesForThreadProvider(threadId));
  };
});
