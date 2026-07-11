import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../core/router/app_router.dart';
import '../../models/course_model.dart';
import '../../providers/admin_provider.dart';

class CourseManagementScreen extends ConsumerStatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  ConsumerState<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends ConsumerState<CourseManagementScreen> {
  Grade? _gradeFilter;
  Subject? _subjectFilter;

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(allCoursesForAdminProvider);
    final actions = ref.read(courseAuthoringActionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Course Authoring')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.adminCourseEditor),
        icon: const Icon(Icons.add),
        label: const Text('New course'),
      ),
      body: coursesAsync.when(
        data: (rows) {
          final filtered = rows.where((r) {
            if (_gradeFilter != null && r.course.grade != _gradeFilter) return false;
            if (_subjectFilter != null && r.course.subject != _subjectFilter) return false;
            return true;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      DropdownButton<Grade?>(
                        hint: const Text('All grades'),
                        value: _gradeFilter,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All grades')),
                          for (final g in Grade.values)
                            DropdownMenuItem(value: g, child: Text(g.label)),
                        ],
                        onChanged: (g) => setState(() => _gradeFilter = g),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<Subject?>(
                        hint: const Text('All subjects'),
                        value: _subjectFilter,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All subjects')),
                          for (final s in Subject.values)
                            DropdownMenuItem(value: s, child: Text(s.label)),
                        ],
                        onChanged: (s) => setState(() => _subjectFilter = s),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No courses match this filter.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final row = filtered[i];
                          final course = row.course;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: course.subject.color.withValues(alpha: .18),
                                child: Icon(course.subject.icon, color: course.subject.color, size: 18),
                              ),
                              title: Text(course.title),
                              subtitle: Text(
                                '${course.grade.label} · ${course.subject.label} · ${row.teacherName}\n'
                                '${course.requiresPurchase ? '₹${course.price.toStringAsFixed(0)}' : 'Free'}',
                              ),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    context.push(AppRoutes.adminCourseEditor, extra: course);
                                  } else if (value == 'delete') {
                                    _confirmDelete(context, course, actions);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                              ),
                              onTap: () => context.push(AppRoutes.adminCourseEditor, extra: course),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CourseModel course, dynamic actions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete course?'),
        content: Text('"${course.title}" will be removed for every student and teacher. '
            'This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await actions.deleteCourse(course);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
