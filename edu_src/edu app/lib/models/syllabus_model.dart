import '../core/constants/app_enums.dart';

/// A single teaching unit inside a class's curriculum, e.g. "Money Basics"
/// for Class 6, with the list of topics it covers.
class SyllabusModule {
  const SyllabusModule({required this.title, required this.topics});

  final String title;
  final List<String> topics;
}

/// The full curriculum for one grade (Class 6–10), mirroring the Aditya
/// Globals prototype's `syllabusData` entries: a stage name, its teaching
/// modules (each with topics), and the hands-on stage projects for that
/// class.
class SyllabusClassPlan {
  const SyllabusClassPlan({
    required this.grade,
    required this.className,
    required this.stageLabel,
    required this.modules,
    required this.projects,
  });

  final Grade grade;

  /// e.g. "Class 9"
  final String className;

  /// e.g. "Stage 4 — Business Creation"
  final String stageLabel;
  final List<SyllabusModule> modules;
  final List<String> projects;

  /// e.g. "Business Creation" — the stage label without the "Stage N — "
  /// prefix, used in headers/banners.
  String get stageName {
    final i = stageLabel.indexOf('—');
    return i == -1 ? stageLabel : stageLabel.substring(i + 1).trim();
  }

  int get topicCount =>
      modules.fold(0, (sum, m) => sum + m.topics.length);
}
