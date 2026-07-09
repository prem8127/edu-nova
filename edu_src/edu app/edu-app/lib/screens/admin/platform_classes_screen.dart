import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/admin_provider.dart';

class PlatformClassesScreen extends ConsumerWidget {
  const PlatformClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowsAsync = ref.watch(allScheduledClassesOverviewProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('All Classes')),
      body: rowsAsync.when(
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(child: Text('No classes scheduled yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final r = rows[i];
              final c = r.scheduledClass;
              return Card(
                child: ListTile(
                  title: Text(c.title),
                  subtitle: Text(
                      '${r.courseTitle} · ${r.teacherName}\n${DateFormat('EEE, MMM d · h:mm a').format(c.dateTime)} (${c.durationMinutes} min)'),
                  isThreeLine: true,
                  trailing: c.hasEnded
                      ? const Text('Completed', style: TextStyle(color: Colors.black45))
                      : const Text('Upcoming', style: TextStyle(color: Colors.blue)),
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
