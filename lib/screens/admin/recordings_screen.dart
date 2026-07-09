import 'package:flutter/material.dart';
import '../shared/app_drawer.dart';
import '../../core/constants/app_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/platform_models.dart';
import '../../providers/platform_providers.dart';
import '../../shared/widgets/ui.dart';

/// Super Admin recordings library. Recordings auto-expire 48h after class
/// unless flagged as a permanent "sample". Admin can toggle sample status
/// and delete recordings.
class RecordingsScreen extends ConsumerWidget {
  const RecordingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordings = ref.watch(allRecordingsProvider);

    return Scaffold(
      drawer: const AppDrawer(role: UserRole.admin),
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Recordings',
                subtitle: 'Auto-expire 48h after class · samples stay forever',
              ),
              Expanded(
                child: recordings.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (list) {
                    if (list.isEmpty) {
                      return const EmptyState(
                        icon: Icons.video_library_outlined,
                        title: 'No recordings',
                        body: 'Recordings appear here after live classes.',
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _RecordingCard(recording: list[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordingCard extends ConsumerWidget {
  const _RecordingCard({required this.recording});
  final Recording recording;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expired = !recording.isSample && recording.isExpired;
    final controller = ref.read(recordingControllerProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                expired ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                color: expired ? AppBrand.inkSoft : AppBrand.blue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(recording.title,
                    style: const TextStyle(
                        color: AppBrand.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ),
              if (recording.isSample)
                const StatusPill('Sample',
                    color: Color(0x3322C55E), foreground: AppBrand.green)
              else if (expired)
                const StatusPill('Expired',
                    color: Color(0x33EF4444), foreground: Color(0xFFEF4444))
              else
                const StatusPill('Available',
                    color: Color(0x333E7BFA), foreground: AppBrand.blue),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      controller.markAsSample(recording, !recording.isSample),
                  icon: Icon(
                    recording.isSample
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 18,
                  ),
                  label: Text(recording.isSample
                      ? 'Unmark sample'
                      : 'Mark as sample'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => controller.delete(recording),
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
