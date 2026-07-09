import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/platform_providers.dart';
import '../../shared/widgets/ui.dart';

/// A read-only progress report a parent (or admin) can view for a student:
/// attendance, assignments and certificates in one glance.
class ParentReportScreen extends ConsumerWidget {
  const ParentReportScreen({super.key, required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(parentReportProvider(studentId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: report.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (r) => ListView(
              children: [
                PageHeader(
                  title: r.studentName,
                  subtitle: 'Progress report',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.event_available_rounded,
                              color: AppBrand.green,
                              value: '${r.attendancePercent}%',
                              label: 'Attendance',
                              sub: '${r.classesAttended}/${r.classesTotal} classes',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.assignment_turned_in_rounded,
                              color: AppBrand.blue,
                              value: '${r.assignmentsApproved}',
                              label: 'Approved',
                              sub: 'of ${r.assignmentsSubmitted} submitted',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.workspace_premium_rounded,
                              color: AppBrand.amber,
                              value: '${r.certificatesEarned}',
                              label: 'Certificates',
                              sub: 'earned',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.trending_up_rounded,
                              color: AppBrand.purple,
                              value: r.averageScore.toStringAsFixed(0),
                              label: 'Avg score',
                              sub: 'across graded work',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GlassCard(
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: AppBrand.inkSoft, size: 20),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'This report is generated from live attendance, '
                                'assignment reviews and certificates.',
                                style: TextStyle(
                                    color: AppBrand.inkSoft, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.sub,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: AppBrand.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 22)),
          Text(label,
              style: const TextStyle(
                  color: AppBrand.ink, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(sub,
              style: const TextStyle(color: AppBrand.inkSoft, fontSize: 11.5)),
        ],
      ),
    );
  }
}
