import '../../models/platform_models.dart';

/// One repository for all the extended platform features. Kept as a single
/// interface (rather than a dozen tiny ones) because they share the same
/// simple CRUD shape and are always swapped for a real backend together.
abstract class PlatformRepository {
  // Assessments
  Future<List<Assessment>> getAssessmentsByCourse(String courseId);
  Future<Assessment?> getAssessmentById(String id);
  Future<void> upsertAssessment(Assessment a);
  Future<List<AssessmentSubmission>> getSubmissionsForStudent(String studentId);
  Future<List<AssessmentSubmission>> getSubmissionsForAssessment(String assessmentId);
  Future<List<AssessmentSubmission>> getAllAssessmentSubmissions();
  Future<AssessmentSubmission?> getSubmission(String assessmentId, String studentId);
  Future<void> upsertAssessmentSubmission(AssessmentSubmission s);

  // Mini-projects
  Future<List<MiniProject>> getProjectsByCourse(String courseId);
  Future<MiniProject?> getProjectById(String id);
  Future<void> upsertProject(MiniProject p);
  Future<List<ProjectSubmission>> getProjectSubmissionsForStudent(String studentId);
  Future<List<ProjectSubmission>> getAllProjectSubmissions();
  Future<void> upsertProjectSubmission(ProjectSubmission s);

  // Certificates
  Future<List<Certificate>> getCertificatesForStudent(String studentId);
  Future<void> upsertCertificate(Certificate c);

  // Attendance
  Future<List<AttendanceRecord>> getAttendanceForStudent(String studentId);
  Future<List<AttendanceRecord>> getAttendanceForClass(String classId);
  Future<void> upsertAttendance(AttendanceRecord r);

  // Notifications
  Future<List<NotificationItem>> getNotifications(String userId);
  Future<void> addNotification(NotificationItem n);
  Future<void> markNotificationRead(String id);
  Future<void> markAllNotificationsRead(String userId);

  // Announcements
  Future<List<Announcement>> getAnnouncementsByCourse(String courseId);
  Future<List<Announcement>> getAnnouncementsByTeacher(String teacherId);
  Future<void> addAnnouncement(Announcement a);

  // Recordings
  Future<List<Recording>> getAllRecordings();
  Future<List<Recording>> getRecordingsByCourse(String courseId);
  Future<void> upsertRecording(Recording r);
  Future<void> deleteRecording(String id);

  // Audit log
  Future<List<AuditEntry>> getAuditLog();
  Future<void> addAuditEntry(AuditEntry e);

  // Teacher availability (list of "weekdayIndex|HH:mm-HH:mm" strings)
  Future<List<String>> getAvailability(String teacherId);
  Future<void> setAvailability(String teacherId, List<String> slots);

  // Parent links (studentId -> parent name)
  Future<Map<String, String>> getParentLinks();
  Future<void> linkParent(String studentId, String parentName);

  // Gamification: best score per game key
  Future<Map<String, int>> getGameScores();
  Future<void> recordGameScore(String gameKey, int score);
}
