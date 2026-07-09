import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/grade_themes.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/grade_scaffold.dart';

/// Student — Assignments. Track pending/submitted homework with a submit
/// action. Self-contained local state (submissions kept in memory).
class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  final _items = <_Assignment>[
    _Assignment('Algebra Worksheet 4', 'Mathematics', 'Due tomorrow', false),
    _Assignment('Lab Report: Acids & Bases', 'Science', 'Due in 3 days', false),
    _Assignment('Book Review — The Jungle Book', 'English', 'Submitted', true),
    _Assignment('History Map Activity', 'History', 'Due in 5 days', false),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;
    final palette = GradePalette.of(user?.grade);
    final pending = _items.where((a) => !a.submitted).length;

    return GradeScaffold(
      title: 'Assignments',
      subtitle: '$pending pending · ${_items.length - pending} submitted',
      icon: Icons.assignment_rounded,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final a = _items[i];
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
                    Expanded(
                      child: Text(a.title,
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: palette.onSurface)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: (a.submitted
                                ? const Color(0xFF22C55E)
                                : palette.secondary)
                            .withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(a.submitted ? 'Submitted' : a.due,
                          style: TextStyle(
                              color: a.submitted
                                  ? const Color(0xFF22C55E)
                                  : palette.secondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(a.subject,
                    style: TextStyle(
                        color: palette.onSurfaceMuted, fontSize: 12.5)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: a.submitted
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check_circle_rounded, size: 18),
                          label: const Text('Turned in'),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {
                            setState(() => a.submitted = true);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('Submitted "${a.title}"')));
                          },
                          icon: const Icon(Icons.upload_file_rounded, size: 18),
                          label: const Text('Submit assignment'),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Assignment {
  _Assignment(this.title, this.subject, this.due, this.submitted);
  final String title;
  final String subject;
  final String due;
  bool submitted;
}
