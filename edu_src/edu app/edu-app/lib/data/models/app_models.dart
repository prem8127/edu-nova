import 'package:flutter/material.dart';

/// A single recorded video lesson within a course chapter.
class Lesson {
  const Lesson({
    required this.title,
    required this.duration,
    this.description = '',
    this.completed = false,
    this.locked = false,
  });
  final String title;
  final String duration;
  final String description;
  final bool completed;
  final bool locked;
}

/// A chapter/module grouping several recorded lessons — this is the
/// syllabus unit a teacher builds out in their curriculum.
class Chapter {
  const Chapter({required this.title, required this.lessons});
  final String title;
  final List<Lesson> lessons;
}

class Course {
  const Course({
    required this.title,
    required this.category,
    required this.level,
    required this.duration,
    required this.progress,
    required this.rating,
    required this.color,
    required this.icon,
    this.description = 'Learn the principles, tools, and real-world workflows behind this subject.',
    this.teacherName = 'Maya Sharma',
    this.teacherRole = 'Senior Product Designer',
    this.teacherInitials = 'MS',
    this.grade = '',
    this.learners = 2480,
    this.chapters = const [],
  });
  final String title;
  final String category;
  final String level;
  final String duration;
  final double progress;
  final double rating;
  final Color color;
  final IconData icon;
  final String description;
  final String teacherName;
  final String teacherRole;
  final String teacherInitials;
  final String grade;
  final int learners;
  final List<Chapter> chapters;

  int get totalLessons => chapters.fold(0, (sum, c) => sum + c.lessons.length);
}

class Mentor {
  const Mentor({required this.name, required this.role, required this.expertise, required this.rating, required this.color, required this.initials});
  final String name;
  final String role;
  final String expertise;
  final double rating;
  final Color color;
  final String initials;
}

class Opportunity {
  const Opportunity({required this.title, required this.organization, required this.meta, required this.type, required this.color, required this.icon});
  final String title;
  final String organization;
  final String meta;
  final String type;
  final Color color;
  final IconData icon;
}

class AppNotification {
  const AppNotification({required this.title, required this.body, required this.time, required this.icon, required this.color, this.isNew = false});
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color color;
  final bool isNew;
}
