import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/grade_themes.dart';
import '../../shared/widgets/grade_scaffold.dart';

/// Teacher — Upload Content (formerly "Content Upload"). Publishes material
/// to a specific batch, organized into five categories: Notes, Homework,
/// Recordings, Announcements and Assignments. Self-contained local state
/// (uploaded items kept in memory), matching the rest of the demo-mode
/// teacher screens.
class UploadContentScreen extends ConsumerStatefulWidget {
  const UploadContentScreen({super.key});

  @override
  ConsumerState<UploadContentScreen> createState() => _UploadContentScreenState();
}

const _batches = [
  'Class 8 — Morning',
  'Class 10 — Evening',
  'Intermediate 1 — Weekend',
];

enum _Category { notes, homework, recordings, announcements, assignments }

extension on _Category {
  String get label => switch (this) {
        _Category.notes => 'Notes',
        _Category.homework => 'Homework',
        _Category.recordings => 'Recordings',
        _Category.announcements => 'Announcements',
        _Category.assignments => 'Assignments',
      };
  IconData get icon => switch (this) {
        _Category.notes => Icons.description_rounded,
        _Category.homework => Icons.edit_note_rounded,
        _Category.recordings => Icons.videocam_rounded,
        _Category.announcements => Icons.campaign_rounded,
        _Category.assignments => Icons.assignment_rounded,
      };
  String get fileHint => switch (this) {
        _Category.notes => 'Tap to attach a PDF or doc',
        _Category.homework => 'Tap to attach a worksheet',
        _Category.recordings => 'Tap to attach a video file',
        _Category.announcements => 'Attachment optional',
        _Category.assignments => 'Tap to attach the assignment brief',
      };
}

class _ContentItem {
  const _ContentItem(this.title, this.detail, this.timeAgo);
  final String title;
  final String detail;
  final String timeAgo;
}

class _UploadContentScreenState extends ConsumerState<UploadContentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: _Category.values.length, vsync: this);
  String _batch = _batches.first;
  final _titleC = TextEditingController();
  final _detailC = TextEditingController();

  // batch -> category -> published items. Pre-populated with realistic demo
  // content so the screen never opens empty.
  final Map<String, Map<_Category, List<_ContentItem>>> _content = {
    for (final b in _batches)
      b: {
        _Category.notes: [
          const _ContentItem('Chapter 4 — Formula Sheet', 'PDF · 2 pages', '2d ago'),
          const _ContentItem('Revision notes: Unit 3', 'PDF · 5 pages', '1w ago'),
        ],
        _Category.homework: [
          const _ContentItem('Worksheet 12 — Practice problems', 'Due in 3 days', '1d ago'),
        ],
        _Category.recordings: [
          const _ContentItem('Live class recording — Mon session', '48 min · HD', '3d ago'),
        ],
        _Category.announcements: [
          const _ContentItem('Test postponed to next Friday', 'Sent to all students', '6h ago'),
        ],
        _Category.assignments: [
          const _ContentItem('Project brief — Mini research task', 'Due in 1 week', '4d ago'),
        ],
      }
  };

  _Category get _category => _Category.values[_tabController.index];

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleC.dispose();
    _detailC.dispose();
    super.dispose();
  }

  void _publish() {
    if (_titleC.text.trim().isEmpty) return;
    setState(() {
      _content[_batch]![_category]!.insert(
        0,
        _ContentItem(
          _titleC.text.trim(),
          _detailC.text.trim().isEmpty ? 'Just now' : _detailC.text.trim(),
          'Just now',
        ),
      );
      _titleC.clear();
      _detailC.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_category.label.substring(0, _category.label.length - 1)} published to $_batch')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = GradePalette.of(null);
    final items = _content[_batch]![_category]!;

    return GradeScaffold(
      title: 'Upload Content',
      subtitle: 'Publish notes, homework & more — batch-wise',
      icon: Icons.cloud_upload_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Batch selector ----
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: palette.isDark ? Colors.white.withValues(alpha: .06) : Colors.black.withValues(alpha: .05),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _batch,
                  isExpanded: true,
                  icon: Icon(Icons.expand_more_rounded, color: palette.primary),
                  items: _batches
                      .map((b) => DropdownMenuItem(value: b, child: Text(b, style: TextStyle(fontWeight: FontWeight.w700, color: palette.onSurface))))
                      .toList(),
                  onChanged: (v) => setState(() => _batch = v!),
                ),
              ),
            ),
          ),
          // ---- Category tabs ----
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: palette.primary,
            unselectedLabelColor: palette.onSurfaceMuted,
            indicatorColor: palette.primary,
            tabs: _Category.values
                .map((c) => Tab(icon: Icon(c.icon, size: 18), text: c.label))
                .toList(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
              children: [
                _PublishForm(
                  category: _category,
                  batch: _batch,
                  palette: palette,
                  titleC: _titleC,
                  detailC: _detailC,
                  onPublish: _publish,
                ),
                const SizedBox(height: 20),
                Text('Published to $_batch',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: palette.onSurface)),
                const SizedBox(height: 10),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('Nothing published to this batch yet.',
                          style: TextStyle(color: palette.onSurfaceMuted)),
                    ),
                  )
                else
                  ...items.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: palette.isDark ? Colors.white.withValues(alpha: .06) : Colors.black.withValues(alpha: .05),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: palette.primary.withValues(alpha: .14),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(_category.icon, color: palette.primary, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.title, style: TextStyle(fontWeight: FontWeight.w800, color: palette.onSurface)),
                                    Text(c.detail, style: TextStyle(color: palette.onSurfaceMuted, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text(c.timeAgo, style: TextStyle(color: palette.onSurfaceMuted, fontSize: 11)),
                            ],
                          ),
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishForm extends StatelessWidget {
  const _PublishForm({
    required this.category,
    required this.batch,
    required this.palette,
    required this.titleC,
    required this.detailC,
    required this.onPublish,
  });

  final _Category category;
  final String batch;
  final GradePalette palette;
  final TextEditingController titleC;
  final TextEditingController detailC;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: palette.isDark ? Colors.white.withValues(alpha: .06) : Colors.black.withValues(alpha: .05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, color: palette.primary, size: 18),
              const SizedBox(width: 8),
              Text('New ${category.label.toLowerCase()}',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: palette.onSurface)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Publishing to $batch', style: TextStyle(color: palette.onSurfaceMuted, fontSize: 12)),
          const SizedBox(height: 12),
          TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 10),
          TextField(controller: detailC, decoration: const InputDecoration(labelText: 'Details (optional)')),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('File picker (demo)'))),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: palette.primary.withValues(alpha: .4)),
                color: palette.primary.withValues(alpha: .06),
              ),
              child: Column(
                children: [
                  Icon(Icons.upload_file_rounded, color: palette.primary, size: 26),
                  const SizedBox(height: 6),
                  Text(category.fileHint, style: TextStyle(color: palette.onSurfaceMuted, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPublish,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text('Publish ${category.label.toLowerCase()}'),
            ),
          ),
        ],
      ),
    );
  }
}
