import 'package:flutter/material.dart';

import '../premium_student_dashboard.dart';

class Class7Home extends StatelessWidget {
  const Class7Home({super.key});

  @override
  Widget build(BuildContext context) => const PremiumStudentDashboard(
        config: PremiumDashboardConfig(
          name: 'Aarav',
          title: 'Adventure Learning World',
          subtitle: 'Class 7 explorer path for curious minds, daily quests, rewards, and playful mastery.',
          themeLabel: 'CLASS 7 QUEST',
          avatar: 'A',
          level: 12,
          streak: 9,
          xp: 4280,
          xpTarget: 5600,
          rank: '#4 Explorer',
          primary: Color(0xFF087CFF),
          secondary: Color(0xFF7C3AED),
          accent: Color(0xFF7ED957),
          warm: Color(0xFFFFA928),
          backgroundTop: Color(0xFFEAF7FF),
          backgroundBottom: Color(0xFFFFF8DC),
          navColor: Color(0xFF087CFF),
          heroTitle: 'Next realm unlock: Ratio Rapids',
          heroAction: 'Continue',
          subjects: [
            PremiumSubject('Math', Icons.calculate_rounded, Color(0xFF087CFF), .76, 'Fractions and ratios are getting stronger.'),
            PremiumSubject('Science', Icons.science_rounded, Color(0xFF7ED957), .68, 'Light and motion lab quest is active.'),
            PremiumSubject('English', Icons.menu_book_rounded, Color(0xFFFFC928), .82, 'Reading streak is ahead of target.'),
            PremiumSubject('Social Studies', Icons.public_rounded, Color(0xFFFF8A00), .61, 'Map skills need one short review.'),
            PremiumSubject('Computer Science', Icons.memory_rounded, Color(0xFF7C3AED), .72, 'Logic puzzles unlocked.'),
          ],
          continueLessons: ['Quest 4', 'Live Lab', 'Story Trail', 'Map Mission', 'Code Cave'],
          missions: ['Solve 8 Math gems', 'Complete one Science experiment', 'Read the English story chapter', 'Win a Code Cave mini game'],
          rewards: ['Fast Learner', 'Quest Hero', 'Lab Spark', 'Code Cub'],
          mentorTitle: 'AI Learning Buddy',
          mentorMessage: 'Zippy can explain ratios using pizza slices, cricket scores, or treasure maps.',
          challengeTitle: 'Weekly Challenge',
          challengeDetail: 'Finish 5 subject quests to earn 300 XP and the Realm Hopper badge.',
          analyticsTitle: 'Weekly XP Analytics',
          analyticsValues: [.42, .62, .54, .74, .68, .48, .88],
          upcoming: ['Today 4:00 PM - Math Adventure Class', 'Tomorrow 5:30 PM - Science Live Lab', 'Friday 6:00 PM - English Story Arena'],
          recommendations: ['Achievement Center: unlock Star Reader', 'Try Social Studies map sprint', 'Revise Ratio Rapids before Friday'],
          leaderboard: ['Isha - 5020 XP', 'Aarav - 4860 XP', 'Kabir - 4610 XP', 'Meera - 4380 XP'],
          funFact: 'A lightning bolt can heat the air around it to nearly five times hotter than the surface of the Sun.',
        ),
      );
}
