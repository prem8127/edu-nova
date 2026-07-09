import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin generic wrapper so every repository doesn't reimplement
/// JSON-encode/decode + SharedPreferences boilerplate. When we swap to a
/// real backend, only the *_repository.dart files change — this class and
/// the repository interfaces stay untouched.
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _sp async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<Map<String, dynamic>>> readList(String key) async {
    final sp = await _sp;
    final raw = sp.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) async {
    final sp = await _sp;
    await sp.setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> readObject(String key) async {
    final sp = await _sp;
    final raw = sp.getString(key);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> writeObject(String key, Map<String, dynamic> value) async {
    final sp = await _sp;
    await sp.setString(key, jsonEncode(value));
  }

  Future<void> remove(String key) async {
    final sp = await _sp;
    await sp.remove(key);
  }

  Future<void> clearAll() async {
    final sp = await _sp;
    await sp.clear();
  }
}

/// Keys centralized here so nothing typos a string key across files.
class StorageKeys {
  static const currentUser = 'aditya_globals_current_user';
  static const users = 'aditya_globals_users';
  static const courses = 'aditya_globals_courses';
  static const quizzes = 'aditya_globals_quizzes';
  static const quizAttempts = 'aditya_globals_quiz_attempts';
  static const scheduledClasses = 'aditya_globals_scheduled_classes';
  static const doubtThreads = 'aditya_globals_doubt_threads';
  static const doubtMessages = 'aditya_globals_doubt_messages';
  static const purchasedCourseIds = 'aditya_globals_purchased_course_ids';
  static const onboardingComplete = 'aditya_globals_onboarding_complete';
  static const transactions = 'aditya_globals_transactions';

  // Extended platform features
  static const assessments = 'aditya_globals_assessments';
  static const assessmentSubmissions = 'aditya_globals_assessment_submissions';
  static const miniProjects = 'aditya_globals_mini_projects';
  static const projectSubmissions = 'aditya_globals_project_submissions';
  static const certificates = 'aditya_globals_certificates';
  static const attendance = 'aditya_globals_attendance';
  static const notifications = 'aditya_globals_notifications';
  static const announcements = 'aditya_globals_announcements';
  static const recordings = 'aditya_globals_recordings';
  static const auditLog = 'aditya_globals_audit_log';
  static const teacherAvailability = 'aditya_globals_teacher_availability';
  static const gameScores = 'aditya_globals_game_scores';
}
