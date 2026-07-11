import '../core/constants/app_enums.dart';

/// ── EduNova extended domain models ──────────────────────────────────────
/// All the new records that power assessments, mini-projects, certificates,
/// attendance, notifications, announcements, recordings, audit logging and
/// gamification. Each is a plain data class with JSON (de)serialization so
/// it drops straight into the existing LocalStorageService pattern.
/// ------------------------------------------------------------------------

// ── A single coding test case (input → expected output) ────────────────
class TestCase {
  final String input;
  final String expectedOutput;
  const TestCase({required this.input, required this.expectedOutput});

  Map<String, dynamic> toJson() => {'input': input, 'expectedOutput': expectedOutput};
  factory TestCase.fromJson(Map<String, dynamic> j) =>
      TestCase(input: j['input'] as String, expectedOutput: j['expectedOutput'] as String);
}

/// A track-specific assessment. One model covers all four formats; the
/// fields that matter depend on [type].
class Assessment {
  final String id;
  final String courseId;
  final Subject subject;
  final Grade grade;
  final AssessmentType type;
  final String title;
  final String prompt;
  final int points;
  final DateTime? dueDate;

  // coding
  final String starterCode;
  final List<TestCase> testCases;

  // calculation
  final double? expectedAnswer;
  final double tolerance;
  final String unit;

  // mcq
  final List<String> options;
  final int correctOptionIndex;

  // writing
  final int minWords;
  final List<String> rubric;

  const Assessment({
    required this.id,
    required this.courseId,
    required this.subject,
    required this.grade,
    required this.type,
    required this.title,
    required this.prompt,
    this.points = 100,
    this.dueDate,
    this.starterCode = '',
    this.testCases = const [],
    this.expectedAnswer,
    this.tolerance = 0.01,
    this.unit = '',
    this.options = const [],
    this.correctOptionIndex = 0,
    this.minWords = 120,
    this.rubric = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'subject': subject.name,
        'grade': grade.name,
        'type': type.name,
        'title': title,
        'prompt': prompt,
        'points': points,
        'dueDate': dueDate?.toIso8601String(),
        'starterCode': starterCode,
        'testCases': testCases.map((t) => t.toJson()).toList(),
        'expectedAnswer': expectedAnswer,
        'tolerance': tolerance,
        'unit': unit,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'minWords': minWords,
        'rubric': rubric,
      };

  factory Assessment.fromJson(Map<String, dynamic> j) => Assessment(
        id: j['id'] as String,
        courseId: j['courseId'] as String,
        subject: Subject.values.byName(j['subject'] as String),
        grade: Grade.values.byName(j['grade'] as String),
        type: AssessmentType.values.byName(j['type'] as String),
        title: j['title'] as String,
        prompt: j['prompt'] as String,
        points: j['points'] as int? ?? 100,
        dueDate: j['dueDate'] == null ? null : DateTime.parse(j['dueDate'] as String),
        starterCode: j['starterCode'] as String? ?? '',
        testCases: (j['testCases'] as List<dynamic>? ?? [])
            .map((e) => TestCase.fromJson(e as Map<String, dynamic>))
            .toList(),
        expectedAnswer: (j['expectedAnswer'] as num?)?.toDouble(),
        tolerance: (j['tolerance'] as num?)?.toDouble() ?? 0.01,
        unit: j['unit'] as String? ?? '',
        options: (j['options'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
        correctOptionIndex: j['correctOptionIndex'] as int? ?? 0,
        minWords: j['minWords'] as int? ?? 120,
        rubric: (j['rubric'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      );
}

/// A student's attempt/answer to an [Assessment].
class AssessmentSubmission {
  final String id;
  final String assessmentId;
  final String courseId;
  final String studentId;
  final AssessmentType type;
  final String content; // code, essay text, or "" for auto types
  final double? numericAnswer;
  final int? selectedOption;
  final SubmissionStatus status;
  final int? autoScore; // 0-100 for auto-graded types
  final int? teacherScore; // 0-100 assigned by teacher
  final String aiFeedback;
  final String teacherFeedback;
  final DateTime submittedAt;

  const AssessmentSubmission({
    required this.id,
    required this.assessmentId,
    required this.courseId,
    required this.studentId,
    required this.type,
    required this.submittedAt,
    this.content = '',
    this.numericAnswer,
    this.selectedOption,
    this.status = SubmissionStatus.submitted,
    this.autoScore,
    this.teacherScore,
    this.aiFeedback = '',
    this.teacherFeedback = '',
  });

  int? get finalScore => teacherScore ?? autoScore;

  AssessmentSubmission copyWith({
    SubmissionStatus? status,
    int? teacherScore,
    String? teacherFeedback,
    String? aiFeedback,
  }) =>
      AssessmentSubmission(
        id: id,
        assessmentId: assessmentId,
        courseId: courseId,
        studentId: studentId,
        type: type,
        submittedAt: submittedAt,
        content: content,
        numericAnswer: numericAnswer,
        selectedOption: selectedOption,
        status: status ?? this.status,
        autoScore: autoScore,
        teacherScore: teacherScore ?? this.teacherScore,
        aiFeedback: aiFeedback ?? this.aiFeedback,
        teacherFeedback: teacherFeedback ?? this.teacherFeedback,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'assessmentId': assessmentId,
        'courseId': courseId,
        'studentId': studentId,
        'type': type.name,
        'content': content,
        'numericAnswer': numericAnswer,
        'selectedOption': selectedOption,
        'status': status.name,
        'autoScore': autoScore,
        'teacherScore': teacherScore,
        'aiFeedback': aiFeedback,
        'teacherFeedback': teacherFeedback,
        'submittedAt': submittedAt.toIso8601String(),
      };

  factory AssessmentSubmission.fromJson(Map<String, dynamic> j) => AssessmentSubmission(
        id: j['id'] as String,
        assessmentId: j['assessmentId'] as String,
        courseId: j['courseId'] as String,
        studentId: j['studentId'] as String,
        type: AssessmentType.values.byName(j['type'] as String),
        content: j['content'] as String? ?? '',
        numericAnswer: (j['numericAnswer'] as num?)?.toDouble(),
        selectedOption: j['selectedOption'] as int?,
        status: SubmissionStatus.values.byName(j['status'] as String? ?? 'submitted'),
        autoScore: j['autoScore'] as int?,
        teacherScore: j['teacherScore'] as int?,
        aiFeedback: j['aiFeedback'] as String? ?? '',
        teacherFeedback: j['teacherFeedback'] as String? ?? '',
        submittedAt: DateTime.parse(j['submittedAt'] as String),
      );
}

/// A hands-on mini-project brief attached to a course (e.g. "Build a Python
/// number-guessing game").
class MiniProject {
  final String id;
  final String courseId;
  final Subject subject;
  final Grade grade;
  final String title;
  final String brief;
  final List<String> deliverables;

  const MiniProject({
    required this.id,
    required this.courseId,
    required this.subject,
    required this.grade,
    required this.title,
    required this.brief,
    this.deliverables = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'subject': subject.name,
        'grade': grade.name,
        'title': title,
        'brief': brief,
        'deliverables': deliverables,
      };

  factory MiniProject.fromJson(Map<String, dynamic> j) => MiniProject(
        id: j['id'] as String,
        courseId: j['courseId'] as String,
        subject: Subject.values.byName(j['subject'] as String),
        grade: Grade.values.byName(j['grade'] as String),
        title: j['title'] as String,
        brief: j['brief'] as String,
        deliverables: (j['deliverables'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      );
}

/// A student's submitted project — the artifact a portfolio/resume is built
/// from once it's approved.
class ProjectSubmission {
  final String id;
  final String projectId;
  final String courseId;
  final String studentId;
  final String title;
  final String description;
  final String link; // repo / demo / doc link
  final SubmissionStatus status;
  final String aiPrecheck; // AI pre-check summary shown before teacher review
  final String teacherFeedback;
  final DateTime submittedAt;

  const ProjectSubmission({
    required this.id,
    required this.projectId,
    required this.courseId,
    required this.studentId,
    required this.title,
    required this.description,
    required this.submittedAt,
    this.link = '',
    this.status = SubmissionStatus.submitted,
    this.aiPrecheck = '',
    this.teacherFeedback = '',
  });

  ProjectSubmission copyWith({SubmissionStatus? status, String? teacherFeedback, String? aiPrecheck}) =>
      ProjectSubmission(
        id: id,
        projectId: projectId,
        courseId: courseId,
        studentId: studentId,
        title: title,
        description: description,
        submittedAt: submittedAt,
        link: link,
        status: status ?? this.status,
        aiPrecheck: aiPrecheck ?? this.aiPrecheck,
        teacherFeedback: teacherFeedback ?? this.teacherFeedback,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'courseId': courseId,
        'studentId': studentId,
        'title': title,
        'description': description,
        'link': link,
        'status': status.name,
        'aiPrecheck': aiPrecheck,
        'teacherFeedback': teacherFeedback,
        'submittedAt': submittedAt.toIso8601String(),
      };

  factory ProjectSubmission.fromJson(Map<String, dynamic> j) => ProjectSubmission(
        id: j['id'] as String,
        projectId: j['projectId'] as String,
        courseId: j['courseId'] as String,
        studentId: j['studentId'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        link: j['link'] as String? ?? '',
        status: SubmissionStatus.values.byName(j['status'] as String? ?? 'submitted'),
        aiPrecheck: j['aiPrecheck'] as String? ?? '',
        teacherFeedback: j['teacherFeedback'] as String? ?? '',
        submittedAt: DateTime.parse(j['submittedAt'] as String),
      );
}

/// A completion certificate awarded per course or per track.
class Certificate {
  final String id;
  final String studentId;
  final String studentName;
  final String courseId;
  final String title;
  final Subject subject;
  final Grade grade;
  final int scorePercent;
  final DateTime issuedAt;

  const Certificate({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.title,
    required this.subject,
    required this.grade,
    required this.scorePercent,
    required this.issuedAt,
  });

  String get credentialId => 'EDU-${id.hashCode.abs().toRadixString(36).toUpperCase().padLeft(6, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'studentName': studentName,
        'courseId': courseId,
        'title': title,
        'subject': subject.name,
        'grade': grade.name,
        'scorePercent': scorePercent,
        'issuedAt': issuedAt.toIso8601String(),
      };

  factory Certificate.fromJson(Map<String, dynamic> j) => Certificate(
        id: j['id'] as String,
        studentId: j['studentId'] as String,
        studentName: j['studentName'] as String,
        courseId: j['courseId'] as String,
        title: j['title'] as String,
        subject: Subject.values.byName(j['subject'] as String),
        grade: Grade.values.byName(j['grade'] as String),
        scorePercent: j['scorePercent'] as int,
        issuedAt: DateTime.parse(j['issuedAt'] as String),
      );
}

/// One attendance record for a student on a scheduled live class.
class AttendanceRecord {
  final String id;
  final String classId;
  final String courseId;
  final String studentId;
  final AttendanceStatus status;
  final DateTime markedAt;

  const AttendanceRecord({
    required this.id,
    required this.classId,
    required this.courseId,
    required this.studentId,
    required this.status,
    required this.markedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'classId': classId,
        'courseId': courseId,
        'studentId': studentId,
        'status': status.name,
        'markedAt': markedAt.toIso8601String(),
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> j) => AttendanceRecord(
        id: j['id'] as String,
        classId: j['classId'] as String,
        courseId: j['courseId'] as String,
        studentId: j['studentId'] as String,
        status: AttendanceStatus.values.byName(j['status'] as String),
        markedAt: DateTime.parse(j['markedAt'] as String),
      );
}

/// An in-app notification for a specific user.
class NotificationItem {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  NotificationItem copyWith({bool? read}) => NotificationItem(
        id: id,
        userId: userId,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        read: read ?? this.read,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type.name,
        'title': title,
        'body': body,
        'read': read,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
        id: j['id'] as String,
        userId: j['userId'] as String,
        type: NotificationType.values.byName(j['type'] as String),
        title: j['title'] as String,
        body: j['body'] as String,
        read: j['read'] as bool? ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

/// A broadcast from a teacher to everyone enrolled in one of their courses.
class Announcement {
  final String id;
  final String courseId;
  final String teacherId;
  final String title;
  final String body;
  final DateTime createdAt;

  const Announcement({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'teacherId': teacherId,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Announcement.fromJson(Map<String, dynamic> j) => Announcement(
        id: j['id'] as String,
        courseId: j['courseId'] as String,
        teacherId: j['teacherId'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

/// A live-class recording. Regular recordings auto-expire 48h after the
/// class; sample videos are permanent, public preview clips.
class Recording {
  final String id;
  final String classId;
  final String courseId;
  final String title;
  final bool isSample; // permanent public preview vs 48h auto-delete
  final String shareUrl;
  final DateTime createdAt;

  const Recording({
    required this.id,
    required this.classId,
    required this.courseId,
    required this.title,
    required this.createdAt,
    this.isSample = false,
    this.shareUrl = '',
  });

  /// Regular recordings live for 48 hours; sample videos never expire.
  DateTime get expiresAt => createdAt.add(const Duration(hours: 48));
  bool get isExpired => !isSample && DateTime.now().isAfter(expiresAt);
  Duration get timeLeft => expiresAt.difference(DateTime.now());

  Recording copyWith({bool? isSample, String? shareUrl}) => Recording(
        id: id,
        classId: classId,
        courseId: courseId,
        title: title,
        createdAt: createdAt,
        isSample: isSample ?? this.isSample,
        shareUrl: shareUrl ?? this.shareUrl,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'classId': classId,
        'courseId': courseId,
        'title': title,
        'isSample': isSample,
        'shareUrl': shareUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Recording.fromJson(Map<String, dynamic> j) => Recording(
        id: j['id'] as String,
        classId: j['classId'] as String,
        courseId: j['courseId'] as String,
        title: j['title'] as String,
        isSample: j['isSample'] as bool? ?? false,
        shareUrl: j['shareUrl'] as String? ?? '',
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

/// A single row on a grade leaderboard. Built on the fly from submissions,
/// game scores and attendance — not persisted.
class LeaderboardEntry {
  final String studentId;
  final String studentName;
  final int points;
  final int badges;
  final int rank;

  const LeaderboardEntry({
    required this.studentId,
    required this.studentName,
    required this.points,
    required this.badges,
    required this.rank,
  });
}

/// An immutable audit-log entry recording an admin/teacher action.
class AuditEntry {
  final String id;
  final String actorId;
  final String actorName;
  final String action;
  final String target;
  final DateTime createdAt;

  const AuditEntry({
    required this.id,
    required this.actorId,
    required this.actorName,
    required this.action,
    required this.target,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'actorId': actorId,
        'actorName': actorName,
        'action': action,
        'target': target,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AuditEntry.fromJson(Map<String, dynamic> j) => AuditEntry(
        id: j['id'] as String,
        actorId: j['actorId'] as String,
        actorName: j['actorName'] as String,
        action: j['action'] as String,
        target: j['target'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}
