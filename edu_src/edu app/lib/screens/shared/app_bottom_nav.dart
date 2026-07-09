import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

/// Student bottom nav. currentIndex is passed in explicitly by each screen
/// rather than derived from GoRouterState here, since this is a stateless
/// helper — screens should derive it from GoRouterState.of(context).uri
/// the same way Precision Parts does, so the selected tab always matches
/// the URL instead of a manually-tracked provider.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go(AppRoutes.studentDashboard);
            break;
          case 1:
            context.go(AppRoutes.studentCourses);
            break;
          case 2:
            context.go(AppRoutes.studentCalendar);
            break;
          case 3:
            context.go(AppRoutes.studentDoubtChat);
            break;
          case 4:
            context.go(AppRoutes.studentProfile);
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book_rounded),
          label: 'My Courses',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month_rounded),
          label: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(Icons.forum_outlined),
          selectedIcon: Icon(Icons.forum_rounded),
          label: 'Doubts',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
