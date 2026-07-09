import '../shared/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/app_theme.dart';
import '../../models/course_model.dart';
import '../../providers/course_provider.dart';

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: Subject.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: Subject.values.map((s) => Tab(text: s.label)).toList(),
        ),
      ),
      drawer: const AppDrawer(role: UserRole.student),
      body: TabBarView(
        controller: _tabController,
        children: Subject.values.map((subject) {
          final coursesAsync = ref.watch(coursesForCurrentStudentProvider(subject));
          return coursesAsync.when(
            data: (courses) {
              if (courses.isEmpty) {
                return const Center(
                  child: Text('No courses here yet.', style: TextStyle(color: AppBrand.inkSoft)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: courses.length,
                itemBuilder: (context, i) => _CourseCard(course: courses[i]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        }).toList(),
      ),
    );
  }
}

/// Udemy-style course row: colored thumbnail, bold title, subject tag,
/// and a purple/green price pill on the right (purple = paid, green = free).
class _CourseCard extends StatelessWidget {
  final CourseModel course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final subjectColor = course.subject.color;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/student/courses/${course.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: subjectColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(course.subject.icon, color: subjectColor, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, color: AppBrand.ink, fontSize: 14.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, color: AppBrand.inkSoft),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: subjectColor.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            course.subject.label,
                            style: TextStyle(
                                fontSize: 10.5, fontWeight: FontWeight.w700, color: subjectColor),
                          ),
                        ),
                        const Spacer(),
                        if (course.requiresPurchase)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_outline, size: 13, color: AppBrand.purple),
                              const SizedBox(width: 4),
                              Text(
                                '₹${course.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppBrand.purple,
                                    fontSize: 13),
                              ),
                            ],
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppBrand.greenSoft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'FREE',
                              style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppBrand.green),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
