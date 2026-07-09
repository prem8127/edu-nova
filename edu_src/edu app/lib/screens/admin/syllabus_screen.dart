import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/syllabus_model.dart';
import '../../providers/syllabus_provider.dart';
import '../../shared/widgets/grade_scaffold.dart';
import '../../shared/widgets/syllabus_widgets.dart';

/// Curriculum overview for admins: total stats across all classes, a
/// per-class summary, and class tabs with full module/project detail.
/// Mirrors the prototype's `adminSyllabus()`.
class AdminSyllabusScreen extends ConsumerStatefulWidget {
  const AdminSyllabusScreen({super.key});

  @override
  ConsumerState<AdminSyllabusScreen> createState() => _AdminSyllabusScreenState();
}

class _AdminSyllabusScreenState extends ConsumerState<AdminSyllabusScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final syllabusAsync = ref.watch(syllabusDataProvider);
    final booksAsync = ref.watch(essentialBooksProvider);

    return GradeScaffold(
      title: 'Syllabus',
      subtitle: 'Curriculum overview — Class 6 to 10 entrepreneur roadmap',
      icon: Icons.menu_book_rounded,
      child: syllabusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (classes) {
          if (classes.isEmpty) {
            return const Center(child: Text('Syllabus content coming soon.'));
          }
          final totalModules = classes.fold(0, (a, s) => a + s.modules.length);
          final totalTopics = classes.fold(0, (a, s) => a + s.topicCount);
          final totalProjects = classes.fold(0, (a, s) => a + s.projects.length);
          final safeIndex = _selected.clamp(0, classes.length - 1).toInt();
          final selected = classes[safeIndex];

          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatTile(
                    value: '${classes.length}',
                    label: 'Classes Covered',
                    sub: 'Class 6 – 10',
                    icon: Icons.school_rounded,
                    color: AppBrand.navy,
                  ),
                  _StatTile(
                    value: '$totalModules',
                    label: 'Total Modules',
                    sub: 'Across all classes',
                    icon: Icons.view_module_rounded,
                    color: AppBrand.orange,
                  ),
                  _StatTile(
                    value: '$totalTopics',
                    label: 'Total Topics',
                    sub: 'Across all modules',
                    icon: Icons.topic_rounded,
                    color: AppBrand.green,
                  ),
                  _StatTile(
                    value: '$totalProjects',
                    label: 'Stage Projects',
                    sub: 'Hands-on deliverables',
                    icon: Icons.rocket_launch_rounded,
                    color: AppBrand.blue,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppBrand.card,
                  borderRadius: BorderRadius.circular(AppBrand.radiusCard),
                  border: Border.all(color: AppBrand.line),
                ),
                child: Column(
                  children: classes
                      .map((s) => _SummaryRow(plan: s))
                      .toList(),
                ),
              ),
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.sub,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final String sub;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppBrand.card,
        borderRadius: BorderRadius.circular(AppBrand.radiusCard),
        border: Border.all(color: AppBrand.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const Spacer(),
          Text(value,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppBrand.ink)),
          Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppBrand.ink)),
          Text(sub, style: const TextStyle(fontSize: 10.5, color: AppBrand.inkSoft)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.plan});
  final SyllabusClassPlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppBrand.line)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.className,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppBrand.ink)),
                Text(plan.stageName,
                    style: const TextStyle(fontSize: 11, color: AppBrand.inkSoft)),
              ],
            ),
          ),
          Expanded(child: _MiniStat('${plan.modules.length}', 'Modules')),
          Expanded(child: _MiniStat('${plan.topicCount}', 'Topics')),
          Expanded(child: _MiniStat('${plan.projects.length}', 'Projects')),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppBrand.ink)),
        Text(label, style: const TextStyle(fontSize: 9.5, color: AppBrand.inkSoft)),
      ],
    );
  }
}
