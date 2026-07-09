import 'package:flutter/material.dart';
import '../shared/app_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../providers/admin_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/repository_providers.dart';

class StudentProgressDetailScreen extends ConsumerWidget {
  final String studentId;
  const StudentProgressDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userRepositoryProvider).getUserById(studentId);
    final progressAsync = ref.watch(subjectProgressForStudentProvider(studentId));

    return Scaffold(
      drawer: const AppDrawer(role: UserRole.admin),
      appBar: AppBar(
        title: const Text('Student Progress'),
        actions: [
          IconButton(
            tooltip: 'Parent report',
            icon: const Icon(Icons.summarize_rounded),
            onPressed: () =>
                context.push('/admin/parent-report/$studentId'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: userAsync,
        builder: (context, snapshot) {
          final student = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (student != null) ...[
                Text(student.name,
                    style:
                        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(student.grade?.label ?? '—',
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 20),
              ],
              progressAsync.when(
                data: (rows) => Column(
                  children: rows.map((p) {
                    final color = p.attemptCount == 0
                        ? Colors.grey
                        : p.isLagging
                            ? Colors.redAccent
                            : Colors.green;
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.circle, color: color, size: 14),
                        title: Text(p.subject.label),
                        subtitle: p.attemptCount == 0
                            ? const Text('No quizzes attempted yet')
                            : Text(
                                '${p.averagePercentage.toStringAsFixed(0)}% avg over ${p.attemptCount} quiz${p.attemptCount == 1 ? '' : 'zes'}'),
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          );
        },
      ),
    );
  }
}
