import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/grade_themes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/platform_providers.dart';
import '../../shared/widgets/grade_scaffold.dart';
import '../../shared/widgets/ui.dart';

/// A quick "Rapid Recall" quiz game. A question flashes with four options and
/// a shrinking timer; correct + fast answers score more. Final score is saved
/// to the grade leaderboard as game points.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameQuestion {
  final String prompt;
  final List<String> options;
  final int answer;
  const _GameQuestion(this.prompt, this.options, this.answer);
}

class _GameScreenState extends ConsumerState<GameScreen> {
  static const _questionCount = 8;
  static const _perQuestion = Duration(seconds: 8);

  late List<_GameQuestion> _questions;
  int _index = 0;
  int _score = 0;
  int _streak = 0;
  int? _picked;
  bool _started = false;
  bool _finished = false;
  bool _saved = false;
  Timer? _timer;
  double _remaining = 1.0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _buildQuestions() {
    final rnd = Random();
    final qs = <_GameQuestion>[];
    for (var i = 0; i < _questionCount; i++) {
      final a = rnd.nextInt(12) + 2;
      final b = rnd.nextInt(12) + 2;
      final correct = a * b;
      final opts = <int>{correct};
      while (opts.length < 4) {
        final delta = rnd.nextInt(12) - 6;
        final candidate = correct + delta;
        if (candidate > 0) opts.add(candidate);
      }
      final shuffled = opts.toList()..shuffle(rnd);
      qs.add(_GameQuestion(
        'What is $a x $b ?',
        shuffled.map((e) => e.toString()).toList(),
        shuffled.indexOf(correct),
      ));
    }
    _questions = qs;
  }

  void _start() {
    _buildQuestions();
    setState(() {
      _started = true;
      _finished = false;
      _saved = false;
      _index = 0;
      _score = 0;
      _streak = 0;
      _picked = null;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remaining = 1.0;
    const tick = Duration(milliseconds: 50);
    _timer = Timer.periodic(tick, (t) {
      setState(() {
        _remaining -= tick.inMilliseconds / _perQuestion.inMilliseconds;
        if (_remaining <= 0) {
          _remaining = 0;
          _lockAnswer(null);
        }
      });
    });
  }

  void _lockAnswer(int? choice) {
    if (_picked != null) return;
    _timer?.cancel();
    final correct = choice != null && choice == _questions[_index].answer;
    setState(() {
      _picked = choice ?? -1;
      if (correct) {
        _streak++;
        _score += 10 + (_remaining * 10).round() + (_streak - 1) * 2;
      } else {
        _streak = 0;
      }
    });
    Future.delayed(const Duration(milliseconds: 850), _next);
  }

  void _next() {
    if (!mounted) return;
    if (_index + 1 >= _questions.length) {
      setState(() => _finished = true);
      _save();
    } else {
      setState(() {
        _index++;
        _picked = null;
      });
      _startTimer();
    }
  }

  Future<void> _save() async {
    if (_saved) return;
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;
    _saved = true;
    await ref.read(gameControllerProvider).recordScore('rapid_recall', _score);
    final grade = user.grade;
    if (grade != null) ref.invalidate(leaderboardProvider(grade));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;
    final grade = user?.grade ?? Grade.class6;
    final palette = GradePalette.of(grade);

    return GradeScaffold(
      gradeOverride: grade,
      title: 'Rapid Recall',
      subtitle: 'Beat the clock, climb the board',
      child: _finished
          ? _buildFinished(palette)
          : !_started
              ? _buildIntro(palette)
              : _buildPlaying(palette),
    );
  }

  Widget _buildIntro(GradePalette palette) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: 72, color: palette.primary),
          const SizedBox(height: 16),
          Text('Rapid Recall',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Answer 8 quick questions. Faster answers and streaks score more points. Your best run counts toward the leaderboard.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Start game',
            onPressed: _start,
            expand: false,
            gradient: palette.heroGradient,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaying(GradePalette palette) {
    final q = _questions[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question ${_index + 1}/${_questions.length}'),
            Text('Score $_score',
                style: TextStyle(
                    color: palette.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _remaining,
            minHeight: 8,
            backgroundColor: palette.primary.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(
                _remaining < 0.3 ? Colors.redAccent : palette.primary),
          ),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.primary.withValues(alpha: 0.2)),
          ),
          child: Center(
            child: Text(q.prompt,
                style: Theme.of(context).textTheme.headlineSmall),
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(q.options.length, (i) {
          Color? bg;
          if (_picked != null) {
            if (i == q.answer) {
              bg = Colors.green.withValues(alpha: 0.25);
            } else if (i == _picked) {
              bg = Colors.red.withValues(alpha: 0.25);
            }
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _picked == null ? () => _lockAnswer(i) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: bg ?? palette.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: palette.primary.withValues(alpha: 0.25)),
                ),
                child: Text(q.options[i],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          );
        }),
        if (_streak > 1)
          Center(
            child: Text('Streak x$_streak',
                style: TextStyle(
                    color: palette.primary, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildFinished(GradePalette palette) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: 72, color: palette.primary),
          const SizedBox(height: 16),
          Text('Game over!',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('You scored $_score points',
              style: TextStyle(
                  fontSize: 18,
                  color: palette.primary,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Play again',
            onPressed: _start,
            expand: false,
            gradient: palette.heroGradient,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
