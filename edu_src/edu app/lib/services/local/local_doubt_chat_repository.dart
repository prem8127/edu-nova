import 'package:uuid/uuid.dart';

import '../../models/doubt_chat_model.dart';
import '../interfaces/doubt_chat_repository.dart';
import 'local_storage_service.dart';

class LocalDoubtChatRepository implements DoubtChatRepository {
  final _storage = LocalStorageService.instance;
  final _uuid = const Uuid();

  Future<List<DoubtThread>> _readThreads() async {
    final list = await _storage.readList(StorageKeys.doubtThreads);
    return list.map(DoubtThread.fromJson).toList();
  }

  Future<void> _writeThreads(List<DoubtThread> items) async {
    await _storage.writeList(
      StorageKeys.doubtThreads,
      items.map((t) => t.toJson()).toList(),
    );
  }

  @override
  Future<DoubtThread> getOrCreateThread({
    required String studentId,
    required String teacherId,
    required String courseId,
  }) async {
    final threads = await _readThreads();
    try {
      return threads.firstWhere(
        (t) =>
            t.studentId == studentId &&
            t.teacherId == teacherId &&
            t.courseId == courseId,
      );
    } catch (_) {
      final newThread = DoubtThread(
        id: _uuid.v4(),
        studentId: studentId,
        teacherId: teacherId,
        courseId: courseId,
        createdAt: DateTime.now(),
      );
      threads.add(newThread);
      await _writeThreads(threads);
      return newThread;
    }
  }

  @override
  Future<List<DoubtThread>> getThreadsForStudent(String studentId) async {
    final all = await _readThreads();
    return all.where((t) => t.studentId == studentId).toList();
  }

  @override
  Future<List<DoubtThread>> getThreadsForTeacher(String teacherId) async {
    final all = await _readThreads();
    return all.where((t) => t.teacherId == teacherId).toList();
  }

  @override
  Future<List<DoubtMessage>> getMessages(String threadId) async {
    final list = await _storage.readList(StorageKeys.doubtMessages);
    return list
        .map(DoubtMessage.fromJson)
        .where((m) => m.threadId == threadId)
        .toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
  }

  @override
  Future<void> sendMessage(DoubtMessage message) async {
    final list = await _storage.readList(StorageKeys.doubtMessages);
    final messages = list.map(DoubtMessage.fromJson).toList();
    messages.add(message);
    await _storage.writeList(
      StorageKeys.doubtMessages,
      messages.map((m) => m.toJson()).toList(),
    );
  }
}
