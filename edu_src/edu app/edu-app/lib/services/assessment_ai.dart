import '../core/constants/app_enums.dart';
import '../models/platform_models.dart';
import '../models/quiz_model.dart';

/// ── EduNova in-house assessment engine ──────────────────────────────────
/// Deterministic, on-device grading + "AI" pre-checks. No external service:
/// coding/calculation/MCQ are auto-graded, while code and writing get a
/// heuristic pre-check summary that flags likely issues *before* a teacher
/// reviews them (the "AI pre-check on submissions" requirement).
/// ------------------------------------------------------------------------

class GradeResult {
  final int score; // 0-100
  final SubmissionStatus status;
  final String feedback;
  const GradeResult(this.score, this.status, this.feedback);
}

class AssessmentGrader {
  AssessmentGrader._();

  /// Auto-grade a coding submission by naively checking that the code
  /// references the tokens each test case expects in its output, plus basic
  /// structural signals. This is a stand-in for a real code runner but gives
  /// a stable, explainable score.
  static GradeResult gradeCoding(Assessment a, String code) {
    if (code.trim().isEmpty) {
      return const GradeResult(0, SubmissionStatus.needsWork, 'No code submitted.');
    }
    final lower = code.toLowerCase();
    var passed = 0;
    for (final tc in a.testCases) {
      final expect = tc.expectedOutput.toLowerCase().trim();
      if (expect.isEmpty) continue;
      if (lower.contains(expect) || _looksHandled(lower, tc.input)) passed++;
    }
    final total = a.testCases.isEmpty ? 1 : a.testCases.length;
    final ratio = passed / total;
    final hasStructure = lower.contains('def ') ||
        lower.contains('function') ||
        lower.contains('return') ||
        lower.contains('print') ||
        lower.contains('for') ||
        lower.contains('while');
    var score = (ratio * 80 + (hasStructure ? 20 : 0)).round().clamp(0, 100);
    final status = score >= 60 ? SubmissionStatus.approved : SubmissionStatus.needsWork;
    return GradeResult(
      score,
      status,
      '$passed/$total sample checks matched. '
      '${hasStructure ? 'Code structure looks complete.' : 'Add functions/loops to complete the solution.'}',
    );
  }

  static bool _looksHandled(String code, String input) {
    final tokens = input.split(RegExp(r'[\s,]+')).where((t) => t.length > 1);
    return tokens.isNotEmpty && tokens.every((t) => code.contains(t.toLowerCase()));
  }

  /// Numeric calculation grading with a tolerance window.
  static GradeResult gradeCalculation(Assessment a, double answer) {
    final expected = a.expectedAnswer ?? 0;
    final diff = (answer - expected).abs();
    if (diff <= a.tolerance) {
      return const GradeResult(100, SubmissionStatus.approved, 'Correct — exact within tolerance.');
    }
    final relative = expected == 0 ? diff : diff / expected.abs();
    if (relative <= 0.05) {
      return const GradeResult(70, SubmissionStatus.approved, 'Very close — minor rounding difference.');
    }
    return GradeResult(
      0,
      SubmissionStatus.needsWork,
      'Expected ${expected.toStringAsFixed(2)}${a.unit.isNotEmpty ? ' ${a.unit}' : ''}. Re-check your working.',
    );
  }

  /// MCQ grading (single correct option).
  static GradeResult gradeMcq(Assessment a, int selected) {
    final correct = selected == a.correctOptionIndex;
    return GradeResult(
      correct ? 100 : 0,
      correct ? SubmissionStatus.approved : SubmissionStatus.needsWork,
      correct ? 'Correct answer.' : 'Incorrect — review the concept and try again.',
    );
  }
}

class AiPrecheck {
  AiPrecheck._();

  /// Heuristic AI pre-check for code submissions (mini-projects). Returns a
  /// short summary and whether it should be flagged for closer review.
  static ({String summary, bool flagged}) reviewCode(String code) {
    final notes = <String>[];
    var flagged = false;
    final lower = code.toLowerCase();

    if (code.trim().length < 40) {
      notes.add('Submission is very short — may be incomplete.');
      flagged = true;
    }
    if (!lower.contains('def ') && !lower.contains('function') && !lower.contains('class ')) {
      notes.add('No functions/classes detected — consider structuring the code.');
    }
    if (lower.contains('todo') || lower.contains('fixme')) {
      notes.add('Contains TODO/FIXME markers.');
      flagged = true;
    }
    final comments = RegExp(r'(#|//)').allMatches(code).length;
    if (comments == 0) notes.add('No comments — add a few to explain intent.');
    if (RegExp(r'password\s*=\s*["\x27]').hasMatch(lower)) {
      notes.add('Possible hard-coded credential detected.');
      flagged = true;
    }
    if (notes.isEmpty) notes.add('No obvious issues found. Ready for teacher review.');

    return (
      summary: '${flagged ? 'Needs attention' : 'Looks OK'} · ${notes.join(' ')}',
      flagged: flagged,
    );
  }

  /// Heuristic AI pre-check for writing/story submissions.
  static ({String summary, bool flagged}) reviewWriting(String text, int minWords) {
    final words = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    final sentences = text.split(RegExp(r'[.!?]')).where((s) => s.trim().isNotEmpty).length;
    final notes = <String>[];
    var flagged = false;

    if (words < minWords) {
      notes.add('Under the $minWords-word minimum ($words words).');
      flagged = true;
    } else {
      notes.add('$words words.');
    }
    if (sentences > 0) {
      final avg = words / sentences;
      if (avg > 30) notes.add('Long average sentence length — consider shorter sentences.');
    }
    if (RegExp(r'(.)\1{4,}').hasMatch(text)) {
      notes.add('Repeated characters detected — possible filler.');
      flagged = true;
    }
    return (
      summary: '${flagged ? 'Needs attention' : 'Looks OK'} · ${notes.join(' ')}',
      flagged: flagged,
    );
  }
}

/// In-house AI quiz generator — assembles a checkpoint quiz for a tech topic
/// from a curated template bank, so teachers/students can spin up practice
/// quizzes on demand (the "AI-assisted IT/tech quiz generation" feature).
class AiQuizGenerator {
  AiQuizGenerator._();

  static const _bank = <Map<String, Object>>[
    {
      'q': 'What is the time complexity of binary search?',
      'options': ['O(n)', 'O(log n)', 'O(n^2)', 'O(1)'],
      'a': 1,
    },
    {
      'q': 'Which keyword defines a function in Python?',
      'options': ['func', 'def', 'function', 'fn'],
      'a': 1,
    },
    {
      'q': 'What does an "if" statement control?',
      'options': ['A loop', 'Conditional execution', 'A variable type', 'Memory'],
      'a': 1,
    },
    {
      'q': 'Which of these is a version-control tool?',
      'options': ['Docker', 'Git', 'NPM', 'Figma'],
      'a': 1,
    },
    {
      'q': 'What does API stand for?',
      'options': [
        'Application Programming Interface',
        'Applied Process Integration',
        'Automatic Program Input',
        'Advanced Peripheral Interface'
      ],
      'a': 0,
    },
    {
      'q': 'A list in Python is...',
      'options': ['Immutable', 'Ordered and mutable', 'Always sorted', 'Key-value pairs'],
      'a': 1,
    },
  ];

  static QuizModel generate({
    required String courseId,
    required String topic,
    int count = 4,
    int seed = 0,
  }) {
    final start = seed.abs() % _bank.length;
    final picked = <Map<String, Object>>[];
    for (var i = 0; i < count && i < _bank.length; i++) {
      picked.add(_bank[(start + i) % _bank.length]);
    }
    final id = 'ai_quiz_${courseId}_$seed';
    return QuizModel(
      id: id,
      courseId: courseId,
      title: 'AI Practice Quiz — $topic',
      questions: [
        for (var i = 0; i < picked.length; i++)
          QuizQuestion(
            id: '${id}_q$i',
            question: picked[i]['q'] as String,
            options: List<String>.from(picked[i]['options'] as List),
            correctOptionIndex: picked[i]['a'] as int,
          ),
      ],
    );
  }
}
