import 'package:flutter/material.dart';

enum StudentGrade { six, seven, eight, nine, ten, intermediate }

extension StudentGradeX on StudentGrade {
  /// Used in route paths, e.g. /class/6, /class/intermediate
  String get routeKey => switch (this) {
        StudentGrade.six => '6',
        StudentGrade.seven => '7',
        StudentGrade.eight => '8',
        StudentGrade.nine => '9',
        StudentGrade.ten => '10',
        StudentGrade.intermediate => 'intermediate',
      };

  String get label => switch (this) {
        StudentGrade.six => 'Class 6',
        StudentGrade.seven => 'Class 7',
        StudentGrade.eight => 'Class 8',
        StudentGrade.nine => 'Class 9',
        StudentGrade.ten => 'Class 10',
        StudentGrade.intermediate => 'Intermediate',
      };

  String get ageRange => switch (this) {
        StudentGrade.six => '10–11 yrs',
        StudentGrade.seven => '11–12 yrs',
        StudentGrade.eight => '12–13 yrs',
        StudentGrade.nine => '13–14 yrs',
        StudentGrade.ten => '14–16 yrs',
        StudentGrade.intermediate => '16–18 yrs',
      };

  String get tagline => switch (this) {
        StudentGrade.six => 'Fun & playful learning',
        StudentGrade.seven => 'Daily challenges & subject paths',
        StudentGrade.eight => 'Clean, modern student space',
        StudentGrade.nine => 'Academic & goal-driven',
        StudentGrade.ten => 'Exam prep mode',
        StudentGrade.intermediate => 'College-style platform',
      };

  IconData get icon => switch (this) {
        StudentGrade.six => Icons.star_rounded,
        StudentGrade.seven => Icons.explore_rounded,
        StudentGrade.eight => Icons.dashboard_customize_rounded,
        StudentGrade.nine => Icons.insights_rounded,
        StudentGrade.ten => Icons.timer_rounded,
        StudentGrade.intermediate => Icons.workspace_premium_rounded,
      };

  static StudentGrade? fromRouteKey(String? key) => switch (key) {
        '6' => StudentGrade.six,
        '7' => StudentGrade.seven,
        '8' => StudentGrade.eight,
        '9' => StudentGrade.nine,
        '10' => StudentGrade.ten,
        'intermediate' => StudentGrade.intermediate,
        _ => null,
      };
}
