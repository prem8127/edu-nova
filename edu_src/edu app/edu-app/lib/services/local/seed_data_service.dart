import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../core/constants/app_enums.dart';
import '../../models/class_schedule_model.dart';
import '../../models/course_model.dart';
import '../../models/doubt_chat_model.dart';
import '../../models/platform_models.dart';
import '../../models/quiz_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../interfaces/course_repository.dart';
import '../interfaces/doubt_chat_repository.dart';
import '../interfaces/platform_repository.dart';
import '../interfaces/quiz_repository.dart';
import '../interfaces/schedule_repository.dart';
import '../interfaces/transaction_repository.dart';
import '../interfaces/user_repository.dart';

/// Fixed (non-random) ids for every seeded teacher so the "I'm a Teacher"
/// demo-login button can sign in as an account that actually owns seeded
/// courses/classes, instead of a throwaway id nothing else references.
class SeedIds {
  SeedIds._();
  static const teacherTech = 'seed_teacher_tech';
  static const teacherBusiness = 'seed_teacher_business';
  static const teacherFinance = 'seed_teacher_finance';
  static const teacherContent = 'seed_teacher_content';
  static const admin = 'seed_admin';

  static String teacherFor(Subject s) {
    switch (s) {
      case Subject.tech:
        return teacherTech;
      case Subject.business:
        return teacherBusiness;
      case Subject.finance:
        return teacherFinance;
      case Subject.contentCreation:
        return teacherContent;
    }
  }
}

/// Populates realistic demo content so the app never opens to an empty
/// screen. Two entry points:
///  - [seedPlatformContent] — courses/teachers/quizzes/classes, run once
///    at app startup (idempotent: skips if courses already exist).
///  - [seedProgressForStudent] — purchases a few courses, records varied
///    quiz attempts (so the lagging-subject tracker has real data) and
///    starts a doubt thread, for a freshly onboarded student.
class SeedDataService {
  SeedDataService._();

  static const _teacherNames = {
    Subject.tech: 'Rahul Menon',
    Subject.business: 'Ayesha Khan',
    Subject.finance: 'Vikram Rao',
    Subject.contentCreation: 'Sneha Iyer',
  };

  static const _courseBlurb = {
    Subject.tech: 'Hands-on coding, computational thinking and real projects.',
    Subject.business:
        'Practical business fundamentals — from ideas to running one.',
    Subject.finance: 'Money skills: budgeting, saving, and how markets work.',
    Subject.contentCreation:
        'Storytelling, video editing and building an audience online.',
  };

  static const Map<Subject, List<Map<String, Object>>> _questionBank = {
    Subject.tech: [
      {
        'q': 'Which symbol starts a comment in most C-family languages?',
        'options': ['//', '##', '<!--', '::'],
        'a': 0,
      },
      {
        'q': 'What does "HTML" stand for?',
        'options': [
          'HyperText Markup Language',
          'HighText Machine Language',
          'HyperTransfer Markup List',
          'Home Tool Markup Language',
        ],
        'a': 0,
      },
      {
        'q': 'Which data structure uses FIFO (first in, first out)?',
        'options': ['Stack', 'Queue', 'Tree', 'Graph'],
        'a': 1,
      },
      {
        'q': 'What is the output of 7 % 2 in most programming languages?',
        'options': ['3.5', '0', '1', '14'],
        'a': 2,
      },
    ],
    Subject.business: [
      {
        'q': 'What does "ROI" measure?',
        'options': [
          'Return on Investment',
          'Rate of Interest',
          'Revenue over Income',
          'Risk of Insolvency',
        ],
        'a': 0,
      },
      {
        'q': 'A business plan primarily helps you...',
        'options': [
          'Avoid paying taxes',
          'Clarify goals and strategy before you start',
          'Guarantee profit',
          'Skip market research',
        ],
        'a': 1,
      },
      {
        'q': 'Which of these is a fixed cost?',
        'options': ['Raw materials', 'Shop rent', 'Packaging', 'Delivery fuel'],
        'a': 1,
      },
      {
        'q': '"Break-even point" is when...',
        'options': [
          'Profit equals revenue',
          'Total revenue equals total cost',
          'A business shuts down',
          'Costs are zero',
        ],
        'a': 1,
      },
    ],
    Subject.finance: [
      {
        'q': 'Compound interest is calculated on...',
        'options': [
          'Principal only',
          'Principal plus accumulated interest',
          'Only the last year\'s interest',
          'Tax amount',
        ],
        'a': 1,
      },
      {
        'q': 'A budget is best described as...',
        'options': [
          'A record of past spending only',
          'A plan for income and expenses',
          'A type of loan',
          'A bank account',
        ],
        'a': 1,
      },
      {
        'q': 'Which is generally the safest investment?',
        'options': [
          'Government savings bond',
          'Cryptocurrency',
          'Penny stocks',
          'Lottery tickets',
        ],
        'a': 0,
      },
      {
        'q': 'An "emergency fund" should ideally cover...',
        'options': [
          'One day of expenses',
          '3-6 months of expenses',
          'A new phone',
          'Nothing, it\'s optional',
        ],
        'a': 1,
      },
    ],
    Subject.contentCreation: [
      {
        'q': 'A "hook" in a video refers to...',
        'options': [
          'The closing credits',
          'The opening moment that grabs attention',
          'A camera accessory',
          'The video file format',
        ],
        'a': 1,
      },
      {
        'q': 'Which aspect ratio is standard for most short-form video?',
        'options': ['9:16', '4:3', '21:9', '3:2'],
        'a': 0,
      },
      {
        'q': 'What does "engagement rate" usually measure?',
        'options': [
          'Video file size',
          'Interactions relative to reach/followers',
          'Upload speed',
          'Number of hashtags used',
        ],
        'a': 1,
      },
      {
        'q': 'A content calendar is used to...',
        'options': [
          'Edit videos faster',
          'Plan and schedule what to post and when',
          'Track device storage',
          'Replace a script',
        ],
        'a': 1,
      },
    ],
  };

  static const Map<Subject, List<String>> _courseTopics = {
    Subject.tech: ['Programming Basics', 'Web Development', 'Intro to AI'],
    Subject.business: ['Entrepreneurship 101', 'Marketing Essentials', 'Startup Strategy'],
    Subject.finance: ['Personal Finance', 'Investing Basics', 'Financial Literacy'],
    Subject.contentCreation: ['Video Editing', 'Social Media Growth', 'Scriptwriting'],
  };

  static String _courseId(Grade g, Subject s, int i) => 'seed_course_${g.name}_${s.name}_$i';
  static String _quizId(String courseId) => '${courseId}_quiz';

  /// A ready-made assessment for each subject, in the subject's natural
  /// format (coding / mcq / calculation / writing).
  static Assessment _assessmentFor(String courseId, Subject subject, Grade grade) {
    final id = '${courseId}_assess';
    switch (subject) {
      case Subject.tech:
        return Assessment(
          id: id,
          courseId: courseId,
          subject: subject,
          grade: grade,
          type: AssessmentType.coding,
          title: 'Sum of Two Numbers',
          prompt:
              'Read two integers and print their sum. Your program should read '
              'the input, add the numbers, and output a single integer.',
          points: 100,
          starterCode: '# Read two numbers and print their sum\n'
              'a, b = map(int, input().split())\n'
              '# your code here\n',
          testCases: const [
            TestCase(input: '2 3', expectedOutput: '5'),
            TestCase(input: '10 15', expectedOutput: '25'),
            TestCase(input: '-4 9', expectedOutput: '5'),
          ],
        );
      case Subject.business:
        return Assessment(
          id: id,
          courseId: courseId,
          subject: subject,
          grade: grade,
          type: AssessmentType.mcq,
          title: 'Marketing Fundamentals',
          prompt: 'Which metric best measures how efficiently ad spend turns '
              'into revenue?',
          points: 100,
          options: const ['ROAS', 'CPM', 'Impressions', 'Follower count'],
          correctOptionIndex: 0,
        );
      case Subject.finance:
        return Assessment(
          id: id,
          courseId: courseId,
          subject: subject,
          grade: grade,
          type: AssessmentType.calculation,
          title: 'Simple Interest',
          prompt: 'Calculate the simple interest on a principal of 5000 at 8% '
              'per year for 3 years. (Formula: P × R × T / 100)',
          points: 100,
          expectedAnswer: 1200,
          tolerance: 0.5,
          unit: 'rupees',
        );
      case Subject.contentCreation:
        return Assessment(
          id: id,
          courseId: courseId,
          subject: subject,
          grade: grade,
          type: AssessmentType.writing,
          title: 'Write a Video Hook',
          prompt: 'Write an opening 3-second hook and a short script outline '
              'for a 60-second video teaching a skill you know well.',
          points: 100,
          minWords: 120,
          rubric: const [
            'Strong attention-grabbing hook',
            'Clear structure (intro, body, call to action)',
            'Audience-appropriate tone',
          ],
        );
    }
  }

  static const Map<Subject, Map<String, Object>> _projectBank = {
    Subject.tech: {
      'title': 'Build a Number Guessing Game',
      'brief':
          'Create a small program where the computer picks a random number '
              'and the player guesses it, with "higher/lower" hints.',
      'deliverables': ['Working code', 'Short demo video or screenshots'],
    },
    Subject.business: {
      'title': 'One-Page Business Plan',
      'brief':
          'Pick a small business idea and write a one-page plan covering the '
              'problem, customer, offer, pricing and how you would get first sales.',
      'deliverables': ['One-page plan (doc/PDF)', '3 bullet go-to-market steps'],
    },
    Subject.finance: {
      'title': 'Personal Monthly Budget',
      'brief':
          'Build a monthly budget for a student with a fixed allowance. Track '
              'income, needs, wants and savings, and explain your choices.',
      'deliverables': ['Budget sheet', 'Short reflection on trade-offs'],
    },
    Subject.contentCreation: {
      'title': 'Produce a 60-Second Video',
      'brief':
          'Script, record and edit a 60-second short-form video on a topic you '
              'enjoy. Focus on a strong hook and clear pacing.',
      'deliverables': ['Final video link', 'The script you used'],
    },
  };

  /// Idempotent: only runs if there are no courses yet, so re-launching
  /// the app (or a real backend swap later) never duplicates data.
  static Future<void> seedPlatformContent({
    required UserRepository userRepo,
    required CourseRepository courseRepo,
    required QuizRepository quizRepo,
    required ScheduleRepository scheduleRepo,
    required PlatformRepository platformRepo,
  }) async {
    final existing = await courseRepo.getAllCourses();
    if (existing.isNotEmpty) return;

    // 1. Teachers, one per subject, with fixed ids so demo-login can
    // sign straight into an account that owns real assigned content.
    for (final subject in Subject.values) {
      await userRepo.upsertUser(AppUser(
        id: SeedIds.teacherFor(subject),
        name: _teacherNames[subject]!,
        role: UserRole.teacher,
        assignedSubjects: [subject],
      ));
    }
    await userRepo.upsertUser(const AppUser(
      id: SeedIds.admin,
      name: 'Priya Sharma',
      role: UserRole.admin,
    ));

    final now = DateTime.now();

    // 2. Courses + one quiz each, across every grade and subject.
    for (final grade in Grade.values) {
      for (final subject in Subject.values) {
        final topics = _courseTopics[subject]!;
        final topicIndex = grade.index % topics.length;
        final title = '${topics[topicIndex]} — ${grade.label}';
        final courseId = _courseId(grade, subject, topicIndex);
        // Every 3rd course is a free intro course; the rest require
        // purchase, matching the "paid by default" rule.
        final isFree = grade.index % 3 == 0;

        final quizId = _quizId(courseId);
        final course = CourseModel(
          id: courseId,
          title: title,
          description: _courseBlurb[subject]!,
          subject: subject,
          grade: grade,
          teacherId: SeedIds.teacherFor(subject),
          price: isFree ? 0 : 499 + (subject.index * 200),
          quizIds: [quizId],
        );
        await courseRepo.upsertCourse(course);

        final bank = _questionBank[subject]!;
        await quizRepo.upsertQuiz(QuizModel(
          id: quizId,
          courseId: courseId,
          title: '$title — Checkpoint Quiz',
          questions: [
            for (var i = 0; i < bank.length; i++)
              QuizQuestion(
                id: '${quizId}_q$i',
                question: bank[i]['q'] as String,
                options: List<String>.from(bank[i]['options'] as List),
                correctOptionIndex: bank[i]['a'] as int,
              ),
          ],
        ));

        // 3. One class that already happened (unlocks doubt chat) and
        // one upcoming class, so calendars/dashboards aren't empty.
        await scheduleRepo.upsertScheduledClass(ScheduledClass(
          id: '${courseId}_class_past',
          courseId: courseId,
          teacherId: SeedIds.teacherFor(subject),
          title: '$title — Live Session 1',
          dateTime: now.subtract(const Duration(days: 2, hours: 1)),
          zoomLink: 'https://zoom.us/j/demo-${courseId.hashCode.abs()}',
        ));
        await scheduleRepo.upsertScheduledClass(ScheduledClass(
          id: '${courseId}_class_upcoming',
          courseId: courseId,
          teacherId: SeedIds.teacherFor(subject),
          title: '$title — Live Session 2',
          dateTime: now.add(Duration(days: 1 + subject.index, hours: 17)),
        ));

        // 4. One track-specific assessment + one mini-project brief per
        // course, so the assessment engine and projects hub always have
        // real content to open.
        await platformRepo.upsertAssessment(
            _assessmentFor(courseId, subject, grade));

        final proj = _projectBank[subject]!;
        await platformRepo.upsertProject(MiniProject(
          id: '${courseId}_proj',
          courseId: courseId,
          subject: subject,
          grade: grade,
          title: proj['title'] as String,
          brief: proj['brief'] as String,
          deliverables: List<String>.from(proj['deliverables'] as List),
        ));

        // 5. A welcome announcement from the teacher and a permanent
        // sample recording (public preview clip) for the course.
        await platformRepo.addAnnouncement(Announcement(
          id: '${courseId}_ann',
          courseId: courseId,
          teacherId: SeedIds.teacherFor(subject),
          title: 'Welcome to $title',
          body:
              'Glad to have you here! Watch the sample lesson, then join our '
              'next live session. Post any doubts in the chat anytime.',
          createdAt: now.subtract(const Duration(days: 3)),
        ));
        await platformRepo.upsertRecording(Recording(
          id: '${courseId}_rec_sample',
          classId: '${courseId}_class_past',
          courseId: courseId,
          title: '$title — Sample Lesson',
          isSample: true,
          shareUrl: 'https://edunova.demo/watch/${courseId.hashCode.abs()}',
          createdAt: now.subtract(const Duration(days: 3)),
        ));
      }
    }

    // 6. One audit-log entry so the admin audit view isn't empty.
    await platformRepo.addAuditEntry(AuditEntry(
      id: 'seed_audit_bootstrap',
      actorId: SeedIds.admin,
      actorName: 'Priya Sharma',
      action: 'Seeded platform content',
      target: 'courses, assessments, projects',
      createdAt: now,
    ));
  }

  /// Called once right after a student finishes onboarding: gives them a
  /// couple of purchased courses, a realistic (and intentionally uneven —
  /// so the lagging-subject tracker has something to show) quiz history,
  /// and one open doubt-chat thread.
  static Future<void> seedProgressForStudent({
    required AppUser student,
    required CourseRepository courseRepo,
    required QuizRepository quizRepo,
    required DoubtChatRepository doubtRepo,
    required TransactionRepository transactionRepo,
    required PlatformRepository platformRepo,
  }) async {
    if (student.grade == null) return;
    final random = Random(student.id.hashCode);
    final courses = await courseRepo.getCoursesByGradeAndSubject(student.grade!, null);
    if (courses.isEmpty) return;

    // Purchase the free courses plus a couple of paid ones so "My
    // Courses" and "Continue learning" aren't empty on first run. Every
    // paid purchase is recorded as a transaction, backdated over the last
    // ~60 days, so the revenue dashboards have a real trend to show
    // instead of a single spike on day one.
    const uuid = Uuid();
    for (final course in courses) {
      final shouldPurchase = !course.requiresPurchase || random.nextBool();
      if (shouldPurchase) {
        await courseRepo.purchaseCourse(course.id);
        if (course.requiresPurchase) {
          await transactionRepo.recordTransaction(TransactionModel(
            id: uuid.v4(),
            studentId: student.id,
            courseId: course.id,
            teacherId: course.teacherId,
            amount: course.price,
            createdAt: DateTime.now().subtract(Duration(days: random.nextInt(60))),
          ));
        }
      }
    }

    final purchasedIds = await courseRepo.getPurchasedCourseIds();
    final purchasedCourses = courses.where((c) => purchasedIds.contains(c.id)).toList();

    // Deliberately skew scores per subject so at least one subject lands
    // below the lagging threshold — makes the "where you need to catch
    // up" section meaningful instead of always empty.
    const subjectBias = {
      Subject.tech: 0.85,
      Subject.business: 0.75,
      Subject.finance: 0.45, // intentionally weak, for the lagging demo
      Subject.contentCreation: 0.9,
    };

    // Start at day-offset 0 (today) and count backwards so the streak
    // stat on the profile/dashboard is real and non-zero on first launch.
    var dayOffset = 0;
    for (final course in purchasedCourses) {
      final quizzes = await quizRepo.getQuizzesByCourse(course.id);
      for (final quiz in quizzes) {
        final bias = subjectBias[course.subject] ?? 0.7;
        final total = quiz.questions.length;
        final jitter = (random.nextDouble() - 0.5) * 0.25;
        final ratio = (bias + jitter).clamp(0.2, 1.0);
        final score = (total * ratio).round().clamp(0, total);
        await quizRepo.recordAttempt(QuizAttempt(
          id: '${student.id}_attempt_$dayOffset',
          studentId: student.id,
          quizId: quiz.id,
          courseId: course.id,
          score: score,
          totalQuestions: total,
          takenAt: DateTime.now().subtract(Duration(days: dayOffset)),
        ));
        dayOffset++;
      }
    }

    // One doubt thread with the teacher of the first purchased course,
    // with a short back-and-forth already in it.
    if (purchasedCourses.isNotEmpty) {
      final course = purchasedCourses.first;
      final thread = await doubtRepo.getOrCreateThread(
        studentId: student.id,
        teacherId: course.teacherId,
        courseId: course.id,
      );
      await doubtRepo.sendMessage(DoubtMessage(
        id: '${thread.id}_msg1',
        threadId: thread.id,
        senderId: student.id,
        text: "Hi! I didn't fully understand today's class, can you help?",
        sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      ));
      await doubtRepo.sendMessage(DoubtMessage(
        id: '${thread.id}_msg2',
        threadId: thread.id,
        senderId: course.teacherId,
        text: 'Of course — tell me which part felt confusing and we\'ll go through it.',
        sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ));
    }

    // Attendance for the (already-happened) first live class of each
    // purchased course, so the attendance screen and parent report have
    // real history. Most present, an occasional late/absent for realism.
    for (var i = 0; i < purchasedCourses.length; i++) {
      final course = purchasedCourses[i];
      final roll = random.nextInt(10);
      final status = roll < 8
          ? AttendanceStatus.present
          : (roll == 8 ? AttendanceStatus.late : AttendanceStatus.absent);
      await platformRepo.upsertAttendance(AttendanceRecord(
        id: '${student.id}_att_${course.id}',
        classId: '${course.id}_class_past',
        courseId: course.id,
        studentId: student.id,
        status: status,
        markedAt: DateTime.now().subtract(const Duration(days: 2)),
      ));
    }

    // Award one certificate for the strongest purchased course (>=70%),
    // so the certificates/portfolio screen starts with something earned.
    Certificate? best;
    for (final course in purchasedCourses) {
      final attempts = (await quizRepo.getAttemptsForStudent(student.id))
          .where((a) => a.courseId == course.id)
          .toList();
      if (attempts.isEmpty) continue;
      final pct = attempts
              .map((a) => a.totalQuestions == 0
                  ? 0.0
                  : a.score / a.totalQuestions)
              .reduce((a, b) => a > b ? a : b) *
          100;
      if (pct >= 70 &&
          (best == null || pct.round() > best.scorePercent)) {
        best = Certificate(
          id: '${student.id}_cert_${course.id}',
          studentId: student.id,
          studentName: student.name,
          courseId: course.id,
          title: course.title,
          subject: course.subject,
          grade: student.grade!,
          scorePercent: pct.round(),
          issuedAt: DateTime.now().subtract(const Duration(days: 1)),
        );
      }
    }
    if (best != null) {
      await platformRepo.upsertCertificate(best);
      await platformRepo.addNotification(NotificationItem(
        id: '${student.id}_notif_cert',
        userId: student.id,
        type: NotificationType.certificate,
        title: 'Certificate earned!',
        body: 'You earned a certificate for "${best.title}". View it in your portfolio.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ));
    }

    // A welcome + a class-reminder notification so the bell isn't empty.
    await platformRepo.addNotification(NotificationItem(
      id: '${student.id}_notif_welcome',
      userId: student.id,
      type: NotificationType.announcement,
      title: 'Welcome to EduNova',
      body: 'Explore your courses, assessments and mini-projects to get started.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ));
    if (purchasedCourses.isNotEmpty) {
      await platformRepo.addNotification(NotificationItem(
        id: '${student.id}_notif_class',
        userId: student.id,
        type: NotificationType.classReminder,
        title: 'Upcoming live class',
        body: 'Your next "${purchasedCourses.first.title}" session is coming up soon.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ));
    }
  }
}
