import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/grade_themes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/platform_providers.dart';
import '../../shared/widgets/grade_scaffold.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = GradePalette.of(ref.watch(authControllerProvider).value?.grade);
    final attendance = ref.watch(myAttendanceProvider);

    return GradeScaffold(
      title: 'My Attendance',
      subtitle: 'Live class attendance record',
      icon: Icons.fact_check_rounded,
      child: attendance.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (records) {
          final total = records.length;
          final present =
              records.where((r) => r.status == AttendanceStatus.present).length;
          final late = records.where((r) => r.status == AttendanceStatus.late).length;
          final pct = total == 0 ? 0 : (((present + late) / total) * 100).round();

          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: palette.heroGradient,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$pct%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w900)),
                        const Text('Overall attendance',
                            style: TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.calendar_month_rounded,
                        color: Colors.white.withValues(alpha: .6), size: 54),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: GradeStatCard(
                          label: 'Present',
                          value: '$present',
                          icon: Icons.check_circle_rounded,
                          palette: palette)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: GradeStatCard(
                          label: 'Late',
                          value: '$late',
                          icon: Icons.timelapse_rounded,
                          palette: palette)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: GradeStatCard(
                          label: 'Total',
                          value: '$total',
                          icon: Icons.event_rounded,
                          palette: palette)),
                ],
              ),
              const SizedBox(height: 18),
              Text('History',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: palette.onSurface)),
              const SizedBox(height: 10),
              if (records.isEmpty)
                Text('No classes recorded yet.',
                    style: TextStyle(color: palette.onSurfaceMuted))
              else
                ...records.map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.videocam_rounded, color: palette.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Class ${r.classId}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: palette.onSurface)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: r.status.color.withValues(alpha: .16),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(r.status.label,
                                style: TextStyle(
                                    color: r.status.color,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}
