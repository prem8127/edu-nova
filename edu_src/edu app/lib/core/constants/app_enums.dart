import 'package:flutter/material.dart';

/// Central enums used across EduNova. Keeping these in one file makes it
/// trivial to extend (e.g. add a new subject or grade) without hunting
/// through the codebase.

enum UserRole { student, teacher, admin }

/// Class 6-10 + Intermediate (11-12). Kept as an enum (not a free string)
/// so every screen that branches on grade is compile-time safe.
enum Grade {
  class6,
  class7,
  class8,
  class9,
  class10,
  intermediate1,
  intermediate2,
}

extension GradeLabel on Grade {
  String get label {
    switch (this) {
      case Grade.class6:
        return 'Class 6';
      case Grade.class7:
        return 'Class 7';
      case Grade.class8:
        return 'Class 8';
      case Grade.class9:
        return 'Class 9';
      case Grade.class10:
        return 'Class 10';
      case Grade.intermediate1:
        return 'Intermediate 1st Year';
      case Grade.intermediate2:
        return 'Intermediate 2nd Year';
    }
  }
}

/// The four subject verticals decided for EduNova, applied uniformly
/// across all grades (replaces the old per-grade subject model).
enum Subject { tech, business, finance, contentCreation }

extension SubjectLabel on Subject {
  String get label {
    switch (this) {
      case Subject.tech:
        return 'Tech';
      case Subject.business:
        return 'Business';
      case Subject.finance:
        return 'Finance';
      case Subject.contentCreation:
        return 'Content Creation';
    }
  }
}

enum CourseAccess { free, locked, purchased }

/// Track-specific assessment formats:
///  - tech      → LeetCode-style coding challenge
///  - business  → multiple-choice quiz
///  - finance   → numeric calculation problem (LeetCode-style but numbers)
///  - content   → written/story submission reviewed by a teacher
enum AssessmentType { coding, mcq, calculation, writing }

extension AssessmentTypeInfo on AssessmentType {
  String get label {
    switch (this) {
      case AssessmentType.coding:
        return 'Coding Challenge';
      case AssessmentType.mcq:
        return 'MCQ Quiz';
      case AssessmentType.calculation:
        return 'Calculation Problem';
      case AssessmentType.writing:
        return 'Writing Task';
    }
  }

  IconData get icon {
    switch (this) {
      case AssessmentType.coding:
        return Icons.code_rounded;
      case AssessmentType.mcq:
        return Icons.check_circle_outline_rounded;
      case AssessmentType.calculation:
        return Icons.calculate_rounded;
      case AssessmentType.writing:
        return Icons.edit_note_rounded;
    }
  }

  /// Whether this format is auto-graded (coding/mcq/calculation) or needs a
  /// human teacher to review it (writing).
  bool get autoGraded => this != AssessmentType.writing;
}

/// The natural default assessment format for each subject vertical.
extension SubjectAssessment on Subject {
  AssessmentType get assessmentType {
    switch (this) {
      case Subject.tech:
        return AssessmentType.coding;
      case Subject.business:
        return AssessmentType.mcq;
      case Subject.finance:
        return AssessmentType.calculation;
      case Subject.contentCreation:
        return AssessmentType.writing;
    }
  }
}

/// Lifecycle of a student submission (mini-project or writing task) as it
/// moves through the optional AI pre-check and then teacher review.
enum SubmissionStatus { draft, submitted, aiFlagged, underReview, approved, needsWork }

extension SubmissionStatusInfo on SubmissionStatus {
  String get label {
    switch (this) {
      case SubmissionStatus.draft:
        return 'Draft';
      case SubmissionStatus.submitted:
        return 'Submitted';
      case SubmissionStatus.aiFlagged:
        return 'AI Flagged';
      case SubmissionStatus.underReview:
        return 'Under Review';
      case SubmissionStatus.approved:
        return 'Approved';
      case SubmissionStatus.needsWork:
        return 'Needs Work';
    }
  }

  Color get color {
    switch (this) {
      case SubmissionStatus.draft:
        return const Color(0xFF94A3B8);
      case SubmissionStatus.submitted:
        return const Color(0xFF3E7BFA);
      case SubmissionStatus.aiFlagged:
        return const Color(0xFFF59E0B);
      case SubmissionStatus.underReview:
        return const Color(0xFF7C5CFF);
      case SubmissionStatus.approved:
        return const Color(0xFF22C55E);
      case SubmissionStatus.needsWork:
        return const Color(0xFFEF4444);
    }
  }
}

/// Types of in-app notifications shown in the notification centre and used
/// for scheduled-class reminders, exam deadlines and doubt replies.
enum NotificationType { classReminder, examDeadline, doubtReply, announcement, certificate, submissionResult }

extension NotificationTypeInfo on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.classReminder:
        return Icons.videocam_rounded;
      case NotificationType.examDeadline:
        return Icons.timer_outlined;
      case NotificationType.doubtReply:
        return Icons.forum_rounded;
      case NotificationType.announcement:
        return Icons.campaign_rounded;
      case NotificationType.certificate:
        return Icons.workspace_premium_rounded;
      case NotificationType.submissionResult:
        return Icons.assignment_turned_in_rounded;
    }
  }
}

/// Attendance state for a student on a given scheduled live class.
enum AttendanceStatus { present, absent, late }

extension AttendanceStatusInfo on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.present:
        return const Color(0xFF22C55E);
      case AttendanceStatus.absent:
        return const Color(0xFFEF4444);
      case AttendanceStatus.late:
        return const Color(0xFFF59E0B);
    }
  }
}

/// Visual identity per subject, used for course thumbnails/badges across
/// the redesigned course list, dashboard and detail screens.
extension SubjectVisual on Subject {
  IconData get icon {
    switch (this) {
      case Subject.tech:
        return Icons.terminal_rounded;
      case Subject.business:
        return Icons.trending_up_rounded;
      case Subject.finance:
        return Icons.account_balance_wallet_rounded;
      case Subject.contentCreation:
        return Icons.videocam_rounded;
    }
  }

  Color get color {
    switch (this) {
      case Subject.tech:
        return const Color(0xFF5624D0);
      case Subject.business:
        return const Color(0xFF1E88E5);
      case Subject.finance:
        return const Color(0xFF08BD80);
      case Subject.contentCreation:
        return const Color(0xFFE8631C);
    }
  }
}
