import 'package:flutter/material.dart';

import '../premium_student_dashboard.dart';

/// Intermediate 1st Year — "Career & Competitive Exam Accelerator"
class InterFirstYearHome extends StatelessWidget {
  const InterFirstYearHome({super.key});

  @override
  Widget build(BuildContext context) => const PremiumStudentDashboard(
        config: PremiumDashboardConfig(
          name: 'Ishaan',
          title: 'Career & Competitive Exam Accelerator',
          subtitle: 'Elite Intermediate 1st Year hub for board foundations, JEE/NEET/EAMCET prep, and career clarity.',
          themeLabel: 'CLASS 11 ACCELERATOR',
          avatar: 'I',
          level: 36,
          streak: 24,
          xp: 14860,
          xpTarget: 18000,
          rank: '#46 Rank',
          primary: Color(0xFF0B1B3F),
          secondary: Color(0xFF3730A3),
          accent: Color(0xFF06B6D4),
          warm: Color(0xFFD4AF37),
          backgroundTop: Color(0xFFEFF6FF),
          backgroundBottom: Color(0xFFF8FAFC),
          navColor: Color(0xFFD4AF37),
          heroTitle: 'Target: strengthen concepts before advanced problem sets',
          heroAction: 'Accelerate',
          examMode: true,
          petMode: false,
          castleMode: false,
          prepHubTitle: 'JEE / NEET / EAMCET Preparation Hub',
          prepHubItems: ['JEE track', 'NEET track', 'EAMCET track', 'Practice sets', 'Formula vault'],
          subjects: [
            PremiumSubject('Mathematics', Icons.functions_rounded, Color(0xFF2563EB), .79, 'Sequences and trigonometry foundation is building.'),
            PremiumSubject('Physics', Icons.bolt_rounded, Color(0xFF06B6D4), .72, 'Kinematics numericals need more timed sets.'),
            PremiumSubject('Chemistry', Icons.science_rounded, Color(0xFF7C3AED), .75, 'Mole concept practice is improving.'),
            PremiumSubject('English', Icons.menu_book_rounded, Color(0xFFD4AF37), .86, 'Communication section is strong.'),
            PremiumSubject('Computer Science / Optional Subjects', Icons.memory_rounded, Color(0xFF0EA5E9), .81, 'Programming basics are ahead.'),
          ],
          continueLessons: ['Trigonometry', 'Kinematics', 'Mole Concept', 'Writing', 'Programming'],
          missions: ['Finish daily study planner', 'Attempt 20 competitive numericals', 'Revise one Chemistry concept map', 'Update goal tracker'],
          rewards: ['Concept Builder', 'Rank Climber', 'Gold Focus', 'Mock Starter'],
          mentorTitle: 'AI Academic Mentor',
          mentorMessage: 'Today is best for Physics kinematics, then Chemistry mole concept, then a 15-minute goal review.',
          challengeTitle: 'Weekly Challenges',
          challengeDetail: 'Complete 3 practice sets and 1 mock analysis to lift your projected rank.',
          analyticsTitle: 'Subject-wise Performance Analytics',
          analyticsValues: [.62, .70, .66, .78, .82, .74, .88],
          upcoming: ['Today 7:00 PM - Physics Problem Solving', 'Tomorrow 6:00 PM - JEE Foundation Set', 'Sunday 10:00 AM - Career Guidance'],
          recommendations: ['Career Guidance Section: engineering vs data science', 'Smart Revision Schedule: kinematics', 'Personalized Learning Recommendations: mole concept'],
          leaderboard: ['Neha - 16240 XP', 'Ishaan - 15880 XP', 'Aman - 15130 XP', 'Priya - 14820 XP'],
          funFact: 'Conceptual clarity in Class 11 often decides how quickly advanced entrance-exam problems click in Class 12.',
        ),
      );
}
