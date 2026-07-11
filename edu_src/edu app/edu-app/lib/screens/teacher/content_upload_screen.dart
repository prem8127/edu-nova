import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/grade_themes.dart';
import '../../shared/widgets/grade_scaffold.dart';

/// Teacher — Content Upload. Publish videos, notes and assignments to a batch.
/// Self-contained local state (uploaded items kept in memory).
class ContentUploadScreen extends ConsumerStatefulWidget {
  const ContentUploadScreen({super.key});

  @override
  ConsumerState<ContentUploadScreen> createState() =>
      _ContentUploadScreenState();
}

class _ContentUploadScreenState extends ConsumerState<ContentUploadScreen> {
  final _titleC = TextEditingController();
  final _subjectC = TextEditingController();
  _ContentType _type = _ContentType.video;

  final _uploaded = <_Content>[
    _Content('The Water Cycle', 'Science', _ContentType.video),
    _Content('Algebra Formula Sheet', 'Mathematics', _ContentType.notes),
  ];

  @override
  void dispose() {
    _titleC.dispose();
    _subjectC.dispose();
    super.dispose();
  }

  void _publish() {
    if (_titleC.text.trim().isEmpty) return;
    setState(() {
      _uploaded.insert(
          0,
          _Content(
            _titleC.text.trim(),
            _subjectC.text.trim().isEmpty ? 'General' : _subjectC.text.trim(),
            _type,
          ));
      _titleC.clear();
      _subjectC.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content published to your batch')));
  }

  @override
  Widget build(BuildContext context) {
    final palette = GradePalette.of(null);

    return GradeScaffold(
      title: 'Content Upload',
      subtitle: 'Publish videos, notes & assignments',
      icon: Icons.cloud_upload_rounded,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
        children: [
          Container(
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
                Text('New content',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: palette.onSurface)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _ContentType.values.map((t) {
                    final selected = t == _type;
                    return ChoiceChip(
                      selected: selected,
                      label: Text(t.label),
                      avatar: Icon(t.icon,
                          size: 16,
                          color: selected ? Colors.white : palette.primary),
                      selectedColor: palette.primary,
                      labelStyle: TextStyle(
                          color: selected ? Colors.white : palette.onSurface,
                          fontWeight: FontWeight.w700),
                      onSelected: (_) => setState(() => _type = t),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleC,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _subjectC,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File picker (demo)'))),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: palette.primary.withValues(alpha: .4),
                          style: BorderStyle.solid),
                      color: palette.primary.withValues(alpha: .06),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.upload_file_rounded,
                            color: palette.primary, size: 28),
                        const SizedBox(height: 6),
                        Text('Tap to choose a file',
                            style: TextStyle(
                                color: palette.onSurfaceMuted,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _publish,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Publish content'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Published',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: palette.onSurface)),
          const SizedBox(height: 10),
          ..._uploaded.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: palette.isDark
                          ? Colors.white.withValues(alpha: .06)
                          : Colors.black.withValues(alpha: .05),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(c.type.icon, color: palette.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: palette.onSurface)),
                            Text('${c.subject} · ${c.type.label}',
                                style: TextStyle(
                                    color: palette.onSurfaceMuted,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle_rounded,
                          color: const Color(0xFF22C55E), size: 20),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

enum _ContentType { video, notes, assignment }

extension on _ContentType {
  String get label => switch (this) {
        _ContentType.video => 'Video',
        _ContentType.notes => 'Notes',
        _ContentType.assignment => 'Assignment',
      };
  IconData get icon => switch (this) {
        _ContentType.video => Icons.smart_display_rounded,
        _ContentType.notes => Icons.description_rounded,
        _ContentType.assignment => Icons.assignment_rounded,
      };
}
