import '../../models/platform_models.dart';
import '../interfaces/platform_repository.dart';
import 'local_storage_service.dart';

/// SharedPreferences-backed implementation of [PlatformRepository]. Mirrors
/// the JSON-list pattern used by the other Local* repositories, so swapping
/// to a real backend later is a single-file change.
class LocalPlatformRepository implements PlatformRepository {
  final _storage = LocalStorageService.instance;

  Future<List<T>> _read<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    final list = await _storage.readList(key);
    return list.map(fromJson).toList();
  }

  Future<void> _write<T>(String key, List<T> items, Map<String, dynamic> Function(T) toJson) async {
    await _storage.writeList(key, items.map(toJson).toList());
  }

  Future<void> _upsert<T>(
    String key,
    T item,
    String Function(T) idOf,
    T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final all = await _read(key, fromJson);
    final idx = all.indexWhere((e) => idOf(e) == idOf(item));
    if (idx >= 0) {
      all[idx] = item;
    } else {
      all.add(item);
    }
    await _write(key, all, toJson);
  }

  // ── Assessments ──────────────────────────────────────────────────────
  @override
  Future<List<Assessment>> getAssessmentsByCourse(String courseId) async {
    final all = await _read(StorageKeys.assessments, Assessment.fromJson);
    return all.where((a) => a.courseId == courseId).toList();
  }

  @override
  Future<Assessment?> getAssessmentById(String id) async {
    final all = await _read(StorageKeys.assessments, Assessment.fromJson);
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertAssessment(Assessment a) =>
      _upsert(StorageKeys.assessments, a, (e) => e.id, Assessment.fromJson, (e) => e.toJson());

  @override
  Future<List<AssessmentSubmission>> getSubmissionsForStudent(String studentId) async {
    final all = await _read(StorageKeys.assessmentSubmissions, AssessmentSubmission.fromJson);
    return all.where((s) => s.studentId == studentId).toList();
  }

  @override
  Future<List<AssessmentSubmission>> getSubmissionsForAssessment(String assessmentId) async {
    final all = await _read(StorageKeys.assessmentSubmissions, AssessmentSubmission.fromJson);
    return all.where((s) => s.assessmentId == assessmentId).toList();
  }

  @override
  Future<List<AssessmentSubmission>> getAllAssessmentSubmissions() =>
      _read(StorageKeys.assessmentSubmissions, AssessmentSubmission.fromJson);

  @override
  Future<AssessmentSubmission?> getSubmission(String assessmentId, String studentId) async {
    final all = await _read(StorageKeys.assessmentSubmissions, AssessmentSubmission.fromJson);
    try {
      return all.firstWhere((s) => s.assessmentId == assessmentId && s.studentId == studentId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertAssessmentSubmission(AssessmentSubmission s) => _upsert(
      StorageKeys.assessmentSubmissions, s, (e) => e.id, AssessmentSubmission.fromJson, (e) => e.toJson());

  // ── Mini-projects ────────────────────────────────────────────────────
  @override
  Future<List<MiniProject>> getProjectsByCourse(String courseId) async {
    final all = await _read(StorageKeys.miniProjects, MiniProject.fromJson);
    return all.where((p) => p.courseId == courseId).toList();
  }

  @override
  Future<MiniProject?> getProjectById(String id) async {
    final all = await _read(StorageKeys.miniProjects, MiniProject.fromJson);
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertProject(MiniProject p) =>
      _upsert(StorageKeys.miniProjects, p, (e) => e.id, MiniProject.fromJson, (e) => e.toJson());

  @override
  Future<List<ProjectSubmission>> getProjectSubmissionsForStudent(String studentId) async {
    final all = await _read(StorageKeys.projectSubmissions, ProjectSubmission.fromJson);
    return all.where((s) => s.studentId == studentId).toList();
  }

  @override
  Future<List<ProjectSubmission>> getAllProjectSubmissions() =>
      _read(StorageKeys.projectSubmissions, ProjectSubmission.fromJson);

  @override
  Future<void> upsertProjectSubmission(ProjectSubmission s) => _upsert(
      StorageKeys.projectSubmissions, s, (e) => e.id, ProjectSubmission.fromJson, (e) => e.toJson());

  // ── Certificates ─────────────────────────────────────────────────────
  @override
  Future<List<Certificate>> getCertificatesForStudent(String studentId) async {
    final all = await _read(StorageKeys.certificates, Certificate.fromJson);
    return all.where((c) => c.studentId == studentId).toList();
  }

  @override
  Future<void> upsertCertificate(Certificate c) =>
      _upsert(StorageKeys.certificates, c, (e) => e.id, Certificate.fromJson, (e) => e.toJson());

  // ── Attendance ───────────────────────────────────────────────────────
  @override
  Future<List<AttendanceRecord>> getAttendanceForStudent(String studentId) async {
    final all = await _read(StorageKeys.attendance, AttendanceRecord.fromJson);
    return all.where((r) => r.studentId == studentId).toList();
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceForClass(String classId) async {
    final all = await _read(StorageKeys.attendance, AttendanceRecord.fromJson);
    return all.where((r) => r.classId == classId).toList();
  }

  @override
  Future<void> upsertAttendance(AttendanceRecord r) =>
      _upsert(StorageKeys.attendance, r, (e) => e.id, AttendanceRecord.fromJson, (e) => e.toJson());

  // ── Notifications ────────────────────────────────────────────────────
  @override
  Future<List<NotificationItem>> getNotifications(String userId) async {
    final all = await _read(StorageKeys.notifications, NotificationItem.fromJson);
    final mine = all.where((n) => n.userId == userId).toList();
    mine.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return mine;
  }

  @override
  Future<void> addNotification(NotificationItem n) =>
      _upsert(StorageKeys.notifications, n, (e) => e.id, NotificationItem.fromJson, (e) => e.toJson());

  @override
  Future<void> markNotificationRead(String id) async {
    final all = await _read(StorageKeys.notifications, NotificationItem.fromJson);
    final idx = all.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      all[idx] = all[idx].copyWith(read: true);
      await _write(StorageKeys.notifications, all, (e) => e.toJson());
    }
  }

  @override
  Future<void> markAllNotificationsRead(String userId) async {
    final all = await _read(StorageKeys.notifications, NotificationItem.fromJson);
    for (var i = 0; i < all.length; i++) {
      if (all[i].userId == userId && !all[i].read) all[i] = all[i].copyWith(read: true);
    }
    await _write(StorageKeys.notifications, all, (e) => e.toJson());
  }

  // ── Announcements ────────────────────────────────────────────────────
  @override
  Future<List<Announcement>> getAnnouncementsByCourse(String courseId) async {
    final all = await _read(StorageKeys.announcements, Announcement.fromJson);
    final list = all.where((a) => a.courseId == courseId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<Announcement>> getAnnouncementsByTeacher(String teacherId) async {
    final all = await _read(StorageKeys.announcements, Announcement.fromJson);
    final list = all.where((a) => a.teacherId == teacherId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> addAnnouncement(Announcement a) =>
      _upsert(StorageKeys.announcements, a, (e) => e.id, Announcement.fromJson, (e) => e.toJson());

  // ── Recordings ───────────────────────────────────────────────────────
  @override
  Future<List<Recording>> getAllRecordings() => _read(StorageKeys.recordings, Recording.fromJson);

  @override
  Future<List<Recording>> getRecordingsByCourse(String courseId) async {
    final all = await _read(StorageKeys.recordings, Recording.fromJson);
    return all.where((r) => r.courseId == courseId).toList();
  }

  @override
  Future<void> upsertRecording(Recording r) =>
      _upsert(StorageKeys.recordings, r, (e) => e.id, Recording.fromJson, (e) => e.toJson());

  @override
  Future<void> deleteRecording(String id) async {
    final all = await _read(StorageKeys.recordings, Recording.fromJson);
    all.removeWhere((r) => r.id == id);
    await _write(StorageKeys.recordings, all, (e) => e.toJson());
  }

  // ── Audit log ────────────────────────────────────────────────────────
  @override
  Future<List<AuditEntry>> getAuditLog() async {
    final all = await _read(StorageKeys.auditLog, AuditEntry.fromJson);
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  @override
  Future<void> addAuditEntry(AuditEntry e) =>
      _upsert(StorageKeys.auditLog, e, (x) => x.id, AuditEntry.fromJson, (x) => x.toJson());

  // ── Availability ─────────────────────────────────────────────────────
  @override
  Future<List<String>> getAvailability(String teacherId) async {
    final obj = await _storage.readObject(StorageKeys.teacherAvailability);
    if (obj == null) return [];
    final slots = obj[teacherId] as List<dynamic>?;
    return slots?.map((e) => e as String).toList() ?? [];
  }

  @override
  Future<void> setAvailability(String teacherId, List<String> slots) async {
    final obj = await _storage.readObject(StorageKeys.teacherAvailability) ?? {};
    obj[teacherId] = slots;
    await _storage.writeObject(StorageKeys.teacherAvailability, obj);
  }

  // ── Parent links ─────────────────────────────────────────────────────
  @override
  Future<Map<String, String>> getParentLinks() async {
    final obj = await _storage.readObject(StorageKeys.parentLinks);
    if (obj == null) return {};
    return obj.map((k, v) => MapEntry(k, v as String));
  }

  @override
  Future<void> linkParent(String studentId, String parentName) async {
    final obj = await _storage.readObject(StorageKeys.parentLinks) ?? {};
    obj[studentId] = parentName;
    await _storage.writeObject(StorageKeys.parentLinks, obj);
  }

  // ── Game scores ──────────────────────────────────────────────────────
  @override
  Future<Map<String, int>> getGameScores() async {
    final obj = await _storage.readObject(StorageKeys.gameScores);
    if (obj == null) return {};
    return obj.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  @override
  Future<void> recordGameScore(String gameKey, int score) async {
    final obj = await _storage.readObject(StorageKeys.gameScores) ?? {};
    final prev = (obj[gameKey] as num?)?.toInt() ?? 0;
    if (score > prev) obj[gameKey] = score;
    await _storage.writeObject(StorageKeys.gameScores, obj);
  }
}
