import 'package:flutter/material.dart';
import '../shared/app_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';

class AssignedCoursesScreen extends ConsumerWidget {
  const AssignedCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return const SizedBox.shrink();
    final coursesAsync = ref.watch(coursesForTeacherProvider(user.id));

    return Scaffold(
      drawer: const AppDrawer(role: UserRole.teacher),
      appBar: AppBar(title: const Text('My Courses')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: user.assignedSubjects
                  .map((s) => Chip(label: Text(s.label)))
                  .toList(),
            ),
          ),
          Expanded(
            child: coursesAsync.when(
              data: (courses) => courses.isEmpty
                  ? const Center(child: Text('No courses assigned yet.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: courses.length,
                      itemBuilder: (context, i) {
                        final c = courses[i];
                        return Card(
                          child: ListTile(
                            title: Text(c.title),
                            subtitle: Text('${c.subject.label} · ${c.grade.label}'),
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
