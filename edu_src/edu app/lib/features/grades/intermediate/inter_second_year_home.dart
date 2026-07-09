import 'package:flutter/material.dart';

import '../premium_student_dashboard.dart';

/// Intermediate 2nd Year — "Board & Entrance Exam Mastery Hub"
class InterSecondYearHome extends StatelessWidget {
  const InterSecondYearHome({super.key});

  @override
  Widget build(BuildContext context) => const PremiumStudentDashboard(
        config: PremiumDashboardConfig(
          name: 'Ananya',
          title: 'Board & Entrance Exam Mastery Hub',
          subtitle: 'Elite Intermediate 2nd Year dashboard for boards, full-length mocks, weak topics, and college goals.',
          themeLabel: 'CLASS 12 MASTERY',
          avatar: 'A',
          level: 44,
          streak: 31,
          xp: 21840,
          xpTarget: 25000,
          rank: '#18 Rank',
          primary: Color(0xFF061A40),
          secondary: Color(0xFF1D4ED8),
          accent: Color(0xFF7C3AED),
          warm: Color(0xFFD4AF37),
          backgroundTop: Color(0xFFE0F2FE),
          backgroundBottom: Color(0xFFFAF5FF),
          navColor: Color(0xFFD4AF37),
          heroTitle: 'Target: peak performance before boards and entrance exams',
          heroAction: 'Master',
          examMode: true,
          petMode: false,
          castleMode: false,
          examCountdown: '39 days left',
          prepHubTitle: 'JEE / NEET / EAMCET Preparation Hub',
          prepHubItems: ['Full-length mock', 'Weak topics', 'Previous papers', 'Rank predictor', 'College shortlist'],
          subjects: [
            PremiumSubject('Mathematics', Icons.functions_rounded, Color(0xFF1D4ED8), .86, 'Calculus accuracy is rising.'),
            PremiumSubject('Physics', Icons.bolt_rounded, Color(0xFF06B6D4), .80, 'Electrostatics needs one weak-topic cycle.'),
            PremiumSubject('Chemistry', Icons.science_rounded, Color(0xFF7C3AED), .83, 'Organic mechanisms are nearly ready.'),
            PremiumSubject('English', Icons.menu_book_rounded, Color(0xFFD4AF37), .90, 'Board writing format is strong.'),
            PremiumSubject('Computer Science / Stream Subjects', Icons.memory_rounded, Color(0xFF9333EA), .84, 'Revision questions are on schedule.'),
          ],
          continueLessons: ['Calculus', 'Electrostatics', 'Organic', 'Writing', 'Revision'],
          missions: ['Complete daily study targets', 'Take one full-length mock section', 'Review weak topic analysis', 'Solve previous papers set'],
          rewards: ['Mock Master', 'Board Ready', 'Rank Booster', 'Gold Streak'],
          mentorTitle: 'AI Exam Mentor',
          mentorMessage: 'Your strongest move today: electrostatics weak-topic cycle, then a previous-paper Chemistry review.',
          challengeTitle: 'Weekly Goals & Challenges',
          challengeDetail: 'Two full-length mocks plus one board writing drill unlock the Mastery badge.',
          analyticsTitle: 'Subject-wise Performance Analytics',
          analyticsValues: [.76, .82, .79, .88, .91, .84, .96],
          upcoming: ['Today 7:30 PM - Full Mock Review', 'Tomorrow 6:00 PM - Board Writing Drill', 'Sunday 9:00 AM - Entrance Grand Test'],
          recommendations: ['Career & College Guidance: shortlist update', 'Personalized Study Recommendations: electrostatics', 'Previous Papers Section: 2025 board set'],
          leaderboard: ['Ananya - 23880 XP', 'Ritvik - 23120 XP', 'Sana - 22640 XP', 'Karthik - 21980 XP'],
          funFact: 'Mock-test review is most powerful when you classify every mistake as concept, calculation, reading, or time management.',
        ),
      );
}
