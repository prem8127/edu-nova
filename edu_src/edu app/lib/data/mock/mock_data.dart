import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../models/app_models.dart';

abstract final class MockData {
  static const courses = <Course>[
    Course(
      title: 'UI/UX Design Foundations',
      category: 'Design',
      level: 'Beginner',
      duration: '8 weeks',
      progress: .68,
      rating: 4.9,
      color: Color(0xFFFFD7C2),
      icon: Icons.draw_rounded,
      description: 'Learn the principles, tools, and real-world workflows behind products people love to use.',
      teacherName: 'Maya Sharma',
      teacherRole: 'Senior Product Designer · Figma',
      teacherInitials: 'MS',
      learners: 2480,
      chapters: [
        Chapter(title: 'Design foundations', lessons: [
          Lesson(title: 'The principles of visual hierarchy', duration: '12:48', description: 'Learn how size, contrast, spacing and alignment guide attention through an interface.', completed: true),
          Lesson(title: 'Color theory for interfaces', duration: '15:20', description: 'Build palettes that communicate mood, hierarchy, and accessibility.', completed: true),
          Lesson(title: 'Typography that works', duration: '11:05', description: 'Choosing and pairing type for clarity and personality.'),
        ]),
        Chapter(title: 'Research that reveals', lessons: [
          Lesson(title: 'Talking to real users', duration: '18:40', description: 'Interview techniques that surface honest feedback.'),
          Lesson(title: 'Synthesizing research', duration: '14:12', description: 'Turning notes into actionable insight.'),
        ]),
        Chapter(title: 'Ideas into interfaces', lessons: [
          Lesson(title: 'Wireframing at speed', duration: '16:30', description: 'Sketch and structure screens before polishing.', locked: true),
          Lesson(title: 'Prototyping in Figma', duration: '20:05', description: 'Bring flows to life with interactive prototypes.', locked: true),
        ]),
        Chapter(title: 'Test, learn, iterate', lessons: [
          Lesson(title: 'Usability testing basics', duration: '13:55', description: 'Run lightweight tests and read the signal.', locked: true),
        ]),
      ],
    ),
    Course(
      title: 'Python for Data Science',
      category: 'Technology',
      level: 'Intermediate',
      duration: '10 weeks',
      progress: .32,
      rating: 4.8,
      color: Color(0xFFDDE7FF),
      icon: Icons.data_object_rounded,
      description: 'Go from Python basics to building real data pipelines and models used in industry.',
      teacherName: 'Arjun Mehta',
      teacherRole: 'AI Research Engineer · Orbit AI',
      teacherInitials: 'AM',
      learners: 3120,
      chapters: [
        Chapter(title: 'Python essentials', lessons: [
          Lesson(title: 'Variables, loops & functions', duration: '14:22', description: 'A fast, practical refresher on core Python.', completed: true),
          Lesson(title: 'Working with NumPy arrays', duration: '17:08', description: 'Vectorized operations for fast data work.', completed: true),
        ]),
        Chapter(title: 'Data wrangling', lessons: [
          Lesson(title: 'Pandas for real datasets', duration: '19:45', description: 'Clean, reshape, and explore messy data.'),
          Lesson(title: 'Handling missing data', duration: '12:30', description: 'Strategies for gaps and outliers.', locked: true),
        ]),
        Chapter(title: 'Intro to modeling', lessons: [
          Lesson(title: 'Your first regression model', duration: '21:10', description: 'Fit, evaluate, and interpret a simple model.', locked: true),
        ]),
      ],
    ),
    Course(
      title: 'Digital Marketing Strategy',
      category: 'Business',
      level: 'Beginner',
      duration: '6 weeks',
      progress: 0,
      rating: 4.7,
      color: Color(0xFFE7F5DF),
      icon: Icons.campaign_rounded,
      description: 'Plan, launch, and measure marketing campaigns that actually move the needle.',
      teacherName: 'Nisha Reddy',
      teacherRole: 'Career Strategist · Sprout',
      teacherInitials: 'NR',
      learners: 1860,
      chapters: [
        Chapter(title: 'Foundations of strategy', lessons: [
          Lesson(title: 'Understanding your audience', duration: '13:15', description: 'Segment and target the people who matter most.'),
          Lesson(title: 'Positioning and messaging', duration: '15:40', description: 'Craft a message that sticks.', locked: true),
        ]),
        Chapter(title: 'Channels that convert', lessons: [
          Lesson(title: 'Social media playbook', duration: '18:02', description: 'Building an organic content engine.', locked: true),
        ]),
      ],
    ),
    Course(
      title: 'Financial Literacy',
      category: 'Finance',
      level: 'All levels',
      duration: '4 weeks',
      progress: 0,
      rating: 4.9,
      color: Color(0xFFFFE9AF),
      icon: Icons.account_balance_wallet_rounded,
      description: 'Practical money skills — budgeting, saving, and investing — for everyday life.',
      teacherName: 'Nisha Reddy',
      teacherRole: 'Career Strategist · Sprout',
      teacherInitials: 'NR',
      learners: 960,
      chapters: [
        Chapter(title: 'Money basics', lessons: [
          Lesson(title: 'Budgeting that sticks', duration: '10:50', description: 'A simple system to track every rupee.'),
          Lesson(title: 'Saving with intention', duration: '11:35', description: 'Building an emergency fund and beyond.', locked: true),
        ]),
      ],
    ),
  ];

  static const mentors = <Mentor>[
    Mentor(name: 'Maya Sharma', role: 'Senior Product Designer', expertise: 'Design careers', rating: 4.9, color: AppColors.orangeSoft, initials: 'MS'),
    Mentor(name: 'Arjun Mehta', role: 'AI Research Engineer', expertise: 'AI & data science', rating: 4.8, color: Color(0xFFDDE7FF), initials: 'AM'),
    Mentor(name: 'Nisha Reddy', role: 'Career Strategist', expertise: 'Career transitions', rating: 4.9, color: Color(0xFFE7F5DF), initials: 'NR'),
  ];

  static const internships = <Opportunity>[
    Opportunity(title: 'Product Design Intern', organization: 'Nova Labs', meta: 'Remote · 3 months · ₹15k/mo', type: 'Design', color: AppColors.orangeSoft, icon: Icons.design_services_rounded),
    Opportunity(title: 'Machine Learning Intern', organization: 'Orbit AI', meta: 'Bengaluru · 6 months · ₹25k/mo', type: 'Technology', color: Color(0xFFDDE7FF), icon: Icons.auto_awesome_rounded),
    Opportunity(title: 'Growth Marketing Intern', organization: 'Sprout', meta: 'Hybrid · 4 months · ₹18k/mo', type: 'Marketing', color: Color(0xFFE7F5DF), icon: Icons.trending_up_rounded),
  ];

  static const notifications = <AppNotification>[
    AppNotification(title: 'Your roadmap is ready', body: 'Your personalized Product Designer learning path has 6 milestones.', time: '10 min ago', icon: Icons.route_rounded, color: AppColors.orangeSoft, isNew: true),
    AppNotification(title: 'Live session in 30 minutes', body: 'Join Maya Sharma for Portfolio reviews that get noticed.', time: '1 hr ago', icon: Icons.videocam_rounded, color: Color(0xFFDDE7FF), isNew: true),
    AppNotification(title: 'Weekly goal achieved!', body: 'You completed 4 lessons and kept your 12-day streak alive.', time: 'Yesterday', icon: Icons.local_fire_department_rounded, color: Color(0xFFFFE9AF)),
    AppNotification(title: 'New internship match', body: 'Nova Labs is looking for a Product Design Intern.', time: '2 days ago', icon: Icons.work_rounded, color: Color(0xFFE7F5DF)),
  ];
}
