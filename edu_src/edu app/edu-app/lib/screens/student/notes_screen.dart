import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/grade_themes.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/grade_scaffold.dart';

/// Student — Notes. Downloadable study material per subject. Self-contained
/// with local demo data; download action is simulated.
class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  static const _notes = <_Note>[
    _Note('Algebra Formula Sheet', 'Mathematics', 'PDF · 1.2 MB'),
    _Note('Cell Structure Diagrams', 'Science', 'PDF · 2.8 MB'),
    _Note('Grammar Rules Summary', 'English', 'PDF · 640 KB'),
    _Note('Timeline of Freedom Struggle', 'History', 'PDF · 1.9 MB'),
    _Note('Python Cheat Sheet', 'Computer Science', 'PDF · 820 KB'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final palette = GradePalette.of(user?.grade);

    return GradeScaffold(
      title: 'Notes',
      subtitle: 'Study material & downloads',
      icon: Icons.menu_book_rounded,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
        itemCount: _notes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final n = _notes[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: palette.isDark
                    ? Colors.white.withValues(alpha: .06)
                    : Colors.black.withValues(alpha: .05),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.description_rounded,
                      color: palette.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title,
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14.5,
                              color: palette.onSurface)),
                      const SizedBox(height: 2),
                      Text('${n.subject} · ${n.meta}',
                          style: TextStyle(
                              color: palette.onSurfaceMuted, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloading "${n.title}"…'))),
                  icon: Icon(Icons.download_rounded, color: palette.primary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Note {
  const _Note(this.title, this.subject, this.meta);
  final String title;
  final String subject;
  final String meta;
}
