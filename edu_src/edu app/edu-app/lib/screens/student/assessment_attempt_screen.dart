import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/grade_themes.dart';
import '../../models/platform_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/platform_providers.dart';
import '../../shared/widgets/grade_scaffold.dart';

class AssessmentAttemptScreen extends ConsumerStatefulWidget {
  const AssessmentAttemptScreen({super.key, required this.assessmentId});
  final String assessmentId;

  @override
  ConsumerState<AssessmentAttemptScreen> createState() =>
      _AssessmentAttemptScreenState();
}

class _AssessmentAttemptScreenState
    extends ConsumerState<AssessmentAttemptScreen> {
  final _textController = TextEditingController();
  int? _selectedOption;
  final _numberController = TextEditingController();
  AssessmentSubmission? _result;
  bool _submitting = false;

  @override
  void dispose() {
    _textController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _submit(Assessment a) async {
    setState(() => _submitting = true);
    try {
      final sub = await ref.read(assessmentControllerProvider.notifier).submit(
            assessment: a,
            content: (a.type == AssessmentType.coding ||
                    a.type == AssessmentType.writing)
                ? _textController.text
                : '',
            selectedOption: _selectedOption,
            numericAnswer: double.tryParse(_numberController.text),
          );
      setState(() => _result = sub);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = GradePalette.of(ref.watch(authControllerProvider).value?.grade);
    final async = ref.watch(assessmentByIdProvider(widget.assessmentId));

    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (a) {
        if (a == null) {
          return const Scaffold(body: Center(child: Text('Assessment not found')));
        }
        return GradeScaffold(
          title: a.title,
          subtitle: a.type.label,
          icon: a.type.icon,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
            children: [
              _promptCard(a, palette),
              const SizedBox(height: 16),
              if (_result != null)
                _resultCard(_result!, palette)
              else ...[
                _inputForType(a, palette),
                const SizedBox(height: 20),
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : () => _submit(a),
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded),
                    label: Text(_submitting ? 'Grading…' : 'Submit for grading'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _promptCard(Assessment a, GradePalette palette) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(a.subject.icon, color: a.subject.color, size: 18),
                const SizedBox(width: 6),
                Text('${a.subject.label} · ${a.points} pts',
                    style: TextStyle(
                        color: palette.onSurfaceMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5)),
              ],
            ),
            const SizedBox(height: 10),
            Text(a.prompt,
                style: TextStyle(
                    color: palette.onSurface, height: 1.5, fontSize: 14.5)),
            if (a.type == AssessmentType.coding && a.testCases.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Sample cases',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: palette.onSurface,
                      fontSize: 13)),
              const SizedBox(height: 6),
              ...a.testCases.take(3).map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('in: ${t.input}  →  out: ${t.expectedOutput}',
                        style: TextStyle(
                            fontFamily: 'monospace',
                            color: palette.onSurfaceMuted,
                            fontSize: 12.5)),
                  )),
            ],
            if (a.type == AssessmentType.writing) ...[
              const SizedBox(height: 8),
              Text('Minimum ${a.minWords} words',
                  style: TextStyle(color: palette.onSurfaceMuted, fontSize: 12.5)),
            ],
          ],
        ),
      );

  Widget _inputForType(Assessment a, GradePalette palette) {
    switch (a.type) {
      case AssessmentType.coding:
        return TextField(
          controller: _textController,
          maxLines: 12,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13.5),
          inputFormatters: const [],
          decoration: InputDecoration(
            hintText: a.starterCode.isNotEmpty
                ? a.starterCode
                : '# Write your solution here',
            alignLabelWithHint: true,
          ),
        );
      case AssessmentType.writing:
        return TextField(
          controller: _textController,
          maxLines: 12,
          decoration: const InputDecoration(
            hintText: 'Write your response here…',
            alignLabelWithHint: true,
          ),
        );
      case AssessmentType.calculation:
        return TextField(
          controller: _numberController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
          ],
          decoration: InputDecoration(
            hintText: 'Your numeric answer',
            suffixText: a.unit.isNotEmpty ? a.unit : null,
          ),
        );
      case AssessmentType.mcq:
        return Column(
          children: [
            for (var i = 0; i < a.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: _selectedOption == i
                      ? palette.primary.withValues(alpha: .16)
                      : palette.surface,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _selectedOption = i),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedOption == i
                              ? palette.primary
                              : (palette.isDark
                                  ? Colors.white.withValues(alpha: .08)
                                  : Colors.black.withValues(alpha: .06)),
                          width: 1.4,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedOption == i
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: _selectedOption == i
                                ? palette.primary
                                : palette.onSurfaceMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(a.options[i],
                                style: TextStyle(
                                    color: palette.onSurface,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
    }
  }

  Widget _resultCard(AssessmentSubmission sub, GradePalette palette) {
    final autoGraded = sub.type.autoGraded;
    return Container(
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
              Icon(
                autoGraded ? Icons.grading_rounded : Icons.hourglass_top_rounded,
                color: Colors.white,
                size: 26,
              ),
              const SizedBox(width: 10),
              Text(
                autoGraded ? 'Result' : 'Submitted for review',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (autoGraded)
            Text('${sub.finalScore ?? 0}%',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(sub.aiFeedback,
                      style: const TextStyle(
                          color: Colors.white, height: 1.45, fontSize: 13.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
