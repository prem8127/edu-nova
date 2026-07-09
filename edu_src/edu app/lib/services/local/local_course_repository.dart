import '../../core/constants/app_enums.dart';
import '../../models/course_model.dart';
import '../interfaces/course_repository.dart';
import 'local_storage_service.dart';

class LocalCourseRepository implements CourseRepository {
  final _storage = LocalStorageService.instance;

  @override
  Future<List<CourseModel>> getAllCourses() async {
    final list = await _storage.readList(StorageKeys.courses);
    return list.map(CourseModel.fromJson).toList();
  }

  @override
  Future<List<CourseModel>> getCoursesByGradeAndSubject(
      Grade grade, Subject? subject) async {
    final all = await getAllCourses();
    return all.where((c) {
      final gradeMatch = c.grade == grade;
      final subjectMatch = subject == null || c.subject == subject;
      return gradeMatch && subjectMatch;
    }).toList();
  }

  @override
  Future<List<CourseModel>> getCoursesByTeacher(String teacherId) async {
    final all = await getAllCourses();
    return all.where((c) => c.teacherId == teacherId).toList();
  }

  @override
  Future<CourseModel?> getCourseById(String id) async {
    final all = await getAllCourses();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertCourse(CourseModel course) async {
    final all = await getAllCourses();
    final idx = all.indexWhere((c) => c.id == course.id);
    if (idx >= 0) {
      all[idx] = course;
    } else {
      all.add(course);
    }
    await _storage.writeList(
      StorageKeys.courses,
      all.map((c) => c.toJson()).toList(),
    );
  }

  @override
  Future<void> deleteCourse(String id) async {
    final all = await getAllCourses();
    all.removeWhere((c) => c.id == id);
    await _storage.writeList(
      StorageKeys.courses,
      all.map((c) => c.toJson()).toList(),
    );
  }

  @override
  Future<List<String>> getPurchasedCourseIds() async {
    final json = await _storage.readObject(StorageKeys.purchasedCourseIds);
    if (json == null) return [];
    return (json['ids'] as List<dynamic>).map((e) => e as String).toList();
  }

  @override
  Future<void> purchaseCourse(String courseId) async {
    final ids = await getPurchasedCourseIds();
    if (!ids.contains(courseId)) {
      ids.add(courseId);
      await _storage.writeObject(StorageKeys.purchasedCourseIds, {'ids': ids});
    }
  }

  @override
  Future<bool> isCourseUnlocked(String courseId) async {
    final course = await getCourseById(courseId);
    if (course == null) return false;
    if (!course.requiresPurchase) return true;
    final purchased = await getPurchasedCourseIds();
    return purchased.contains(courseId);
  }
}
