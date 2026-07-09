import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/grade_themes.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/grade_scaffold.dart';

/// Student — Recorded Videos library. Self-contained (local data) with a
/// searchable list and simulated play/progress.
class RecordedVideosScreen extends ConsumerStatefulWidget {
  const RecordedVideosScreen({super.key});

  @override
  ConsumerState<RecordedVideosScreen> createState() =>
      _RecordedVideosScreenState();
}

class _RecordedVideosScreenState extends ConsumerState<RecordedVideosScreen> {
  String _query = '';

  static const _videos = <_Video>[
    _Video('Fractions Made Easy', 'Mathematics', '12:40', .8),
    _Video('The Water Cycle', 'Science', '08:15', 1.0),
    _Video('Parts of Speech', 'English', '15:02', .3),
    _Video('Ancient Civilizations', 'History', '21:30', 0),
    _Video('Introduction to Coding', 'Computer Science', '18:45', .55),
    _Video('Maps & Directions', 'Geography', '10:20', 0),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;
    final palette = GradePalette.of(user?.grade);

    final filtered = _videos
        .where((v) =>
            v.title.toLowerCase().contains(_query.toLowerCase()) ||
            v.subject.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return GradeScaffold(
      title: 'Recorded Videos',
      subtitle: 'Watch anytime, revise anywhere',
      icon: Icons.smart_display_rounded,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search videos or subjects',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: palette.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) =>
                  _VideoCard(video: filtered[i], palette: palette),
            ),
          ),
        ],
      ),
    );
  }
}

class _Video {
  const _Video(this.title, this.subject, this.duration, this.progress);
  final String title;
  final String subject;
  final String duration;
  final double progress;
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.palette});
  final _Video video;
  final GradePalette palette;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playing "${video.title}"…'))),
      child: Container(
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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.play_arrow_rounded,
                  color: palette.primary, size: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video.title,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                          color: palette.onSurface)),
                  const SizedBox(height: 2),
                  Text('${video.subject} · ${video.duration}',
                      style: TextStyle(
                          color: palette.onSurfaceMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: video.progress,
                      minHeight: 5,
                      backgroundColor: palette.primary.withValues(alpha: .12),
                      valueColor:
                          AlwaysStoppedAnimation(palette.primary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.progress == 0
                        ? 'Not started'
                        : video.progress >= 1
                            ? 'Completed'
                            : '${(video.progress * 100).round()}% watched',
                    style: TextStyle(
                        color: palette.onSurfaceMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
