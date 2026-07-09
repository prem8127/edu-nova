import 'package:flutter/material.dart';

import '../premium_student_dashboard.dart';

class Class8Home extends StatelessWidget {
  const Class8Home({super.key});

  @override
  Widget build(BuildContext context) => const PremiumStudentDashboard(
        config: PremiumDashboardConfig(
          name: 'Diya',
          title: 'Adventure Learning World Pro',
          subtitle: 'A modern Class 8 journey with richer goals, smarter quests, and premium reward loops.',
          themeLabel: 'CLASS 8 ADVENTURE',
          avatar: 'D',
          level: 18,
          streak: 14,
          xp: 6120,
          xpTarget: 7600,
          rank: '#3 Voyager',
          primary: Color(0xFF087CFF),
          secondary: Color(0xFF4338CA),
          accent: Color(0xFF7ED957),
          warm: Color(0xFFFFB000),
          backgroundTop: Color(0xFFEAF3FF),
          backgroundBottom: Color(0xFFF5FFE8),
          navColor: Color(0xFF4338CA),
          heroTitle: 'Current expedition: Algebra Island',
          heroAction: 'Explore',
          subjects: [
            PremiumSubject('Mathematics', Icons.functions_rounded, Color(0xFF087CFF), .78, 'Linear equations track is ahead.'),
            PremiumSubject('Science', Icons.biotech_rounded, Color(0xFF7ED957), .73, 'Cells and tissues mastery is rising.'),
            PremiumSubject('English', Icons.auto_stories_rounded, Color(0xFFFFC928), .84, 'Grammar quests are nearly complete.'),
            PremiumSubject('Social Studies', Icons.travel_explore_rounded, Color(0xFFFF8A00), .67, 'History timeline review suggested.'),
            PremiumSubject('Computer Science', Icons.terminal_rounded, Color(0xFF7C3AED), .81, 'Algorithms mini-game unlocked.'),
          ],
          continueLessons: ['Algebra Island', 'Bio Lab', 'Grammar Quest', 'History Trail', 'Code Arcade'],
          missions: ['Complete Algebra Island checkpoint', 'Practice 12 Science flash cards', 'Win one English word duel', 'Review one Social Studies timeline'],
          rewards: ['Algebra Ace', 'Bio Explorer', 'Word Champion', 'Code Pilot'],
          mentorTitle: 'AI Learning Buddy',
          mentorMessage: 'Nova gives hints, quiz boosts, and maturity-friendly explanations without making study feel heavy.',
          challengeTitle: 'Weekly Challenge',
          challengeDetail: 'Score 80%+ in three subject quests to unlock a rare Voyager badge.',
          analyticsTitle: 'Weekly XP Analytics',
          analyticsValues: [.54, .67, .72, .63, .80, .58, .92],
          upcoming: ['Today 4:30 PM - Algebra Live Studio', 'Tomorrow 5:00 PM - Science Practice Lab', 'Saturday 10:00 AM - Coding Challenge'],
          recommendations: ['Achievement Center: complete Bio Explorer', 'Try the Algebra boss quiz', 'Open Magic Treasure Chest after missions'],
          leaderboard: ['Riya - 6920 XP', 'Vihaan - 6740 XP', 'Diya - 6610 XP', 'Arjun - 6340 XP'],
          funFact: 'Your brain forms stronger memories when you test yourself instead of only rereading notes.',
        ),
      );
}
