import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_enums.dart';
import '../models/class_schedule_model.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';
import 'course_provider.dart';
import 'progress_provider.dart';
import 'repository_providers.dart';

final allTeachersProvider = FutureProvider<List<AppUser>>((ref) async {
  final users = await ref.watch(userRepositoryProvider).getAllUsers();
  return users.where((u) => u.role == UserRole.teacher).toList();
});

final allStudentsProvider = FutureProvider<List<AppUser>>((ref) async {
  final users = await ref.watch(userRepositoryProvider).getAllUsers();
  return users.where((u) => u.role == UserRole.student).toList();
});

/// Super Admin actions: add/remove teachers, platform-wide visibility.
final adminActionsProvider = Provider((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  final uuid = const Uuid();
  return (
    addTeacher: (String name, List<Subject> subjects) async {
      final teacher = AppUser(
        id: uuid.v4(),
        name: name,
        role: UserRole.teacher,
        assignedSubjects: subjects,
      );
      await userRepo.upsertUser(teacher);
      ref.invalidate(allTeachersProvider);
    },
    removeTeacher: (String teacherId) async {
      await userRepo.deleteUser(teacherId);
      ref.invalidate(allTeachersProvider);
    },
  );
});

/// One row of the admin's course-authoring list: course + resolved
/// teacher name, so the list doesn't have to look the teacher up itself.
class CourseAuthoringRow {
  final CourseModel course;
  final String teacherName;
  const CourseAuthoringRow({required this.course, required this.teacherName});
}

final allCoursesForAdminProvider = FutureProvider<List<CourseAuthoringRow>>((ref) async {
  final courses = await ref.watch(courseRepositoryProvider).getAllCourses();
  final userRepo = ref.watch(userRepositoryProvider);
  final rows = <CourseAuthoringRow>[];
  for (final course in courses) {
    final teacher = await userRepo.getUserById(course.teacherId);
    rows.add(CourseAuthoringRow(course: course, teacherName: teacher?.name ?? 'Unassigned'));
  }
  rows.sort((a, b) {
    final gradeCompare = a.course.grade.index.compareTo(b.course.grade.index);
    if (gradeCompare != 0) return gradeCompare;
    return a.course.title.compareTo(b.course.title);
  });
  return rows;
});

/// Super Admin actions: create, edit, and delete courses. This is the
/// course-authoring/content-management layer — everything else (student
/// course lists, teacher's assigned courses, pricing/revenue) reads from
/// the same [CourseModel] rows these actions write.
final courseAuthoringActionsProvider = Provider((ref) {
  final courseRepo = ref.watch(courseRepositoryProvider);
  final uuid = const Uuid();

  void invalidateDependents(CourseModel course) {
    ref.invalidate(allCoursesForAdminProvider);
    ref.invalidate(coursesForCurrentStudentProvider);
    ref.invalidate(coursesForTeacherProvider(course.teacherId));
  }

  return (
    createCourse: ({
      required String title,
      required String description,
      required Subject subject,
      required Grade grade,
      required String teacherId,
      required double price,
    }) async {
      final course = CourseModel(
        id: uuid.v4(),
        title: title,
        description: description,
        subject: subject,
        grade: grade,
        teacherId: teacherId,
        price: price,
      );
      await courseRepo.upsertCourse(course);
      invalidateDependents(course);
    },
    updateCourse: (CourseModel course) async {
      await courseRepo.upsertCourse(course);
      invalidateDependents(course);
    },
    deleteCourse: (CourseModel course) async {
      await courseRepo.deleteCourse(course.id);
      invalidateDependents(course);
    },
  );
});


final platformOverviewProvider = FutureProvider<PlatformOverview>((ref) async {
  final users = await ref.watch(userRepositoryProvider).getAllUsers();
  final courses = await ref.watch(courseRepositoryProvider).getAllCourses();
  return PlatformOverview(
    totalStudents: users.where((u) => u.role == UserRole.student).length,
    totalTeachers: users.where((u) => u.role == UserRole.teacher).length,
    totalCourses: courses.length,
  );
});

class PlatformOverview {
  final int totalStudents;
  final int totalTeachers;
  final int totalCourses;
  const PlatformOverview({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalCourses,
  });
}

/// One row of the admin's student-monitoring list: the student plus their
/// lagging subjects, so admin sees the same bottleneck data the student's
/// own dashboard shows — this is the "full visibility" layer.
class StudentProgressSummary {
  final AppUser student;
  final List<SubjectProgress> laggingSubjects;

  const StudentProgressSummary({
    required this.student,
    required this.laggingSubjects,
  });
}

final allStudentProgressProvider =
    FutureProvider<List<StudentProgressSummary>>((ref) async {
  final students = await ref.watch(allStudentsProvider.future);
  final summaries = <StudentProgressSummary>[];
  for (final student in students) {
    final lagging =
        await ref.watch(laggingSubjectsForStudentProvider(student.id).future);
    summaries.add(StudentProgressSummary(student: student, laggingSubjects: lagging));
  }
  // Students with the most lagging subjects surface first — that's who
  // the admin most likely needs to look at.
  summaries.sort(
      (a, b) => b.laggingSubjects.length.compareTo(a.laggingSubjects.length));
  return summaries;
});

/// One row of the admin's platform-wide class oversight list.
class ClassOverviewRow {
  final ScheduledClass scheduledClass;
  final String courseTitle;
  final String teacherName;

  const ClassOverviewRow({
    required this.scheduledClass,
    required this.courseTitle,
    required this.teacherName,
  });
}

/// Every scheduled class across every teacher/course, with names resolved
/// — the admin's "everything happening on the platform" calendar view.
final allScheduledClassesOverviewProvider =
    FutureProvider<List<ClassOverviewRow>>((ref) async {
  final scheduleRepo = ref.watch(scheduleRepositoryProvider);
  final courseRepo = ref.watch(courseRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  final classes = await scheduleRepo.getAllScheduledClasses();
  final rows = <ClassOverviewRow>[];
  for (final c in classes) {
    final course = await courseRepo.getCourseById(c.courseId);
    final teacher = await userRepo.getUserById(c.teacherId);
    rows.add(ClassOverviewRow(
      scheduledClass: c,
      courseTitle: course?.title ?? 'Unknown course',
      teacherName: teacher?.name ?? 'Unknown teacher',
    ));
  }
  rows.sort((a, b) => a.scheduledClass.dateTime.compareTo(b.scheduledClass.dateTime));
  return rows;
});
