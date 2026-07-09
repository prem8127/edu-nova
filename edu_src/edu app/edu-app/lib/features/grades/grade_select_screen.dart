import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/grade.dart';

class GradeSelectScreen extends StatelessWidget {
  const GradeSelectScreen({super.key});

  static const _cardColors = [
    Color(0xFF2F80ED),
    Color(0xFF1FA2A8),
    Color(0xFF5B6BF5),
    Color(0xFF1B2A4A),
    Color(0xFF15181D),
    Color(0xFF14151A),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF7F7FA),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
            children: [
              Text('Which class are you in?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('We’ll tailor the whole app to fit you.', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 26),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: .95,
                children: [
                  for (var i = 0; i < StudentGrade.values.length; i++)
                    _GradeCard(grade: StudentGrade.values[i], color: _cardColors[i]),
                ],
              ),
            ],
          ),
        ),
      );
}

class _GradeCard extends StatelessWidget {
  const _GradeCard({required this.grade, required this.color});
  final StudentGrade grade;
  final Color color;

  @override
  Widget build(BuildContext context) => Material(
        color: color,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.go('/class/${grade.routeKey}'),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(grade.icon, color: Colors.white, size: 30),
                const Spacer(),
                Text(grade.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 4),
                Text(grade.ageRange, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(grade.tagline, style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ),
      );
}
