import '../../core/constants/app_enums.dart';
import '../../models/course_model.dart';

abstract class CourseRepository {
  Future<List<CourseModel>> getAllCourses();
  Future<List<CourseModel>> getCoursesByGradeAndSubject(
      Grade grade, Subject? subject);
  Future<List<CourseModel>> getCoursesByTeacher(String teacherId);
  Future<CourseModel?> getCourseById(String id);
  Future<void> upsertCourse(CourseModel course);
  Future<void> deleteCourse(String id);

  /// Paywall: purchased course ids for the *current* student.
  Future<List<String>> getPurchasedCourseIds();
  Future<void> purchaseCourse(String courseId);
  Future<bool> isCourseUnlocked(String courseId);
}
