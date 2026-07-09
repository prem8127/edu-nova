import '../../models/class_schedule_model.dart';
import '../interfaces/schedule_repository.dart';
import 'local_storage_service.dart';

class LocalScheduleRepository implements ScheduleRepository {
  final _storage = LocalStorageService.instance;

  Future<List<ScheduledClass>> _readAll() async {
    final list = await _storage.readList(StorageKeys.scheduledClasses);
    return list.map(ScheduledClass.fromJson).toList();
  }

  Future<void> _writeAll(List<ScheduledClass> items) async {
    await _storage.writeList(
      StorageKeys.scheduledClasses,
      items.map((c) => c.toJson()).toList(),
    );
  }

  @override
  Future<List<ScheduledClass>> getAllScheduledClasses() => _readAll();

  @override
  Future<List<ScheduledClass>> getClassesForCourse(String courseId) async {
    final all = await _readAll();
    return all.where((c) => c.courseId == courseId).toList();
  }

  @override
  Future<List<ScheduledClass>> getClassesForTeacher(String teacherId) async {
    final all = await _readAll();
    return all.where((c) => c.teacherId == teacherId).toList();
  }

  @override
  Future<void> upsertScheduledClass(ScheduledClass scheduledClass) async {
    final all = await _readAll();
    final idx = all.indexWhere((c) => c.id == scheduledClass.id);
    if (idx >= 0) {
      all[idx] = scheduledClass;
    } else {
      all.add(scheduledClass);
    }
    await _writeAll(all);
  }

  @override
  Future<void> deleteScheduledClass(String id) async {
    final all = await _readAll();
    all.removeWhere((c) => c.id == id);
    await _writeAll(all);
  }

  @override
  Future<void> setZoomLink(String scheduledClassId, String link) async {
    final all = await _readAll();
    final idx = all.indexWhere((c) => c.id == scheduledClassId);
    if (idx < 0) return;
    all[idx] = all[idx].copyWith(zoomLink: link);
    await _writeAll(all);
  }
}
