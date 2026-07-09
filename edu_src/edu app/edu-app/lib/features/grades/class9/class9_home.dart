import 'package:flutter/material.dart';

import '../premium_student_dashboard.dart';

class Class9Home extends StatelessWidget {
  const Class9Home({super.key});

  @override
  Widget build(BuildContext context) => const PremiumStudentDashboard(
        config: PremiumDashboardConfig(
          name: 'Kabir',
          title: 'Future Learning Academy',
          subtitle: 'Aspirational Class 9 dashboard for goals, analytics, revision, and confident progress.',
          themeLabel: 'CLASS 9 FUTURE',
          avatar: 'K',
          level: 24,
          streak: 16,
          xp: 8460,
          xpTarget: 10000,
          rank: '#8 Scholar',
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF4F46E5),
          accent: Color(0xFF06B6D4),
          warm: Color(0xFFA855F7),
          backgroundTop: Color(0xFFEFF6FF),
          backgroundBottom: Color(0xFFF5F3FF),
          navColor: Color(0xFF4F46E5),
          heroTitle: 'Goal: 90% confidence by Term 2 exams',
          heroAction: 'Study',
          examMode: true,
          petMode: false,
          castleMode: false,
          subjects: [
            PremiumSubject('Mathematics', Icons.functions_rounded, Color(0xFF2563EB), .81, 'Quadratic foundations are on track.'),
            PremiumSubject('Science', Icons.science_rounded, Color(0xFF06B6D4), .76, 'Physics numericals need spaced practice.'),
            PremiumSubject('English', Icons.edit_note_rounded, Color(0xFFA855F7), .85, 'Writing skills are above target.'),
            PremiumSubject('Social Studies', Icons.account_balance_rounded, Color(0xFF6366F1), .70, 'Civics flash revision recommended.'),
            PremiumSubject('Computer Science', Icons.developer_mode_rounded, Color(0xFF0891B2), .79, 'Python loops checkpoint unlocked.'),
          ],
          continueLessons: ['Quadratics', 'Motion', 'Writing Lab', 'Civics', 'Python'],
          missions: ['Finish 25-minute revision sprint', 'Attempt 15 Science numericals', 'Take one English writing drill', 'Review weak topic flashcards'],
          rewards: ['Focus Badge', 'Quiz Rewards', 'Streak Shield', 'Analytics Star'],
          mentorTitle: 'AI Study Mentor',
          mentorMessage: 'Your mentor suggests a 35-minute plan: Math first, Science numericals next, English recap last.',
          challengeTitle: 'Weekly Challenges',
          challengeDetail: 'Complete 4 revision blocks and 2 quizzes to unlock the Future Scholar badge.',
          analyticsTitle: 'Subject Performance Analytics',
          analyticsValues: [.58, .72, .64, .82, .75, .61, .88],
          upcoming: ['Today 6:00 PM - Physics Motion Class', 'Tomorrow 7:00 PM - Math Quiz Rewards', 'Monday 5:00 PM - Social Studies Test'],
          recommendations: ['Smart Revision Planner: Motion numericals', 'Learning Resources: Quadratic formula notes', 'Study Streak Tracker: protect 16-day streak'],
          leaderboard: ['Anika - 9360 XP', 'Kabir - 9120 XP', 'Dev - 8840 XP', 'Sara - 8510 XP'],
          funFact: 'Short recall quizzes after study can improve long-term memory more than simply rereading the chapter.',
        ),
      );
}
