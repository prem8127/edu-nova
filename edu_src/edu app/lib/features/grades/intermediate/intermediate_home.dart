import 'package:flutter/material.dart';

import '../premium_student_dashboard.dart';

class IntermediateHome extends StatefulWidget {
  const IntermediateHome({super.key});

  @override
  State<IntermediateHome> createState() => _IntermediateHomeState();
}

class _IntermediateHomeState extends State<IntermediateHome> {
  var _year = 0;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          PremiumStudentDashboard(config: _year == 0 ? _class11 : _class12),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .88), borderRadius: BorderRadius.circular(99), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 18)]),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _YearButton(label: 'Class 11', selected: _year == 0, onTap: () => setState(() => _year = 0)),
                      _YearButton(label: 'Class 12', selected: _year == 1, onTap: () => setState(() => _year = 1)),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

class _YearButton extends StatelessWidget {
  const _YearButton({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? const Color(0xFF0B1B3F) : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            child: Text(label, style: TextStyle(color: selected ? Colors.white : const Color(0xFF0B1B3F), fontWeight: FontWeight.w900)),
          ),
        ),
      );
}

const _class11 = PremiumDashboardConfig(
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
);

const _class12 = PremiumDashboardConfig(
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
);
