import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/grade_themes.dart';
import '../../shared/widgets/grade_scaffold.dart';

/// Teacher — Batches. Manage class batches: view rosters, next session and
/// add a new batch. Self-contained local state.
class BatchesScreen extends ConsumerStatefulWidget {
  const BatchesScreen({super.key});

  @override
  ConsumerState<BatchesScreen> createState() => _BatchesScreenState();
}

class _BatchesScreenState extends ConsumerState<BatchesScreen> {
  final _batches = <_Batch>[
    _Batch('Class 8 — Morning', 'Mathematics', 32, 'Mon/Wed/Fri · 9:00 AM'),
    _Batch('Class 10 — Evening', 'Science', 28, 'Tue/Thu · 5:00 PM'),
    _Batch('Intermediate 1 — Weekend', 'Physics', 21, 'Sat/Sun · 11:00 AM'),
  ];

  void _addBatch() {
    final nameC = TextEditingController();
    final subjectC = TextEditingController();
    final scheduleC = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New batch',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 14),
            TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Batch name')),
            const SizedBox(height: 10),
            TextField(
                controller: subjectC,
                decoration: const InputDecoration(labelText: 'Subject')),
            const SizedBox(height: 10),
            TextField(
                controller: scheduleC,
                decoration: const InputDecoration(labelText: 'Schedule')),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (nameC.text.trim().isEmpty) return;
                  setState(() => _batches.add(_Batch(
                        nameC.text.trim(),
                        subjectC.text.trim().isEmpty
                            ? 'General'
                            : subjectC.text.trim(),
                        0,
                        scheduleC.text.trim().isEmpty
                            ? 'To be scheduled'
                            : scheduleC.text.trim(),
                      )));
                  Navigator.pop(ctx);
                },
                child: const Text('Create batch'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = GradePalette.of(null);

    return GradeScaffold(
      title: 'Batches',
      subtitle: '${_batches.length} active batches',
      icon: Icons.groups_rounded,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addBatch,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New batch'),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 90),
        itemCount: _batches.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final b = _batches[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: palette.isDark
                    ? Colors.white.withValues(alpha: .06)
                    : Colors.black.withValues(alpha: .05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: palette.primary.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.class_rounded, color: palette.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: palette.onSurface)),
                          const SizedBox(height: 2),
                          Text(b.subject,
                              style: TextStyle(
                                  color: palette.onSurfaceMuted,
                                  fontSize: 12.5)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${b.students}',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: palette.primary)),
                        Text('students',
                            style: TextStyle(
                                color: palette.onSurfaceMuted, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 15, color: palette.onSurfaceMuted),
                    const SizedBox(width: 6),
                    Text(b.schedule,
                        style: TextStyle(
                            color: palette.onSurfaceMuted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(
                              content: Text('Opening roster for ${b.name}'))),
                      child: const Text('View roster'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Batch {
  _Batch(this.name, this.subject, this.students, this.schedule);
  final String name;
  final String subject;
  final int students;
  final String schedule;
}
