import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/syllabus_model.dart';

/// One module's card: title + topic count header, then every topic as a
/// wrapped pill chip. Mirrors the prototype's `moduleAccordion()`.
class ModuleAccordionCard extends StatelessWidget {
  const ModuleAccordionCard({super.key, required this.module});
  final SyllabusModule module;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppBrand.card,
        borderRadius: BorderRadius.circular(AppBrand.radiusCard),
        border: Border.all(color: AppBrand.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(module.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14.5, color: AppBrand.ink)),
              ),
              Text('${module.topics.length} topics',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: AppBrand.inkSoft)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: module.topics
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppBrand.bg,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppBrand.line),
                      ),
                      child: Text(t,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600, color: AppBrand.ink)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// "🚀 Stage Projects" card — list of hands-on deliverables for a class.
class StageProjectsCard extends StatelessWidget {
  const StageProjectsCard({super.key, required this.projects, this.classLabel});

  final List<String> projects;

  /// If set, each row shows "Hands-on project for {classLabel}" as a
  /// subtitle (used on the student screen, which only shows one class).
  final String? classLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppBrand.card,
        borderRadius: BorderRadius.circular(AppBrand.radiusCard),
        border: Border.all(color: AppBrand.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🚀 Stage Projects',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppBrand.ink)),
          const SizedBox(height: 12),
          ...projects.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppBrand.orange.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: AppBrand.orange, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13.5, color: AppBrand.ink)),
                          if (classLabel != null)
                            Text('Hands-on project for $classLabel',
                                style: const TextStyle(fontSize: 11.5, color: AppBrand.inkSoft)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// "📚 Essential Books (Class 6–10)" block — three columns (Beginner /
/// Intermediate / Advanced), each listing its recommended titles.
class EssentialBooksCard extends StatelessWidget {
  const EssentialBooksCard({super.key, required this.books});
  final Map<String, List<String>> books;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppBrand.card,
        borderRadius: BorderRadius.circular(AppBrand.radiusCard),
        border: Border.all(color: AppBrand.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📚 Essential Books (Class 6–10)',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppBrand.ink)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 20,
            runSpacing: 16,
            children: books.entries.map((e) {
              return SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppBrand.orange,
                            letterSpacing: .4)),
                    const SizedBox(height: 8),
                    ...e.value.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(b,
                              style: const TextStyle(fontSize: 12.5, color: AppBrand.ink)),
                        )),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Horizontal scrollable row of class tabs (Class 6 … Class 10) used by the
/// Teacher and Admin syllabus screens to switch which class's roadmap is
/// shown below. Mirrors the prototype's `.filterBar` buttons.
class ClassFilterBar extends StatelessWidget {
  const ClassFilterBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == selectedIndex;
          return Material(
            color: selected ? AppBrand.orange : AppBrand.card,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () => onSelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: selected ? Colors.transparent : AppBrand.line),
                ),
                child: Text(labels[i],
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppBrand.ink)),
              ),
            ),
          );
        },
      ),
    );
  }
}
