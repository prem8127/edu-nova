import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/grade_themes.dart';
import '../../models/platform_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/platform_providers.dart';
import '../../shared/widgets/grade_scaffold.dart';

/// Certificates + portfolio: shows every credential the student has earned
/// from approved projects and completed tracks.
class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final palette = GradePalette.of(user?.grade);
    final certs = ref.watch(myCertificatesProvider);
    final projects = ref.watch(myProjectSubmissionsProvider);

    return GradeScaffold(
      title: 'Certificates & Portfolio',
      subtitle: 'Your verified achievements',
      icon: Icons.workspace_premium_rounded,
      child: certs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => ListView(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
          children: [
            if (list.isEmpty)
              _empty(palette)
            else
              ...list.map((c) => _CertCard(cert: c, palette: palette)),
            const SizedBox(height: 18),
            Text('Portfolio projects',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: palette.onSurface)),
            const SizedBox(height: 10),
            projects.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (ps) {
                final approved =
                    ps.where((p) => p.status == SubmissionStatus.approved).toList();
                if (approved.isEmpty) {
                  return Text('Approved projects will appear here.',
                      style: TextStyle(color: palette.onSurfaceMuted));
                }
                return Column(
                  children: approved
                      .map((p) => _PortfolioCard(p: p, palette: palette))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(GradePalette palette) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.emoji_events_outlined,
                size: 56, color: palette.onSurfaceMuted),
            const SizedBox(height: 12),
            Text('No certificates yet',
                style: TextStyle(
                    color: palette.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 15)),
            const SizedBox(height: 4),
            Text('Complete projects & tracks to earn verifiable credentials.',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.onSurfaceMuted, fontSize: 12.5)),
          ],
        ),
      );
}

class _CertCard extends StatelessWidget {
  const _CertCard({required this.cert, required this.palette});
  final Certificate cert;
  final GradePalette palette;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: palette.heroGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_rounded, color: Colors.white, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(cert.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _kv('Subject', cert.subject.label),
                _kv('Score', '${cert.scorePercent}%'),
                _kv('Grade', cert.grade.label),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Credential ID: ${cert.credentialId}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

  Widget _kv(String k, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: .8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(v,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
        ],
      );
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({required this.p, required this.palette});
  final ProjectSubmission p;
  final GradePalette palette;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
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
            Icon(Icons.folder_special_rounded, color: palette.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: palette.onSurface,
                          fontSize: 14)),
                  if (p.link.isNotEmpty)
                    Text(p.link,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: palette.onSurfaceMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.check_circle_rounded,
                color: SubmissionStatus.approved.color, size: 20),
          ],
        ),
      );
}
