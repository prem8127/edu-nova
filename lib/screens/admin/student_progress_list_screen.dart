import 'package:flutter/material.dart';
import '../shared/app_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../providers/admin_provider.dart';

class StudentProgressListScreen extends ConsumerWidget {
  const StudentProgressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(allStudentProgressProvider);
    return Scaffold(
      drawer: const AppDrawer(role: UserRole.admin),
      appBar: AppBar(title: const Text('Student Progress')),
      body: summariesAsync.when(
        data: (summaries) {
          if (summaries.isEmpty) {
            return const Center(child: Text('No students yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: summaries.length,
            itemBuilder: (context, i) {
              final s = summaries[i];
              final laggingCount = s.laggingSubjects.length;
              return Card(
                child: ListTile(
                  title: Text(s.student.name),
                  subtitle: Text(s.student.grade?.label ?? '—'),
                  trailing: laggingCount == 0
                      ? const Chip(
                          label: Text('On track'),
                          backgroundColor: Color(0xFFE6F4EA),
                        )
                      : Chip(
                          label: Text('$laggingCount lagging'),
                          backgroundColor: const Color(0xFFFDEBEC),
                        ),
                  onTap: () =>
                      context.push('/admin/students/${s.student.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
