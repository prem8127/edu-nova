import '../../models/class_schedule_model.dart';

abstract class ScheduleRepository {
  Future<List<ScheduledClass>> getAllScheduledClasses();
  Future<List<ScheduledClass>> getClassesForCourse(String courseId);
  Future<List<ScheduledClass>> getClassesForTeacher(String teacherId);
  Future<void> upsertScheduledClass(ScheduledClass scheduledClass);
  Future<void> deleteScheduledClass(String id);

  /// Manual Zoom-link field: teacher pastes/updates the link for a class.
  Future<void> setZoomLink(String scheduledClassId, String link);
}
