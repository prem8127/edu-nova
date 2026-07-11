import 'package:flutter/material.dart';
import '../shared/app_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/app_theme.dart';
import '../../models/platform_models.dart';
import '../../providers/platform_providers.dart';
import '../../providers/repository_providers.dart';
import '../../shared/widgets/ui.dart';

/// Teacher review queue. Two tabs: student mini-project submissions and
/// writing-assessment submissions that need a human grade. Both show the AI
/// pre-check verdict, then let the teacher approve or send back — and both
/// notify the student.
class ReviewQueueScreen extends ConsumerWidget {
  const ReviewQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: const AppDrawer(role: UserRole.teacher),
        body: AppGradientBackground(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'Grading queue',
                  subtitle: 'Submissions awaiting your review',
                ),
                const TabBar(
                  labelColor: AppBrand.ink,
                  unselectedLabelColor: AppBrand.inkSoft,
                  indicatorColor: AppBrand.purple,
                  tabs: [
                    Tab(text: 'Projects'),
                    Tab(text: 'Writing'),
                  ],
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      _ProjectQueue(),
                      _WritingQueue(),
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

class _ProjectQueue extends ConsumerWidget {
  const _ProjectQueue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(projectReviewQueueProvider);
    final names = ref.watch(userNameMapProvider).value ?? const {};
    return queue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.inbox_rounded,
            title: 'All caught up',
            body: 'There are no project submissions waiting for review.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _SubmissionCard(
            submission: items[i],
            studentName: names[items[i].studentId] ?? 'Student',
          ),
        );
      },
    );
  }
}

class _WritingQueue extends ConsumerWidget {
  const _WritingQueue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(writingReviewQueueProvider);
    final names = ref.watch(userNameMapProvider).value ?? const {};
    return queue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.edit_note_rounded,
            title: 'Nothing to grade',
            body: 'There are no writing submissions waiting for a grade.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _WritingCard(
            submission: items[i],
            studentName: names[items[i].studentId] ?? 'Student',
          ),
        );
      },
    );
  }
}

class _SubmissionCard extends ConsumerWidget {
  const _SubmissionCard({required this.submission, required this.studentName});
  final ProjectSubmission submission;
  final String studentName;

  Future<void> _review(BuildContext context, WidgetRef ref, bool approved) async {
    final feedback = await showDialog<String>(
      context: context,
      builder: (_) => _FeedbackDialog(approved: approved),
    );
    if (feedback == null) return;

    final repo = ref.read(platformRepositoryProvider);
    final project = await repo.getProjectById(submission.projectId);
    await ref.read(projectControllerProvider.notifier).review(
          submission: submission,
          approved: approved,
          feedback: feedback,
          subject: project?.subject,
          grade: project?.grade,
          studentName: studentName,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approved ? 'Approved — certificate issued' : 'Sent back for revision')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flagged = submission.status == SubmissionStatus.aiFlagged;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(submission.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: AppBrand.ink, fontSize: 15)),
              ),
              StatusPill(
                submission.status.label,
                color: submission.status.color.withValues(alpha: .18),
                foreground: submission.status.color,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('by $studentName',
              style: const TextStyle(color: AppBrand.inkSoft, fontSize: 12.5)),
          const SizedBox(height: 12),
          Text(submission.description,
              style: const TextStyle(color: AppBrand.ink, height: 1.45, fontSize: 13.5)),
          if (submission.link.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.link_rounded, size: 15, color: AppBrand.blue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(submission.link,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppBrand.blue, fontSize: 12.5)),
              ),
            ]),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (flagged ? AppBrand.amber : AppBrand.purple).withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(flagged ? Icons.flag_rounded : Icons.auto_awesome_rounded,
                    size: 16, color: flagged ? AppBrand.amber : AppBrand.purple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('AI pre-check: ${submission.aiPrecheck}',
                      style: const TextStyle(color: AppBrand.ink, fontSize: 12.5, height: 1.4)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _review(context, ref, false),
                  child: const Text('Needs work'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  label: 'Approve',
                  onPressed: () => _review(context, ref, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WritingCard extends ConsumerWidget {
  const _WritingCard({required this.submission, required this.studentName});
  final AssessmentSubmission submission;
  final String studentName;

  Future<void> _grade(BuildContext context, WidgetRef ref, bool approved) async {
    final result = await showDialog<({int score, String feedback})>(
      context: context,
      builder: (_) => _GradeDialog(approved: approved),
    );
    if (result == null) return;
    await ref.read(assessmentControllerProvider.notifier).teacherReview(
          submission: submission,
          score: result.score,
          feedback: result.feedback,
          approved: approved,
        );
    ref.invalidate(writingReviewQueueProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approved ? 'Graded ${result.score}%' : 'Sent back for revision')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flagged = submission.status == SubmissionStatus.aiFlagged;
    final words = submission.content.trim().isEmpty
        ? 0
        : submission.content.trim().split(RegExp(r'\s+')).length;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Writing task by $studentName',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: AppBrand.ink, fontSize: 15)),
              ),
              StatusPill(
                submission.status.label,
                color: submission.status.color.withValues(alpha: .18),
                foreground: submission.status.color,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('$words words',
              style: const TextStyle(color: AppBrand.inkSoft, fontSize: 12.5)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppBrand.ink.withValues(alpha: .04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              submission.content.isEmpty ? '(No text submitted)' : submission.content,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppBrand.ink, height: 1.5, fontSize: 13.5),
            ),
          ),
          if (submission.aiFeedback.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (flagged ? AppBrand.amber : AppBrand.purple).withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(flagged ? Icons.flag_rounded : Icons.auto_awesome_rounded,
                      size: 16, color: flagged ? AppBrand.amber : AppBrand.purple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('AI pre-check: ${submission.aiFeedback}',
                        style: const TextStyle(color: AppBrand.ink, fontSize: 12.5, height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _grade(context, ref, false),
                  child: const Text('Needs work'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  label: 'Grade & approve',
                  onPressed: () => _grade(context, ref, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dialog that collects a 0-100 score plus written feedback for a writing
/// submission.
class _GradeDialog extends StatefulWidget {
  const _GradeDialog({required this.approved});
  final bool approved;

  @override
  State<_GradeDialog> createState() => _GradeDialogState();
}

class _GradeDialogState extends State<_GradeDialog> {
  final _feedback = TextEditingController();
  double _score = 80;

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppBrand.card,
      title: Text(widget.approved ? 'Grade & approve' : 'Request changes'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Score: ${_score.round()}%',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppBrand.ink)),
          Slider(
            value: _score,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${_score.round()}%',
            activeColor: AppBrand.purple,
            onChanged: (v) => setState(() => _score = v),
          ),
          TextField(
            controller: _feedback,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Feedback for the student'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            (
              score: _score.round(),
              feedback: _feedback.text.trim().isEmpty
                  ? (widget.approved ? 'Great work!' : 'Please revise and resubmit.')
                  : _feedback.text.trim(),
            ),
          ),
          child: Text(widget.approved ? 'Approve' : 'Send back'),
        ),
      ],
    );
  }
}

class _FeedbackDialog extends StatefulWidget {
  const _FeedbackDialog({required this.approved});
  final bool approved;

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppBrand.card,
      title: Text(widget.approved ? 'Approve submission' : 'Request changes'),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Feedback for the student',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            _controller.text.trim().isEmpty
                ? (widget.approved ? 'Great work!' : 'Please revise and resubmit.')
                : _controller.text.trim(),
          ),
          child: Text(widget.approved ? 'Approve' : 'Send back'),
        ),
      ],
    );
  }
}
