import 'package:flutter/material.dart';

import '../premium_student_dashboard.dart';

/// College Students — "Career Launch & Skill Accelerator"
class CollegeHome extends StatelessWidget {
  const CollegeHome({super.key});

  @override
  Widget build(BuildContext context) => const PremiumStudentDashboard(
        config: PremiumDashboardConfig(
          name: 'Aarav',
          title: 'Career Launch & Skill Accelerator',
          subtitle: 'Placement-ready college hub for internships, industry skills, projects, and interview prep.',
          themeLabel: 'CAREER ACCELERATOR',
          avatar: 'A',
          level: 52,
          streak: 18,
          xp: 27650,
          xpTarget: 32000,
          rank: '#9 Rank',
          primary: Color(0xFF111827),
          secondary: Color(0xFF2563EB),
          accent: Color(0xFF14B8A6),
          warm: Color(0xFFF59E0B),
          backgroundTop: Color(0xFFEEF2FF),
          backgroundBottom: Color(0xFFF8FAFC),
          navColor: Color(0xFF111827),
          heroTitle: 'Target: placement-ready portfolio in 90 days',
          heroAction: 'Launch',
          examMode: false,
          petMode: false,
          castleMode: false,
          prepHubTitle: 'Placements & Certification Hub',
          prepHubItems: ['Aptitude tests', 'Mock interviews', 'Resume builder', 'Coding rounds', 'Certifications'],
          subjects: [
            PremiumSubject('Data Structures & Algorithms', Icons.account_tree_rounded, Color(0xFF2563EB), .81, 'Graph algorithms need one more practice round.'),
            PremiumSubject('Core Branch Subjects', Icons.school_rounded, Color(0xFF14B8A6), .77, 'Semester coursework is on track.'),
            PremiumSubject('Aptitude & Reasoning', Icons.psychology_rounded, Color(0xFFF59E0B), .84, 'Quant speed has improved this week.'),
            PremiumSubject('Communication & Soft Skills', Icons.record_voice_over_rounded, Color(0xFF9333EA), .88, 'Mock interview scores are strong.'),
            PremiumSubject('Industry Tools & Projects', Icons.terminal_rounded, Color(0xFF0EA5E9), .73, 'One capstone project milestone is due.'),
          ],
          continueLessons: ['Graph Algorithms', 'Core Coursework', 'Quant Practice', 'Mock Interview', 'Capstone Project'],
          missions: ['Solve 5 DSA problems', 'Complete one mock interview', 'Update resume with new project', 'Apply to 2 internships'],
          rewards: ['Placement Ready', 'Project Shipper', 'Interview Ace', 'Skill Sprinter'],
          mentorTitle: 'AI Career Mentor',
          mentorMessage: 'Focus today: graph algorithms practice, then a timed aptitude set, then one internship application.',
          challengeTitle: 'Weekly Career Sprints',
          challengeDetail: 'Finish 2 mock interviews and 1 project milestone to unlock the Placement Ready badge.',
          analyticsTitle: 'Skill & Readiness Analytics',
          analyticsValues: [.58, .66, .71, .69, .78, .83, .89],
          upcoming: ['Today 6:00 PM - Mock Technical Interview', 'Tomorrow 5:00 PM - Resume Review Session', 'Sunday 11:00 AM - Placement Drive Briefing'],
          recommendations: ['Internship Matches: software engineering roles', 'Skill Gap Alert: system design basics', 'Certification Pick: cloud fundamentals'],
          leaderboard: ['Meera - 29840 XP', 'Aarav - 27650 XP', 'Kabir - 26980 XP', 'Divya - 26120 XP'],
          funFact: 'Recruiters spend under a minute scanning a resume — a sharp project section is what earns the callback.',
        ),
      );
}
