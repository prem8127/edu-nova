import 'package:flutter/material.dart';

import '../premium_student_dashboard.dart';

class Class10Home extends StatelessWidget {
  const Class10Home({super.key});

  @override
  Widget build(BuildContext context) => const PremiumStudentDashboard(
        config: PremiumDashboardConfig(
          name: 'Ishaan',
          title: 'Board Exam Success Hub',
          subtitle: 'Focused, premium Class 10 command center for board preparation and top-result momentum.',
          themeLabel: 'CLASS 10 BOARDS',
          avatar: 'I',
          level: 30,
          streak: 21,
          xp: 11840,
          xpTarget: 14000,
          rank: '#2 Rank',
          primary: Color(0xFF0B1F4D),
          secondary: Color(0xFF6D28D9),
          accent: Color(0xFF06B6D4),
          warm: Color(0xFFF5C542),
          backgroundTop: Color(0xFFEFF6FF),
          backgroundBottom: Color(0xFFFFFBEB),
          navColor: Color(0xFF0B1F4D),
          heroTitle: 'Goal progress: 92% board readiness',
          heroAction: 'Revise',
          examMode: true,
          petMode: false,
          castleMode: false,
          examCountdown: '47 days left',
          prepHubTitle: 'Mock Tests & Practice Papers',
          prepHubItems: ['Full mock', 'Chapter test', 'Previous papers', 'Practice papers', 'Doubt review'],
          subjects: [
            PremiumSubject('Mathematics', Icons.functions_rounded, Color(0xFF2563EB), .88, 'Trigonometry and statistics are strong.'),
            PremiumSubject('Science', Icons.science_rounded, Color(0xFF06B6D4), .82, 'Chemistry equations need one review.'),
            PremiumSubject('English', Icons.menu_book_rounded, Color(0xFF6D28D9), .91, 'Literature answers are exam-ready.'),
            PremiumSubject('Social Studies', Icons.public_rounded, Color(0xFFF5C542), .79, 'Map work and dates need practice.'),
            PremiumSubject('Computer Science', Icons.memory_rounded, Color(0xFF0EA5E9), .85, 'SQL and Python revision is steady.'),
          ],
          continueLessons: ['Trigonometry', 'Chemistry', 'Literature', 'Maps', 'SQL'],
          missions: ['Complete daily study targets', 'Attempt one timed Math set', 'Revise weak Science topic', 'Analyze one mock-test mistake list'],
          rewards: ['Board Warrior', 'Mock Master', 'Gold Streak', 'Top Rank Push'],
          mentorTitle: 'AI Study Mentor',
          mentorMessage: 'Your mentor recommends Chemistry equations, then a 20-minute Social Studies map drill.',
          challengeTitle: 'Weekly Challenges',
          challengeDetail: 'Score 85%+ in two mock tests to unlock the Board Champion badge.',
          analyticsTitle: 'Goal Progress Dashboard',
          analyticsValues: [.72, .78, .69, .84, .91, .76, .94],
          upcoming: ['Today 6:30 PM - Science Doubt Class', 'Tomorrow 9:00 AM - Full-Length Mock', 'Sunday 5:00 PM - Board Strategy Session'],
          recommendations: ['Personalized Recommendations: chemistry equations', 'Smart Revision Planner: map work', 'Study Streak Tracker: 21 days active'],
          leaderboard: ['Ishaan - 12840 XP', 'Aditi - 12420 XP', 'Rohan - 11970 XP', 'Meera - 11580 XP'],
          funFact: 'Timed practice trains your brain to retrieve answers faster under exam pressure.',
        ),
      );
}
