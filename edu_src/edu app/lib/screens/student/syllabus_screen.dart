import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/grade_themes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/syllabus_provider.dart';
import '../../shared/widgets/grade_scaffold.dart';
import '../../shared/widgets/syllabus_widgets.dart';

/// Shows the signed-in student's own class roadmap: a "Your class" hero
/// banner, every module for that class as an accordion of topic pills, the
/// stage projects, and the essential-books block. Mirrors the prototype's
/// `studentSyllabus()`.
class StudentSyllabusScreen extends ConsumerWidget {
  const StudentSyllabusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final palette = GradePalette.of(user?.grade);
    final planAsync = ref.watch(currentStudentSyllabusProvider);
    final booksAsync = ref.watch(essentialBooksProvider);

    return planAsync.when(
      loading: () => GradeScaffold(
        title: 'Syllabus',
        icon: Icons.menu_book_rounded,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => GradeScaffold(
        title: 'Syllabus',
        icon: Icons.menu_book_rounded,
        child: Center(child: Text('Error: $e', style: TextStyle(color: palette.onSurfaceMuted))),
      ),
      data: (plan) {
        if (plan == null) {
          return GradeScaffold(
            title: 'Syllabus',
            icon: Icons.menu_book_rounded,
            child: Center(
              child: Text('Sign in as a student to view your syllabus.',
                  style: TextStyle(color: palette.onSurfaceMuted)),
            ),
          );
        }
        return GradeScaffold(
          title: 'Syllabus — ${plan.className}',
          subtitle: plan.stageLabel,
          icon: Icons.menu_book_rounded,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppBrand.navy, AppBrand.navy2],
                  ),
                  borderRadius: BorderRadius.circular(AppBrand.radiusCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your class',
                        style: TextStyle(fontSize: 13, color: Color(0xFFCFE0F2))),
                    const SizedBox(height: 4),
                    Text('${plan.className} · ${plan.stageName}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(
                      '${plan.modules.length} modules · ${plan.topicCount} topics · ${plan.projects.length} projects',
                      style: const TextStyle(fontSize: 12, color: Color(0xFFB9CBE0)),
                    ),
                  ],
                ),
              ),
              ...plan.modules.map((m) => ModuleAccordionCard(module: m)),
              StageProjectsCard(projects: plan.projects, classLabel: plan.className),
              booksAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (books) => EssentialBooksCard(books: books),
              ),
            ],
          ),
        );
      },
    );
  }
}
