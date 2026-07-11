import 'package:flutter/material.dart';

class Mission {
  Mission({required this.title, required this.xp, required this.icon, required this.color, this.done = false});
  final String title;
  final int xp;
  final IconData icon;
  final Color color;
  bool done;
}

class Badge_ {
  const Badge_({required this.icon, required this.color, required this.label, this.locked = false});
  final IconData icon;
  final Color color;
  final String label;
  final bool locked;
}

class LeaderRow {
  const LeaderRow({required this.rank, required this.name, required this.emoji, required this.xp, this.isMe = false});
  final int rank;
  final String name;
  final String emoji;
  final int xp;
  final bool isMe;
}

class ClassSlot {
  const ClassSlot({required this.time, required this.subject, required this.emoji, required this.color, required this.teacher});
  final String time;
  final String subject;
  final String emoji;
  final Color color;
  final String teacher;
}
