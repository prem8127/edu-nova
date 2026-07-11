import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/syllabus_provider.dart';
import '../../shared/widgets/grade_scaffold.dart';
import '../../shared/widgets/syllabus_widgets.dart';

/// Full Class 6–10 roadmap for teachers to plan lessons by class, switched
/// via a row of class tabs. Mirrors the prototype's `teacherSyllabus()`.
class TeacherSyllabusScreen extends ConsumerStatefulWidget {
  const TeacherSyllabusScreen({super.key});

  @override
  ConsumerState<TeacherSyllabusScreen> createState() => _TeacherSyllabusScreenState();
}

class _TeacherSyllabusScreenState extends ConsumerState<TeacherSyllabusScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final syllabusAsync = ref.watch(syllabusDataProvider);
    final booksAsync = ref.watch(essentialBooksProvider);

    return GradeScaffold(
      title: 'Syllabus',
      subtitle: 'Full Class 6–10 entrepreneur roadmap — plan lessons by class',
      icon: Icons.menu_book_rounded,
      child: syllabusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (classes) {
          if (classes.isEmpty) {
            return const Center(child: Text('Syllabus content coming soon.'));
          }
          final safeIndex = _selected.clamp(0, classes.length - 1).toInt();
          final selected = classes[safeIndex];
          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
            children: [
              ClassFilterBar(
                labels: classes.map((c) => c.className).toList(),
                selectedIndex: _selected,
                onSelected: (i) => setState(() => _selected = i),
              ),
              const SizedBox(height: 16),
              ...selected.modules.map((m) => ModuleAccordionCard(module: m)),
              StageProjectsCard(projects: selected.projects),
              booksAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (books) => EssentialBooksCard(books: books),
              ),
            ],
          );
        },
      ),
    );
  }
}
