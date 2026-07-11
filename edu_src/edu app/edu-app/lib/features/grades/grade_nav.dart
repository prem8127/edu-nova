import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Simple bottom nav shared by every grade-specific home screen.
/// "Home" is a no-op (you're already there); the rest jump into the
/// shared app-wide feature screens.
class GradeBottomNav extends StatelessWidget {
  const GradeBottomNav({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => NavigationBar(
        backgroundColor: Theme.of(context).cardTheme.color,
        indicatorColor: color.withValues(alpha: .16),
        selectedIndex: 0,
        onDestinationSelected: (i) => switch (i) {
          1 => context.go('/courses'),
          2 => context.go('/mentor'),
          3 => context.go('/profile'),
          _ => null,
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Courses'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_rounded), label: 'Mentor'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      );
}
