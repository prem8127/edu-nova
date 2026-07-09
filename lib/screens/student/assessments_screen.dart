import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/grade_themes.dart';
import '../../models/platform_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/platform_providers.dart';
import '../../shared/widgets/grade_scaffold.dart';

/// Lists every assessment available to the student's grade across the four
/// tracks, with their current status (coding / MCQ / calculation / writing).
class AssessmentsScreen extends ConsumerWidget {
  const AssessmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final palette = GradePalette.of(user?.grade);
    final grade = user?.grade;

    return GradeScaffold(
      title: 'Assessments',
      subtitle: 'Coding, quizzes, calculations & writing',
      icon: Icons.assignment_rounded,
      child: grade == null
          ? Center(
              child: Text('Sign in as a student to view assessments.',
                  style: TextStyle(color: palette.onSurfaceMuted)))
          : ref.watch(assessmentsForGradeProvider(grade)).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (assessments) {
                  final subs = ref.watch(mySubmissionsProvider).value ?? [];
                  if (assessments.isEmpty) {
                    return Center(
                        child: Text('No assessments published yet.',
                            style: TextStyle(color: palette.onSurfaceMuted)));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                    itemCount: assessments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final a = assessments[i];
                      AssessmentSubmission? sub;
                      for (final s in subs) {
                        if (s.assessmentId == a.id) {
                          sub = s;
                          break;
                        }
                      }
                      return _AssessmentTile(
                        assessment: a,
                        submission: sub,
                        palette: palette,
                        onTap: () => context.push(
                          AppRoutes.studentAssessment
                              .replaceFirst(':assessmentId', a.id),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}

class _AssessmentTile extends StatelessWidget {
  const _AssessmentTile({
    required this.assessment,
    required this.submission,
    required this.palette,
    required this.onTap,
  });

  final Assessment assessment;
  final AssessmentSubmission? submission;
  final GradePalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = submission?.status;
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
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
                  color: assessment.subject.color.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(assessment.type.icon,
                    color: assessment.subject.color, size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(assessment.title,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: palette.onSurface)),
                    const SizedBox(height: 4),
                    Text('${assessment.type.label} · ${assessment.points} pts',
                        style: TextStyle(
                            color: palette.onSurfaceMuted, fontSize: 12.5)),
                  ],
                ),
              ),
              if (status != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    submission?.finalScore != null
                        ? '${submission!.finalScore}%'
                        : status.label,
                    style: TextStyle(
                        color: status.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5),
                  ),
                )
              else
                Icon(Icons.chevron_right_rounded, color: palette.onSurfaceMuted),
            ],
          ),
        ),
      ),
    );
  }
}
