import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/grade_themes.dart';
import '../../models/platform_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/platform_providers.dart';
import '../../shared/widgets/grade_scaffold.dart';

class MiniProjectsScreen extends ConsumerWidget {
  const MiniProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final palette = GradePalette.of(user?.grade);
    final grade = user?.grade;

    return GradeScaffold(
      title: 'Mini-Projects',
      subtitle: 'Build, submit & get reviewed',
      icon: Icons.build_circle_rounded,
      child: grade == null
          ? Center(
              child: Text('Sign in as a student to view projects.',
                  style: TextStyle(color: palette.onSurfaceMuted)))
          : ref.watch(projectsForGradeProvider(grade)).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (projects) {
                  final mySubs = ref.watch(myProjectSubmissionsProvider).value ?? [];
                  if (projects.isEmpty) {
                    return Center(
                        child: Text('No projects published yet.',
                            style: TextStyle(color: palette.onSurfaceMuted)));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                    itemCount: projects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final p = projects[i];
                      ProjectSubmission? sub;
                      for (final s in mySubs) {
                        if (s.projectId == p.id) {
                          sub = s;
                          break;
                        }
                      }
                      return _ProjectCard(
                        project: p,
                        submission: sub,
                        palette: palette,
                        onSubmit: () => _openSubmitSheet(context, ref, p),
                      );
                    },
                  );
                },
              ),
    );
  }

  void _openSubmitSheet(BuildContext context, WidgetRef ref, MiniProject p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SubmitSheet(project: p),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.submission,
    required this.palette,
    required this.onSubmit,
  });

  final MiniProject project;
  final ProjectSubmission? submission;
  final GradePalette palette;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Container(
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
                Icon(project.subject.icon, color: project.subject.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(project.title,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5,
                          color: palette.onSurface)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(project.brief,
                style: TextStyle(
                    color: palette.onSurfaceMuted, height: 1.45, fontSize: 13)),
            if (project.deliverables.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...project.deliverables.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_rounded,
                            size: 15, color: palette.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(d,
                              style: TextStyle(
                                  color: palette.onSurface, fontSize: 12.5)),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 14),
            if (submission != null)
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: submission!.status.color.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: submission!.status.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${submission!.status.label}${submission!.teacherFeedback.isNotEmpty ? ' · ${submission!.teacherFeedback}' : ''}',
                        style: TextStyle(
                            color: submission!.status.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: const Text('Submit project'),
                ),
              ),
          ],
        ),
      );
}

class _SubmitSheet extends ConsumerStatefulWidget {
  const _SubmitSheet({required this.project});
  final MiniProject project;

  @override
  ConsumerState<_SubmitSheet> createState() => _SubmitSheetState();
}

class _SubmitSheetState extends ConsumerState<_SubmitSheet> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _link = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _title.text = widget.project.title;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _link.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_desc.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await ref.read(projectControllerProvider.notifier).submit(
            project: widget.project,
            title: _title.text.trim(),
            description: _desc.text.trim(),
            link: _link.text.trim(),
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Submitted! AI pre-check done, awaiting teacher review.')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Submit: ${widget.project.title}',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          TextField(
            controller: _desc,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Describe your work / paste code or notes',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _link,
            decoration: const InputDecoration(
              labelText: 'Repo / demo link (optional)',
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? 'Submitting…' : 'Run AI pre-check & submit'),
            ),
          ),
        ],
      ),
    );
  }
}
