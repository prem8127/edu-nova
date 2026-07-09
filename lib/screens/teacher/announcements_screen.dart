import 'package:flutter/material.dart';
import '../shared/app_drawer.dart';
import '../../core/constants/app_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/platform_providers.dart';
import '../../shared/widgets/ui.dart';

/// Lets a teacher broadcast an announcement to one of their courses and see
/// the history of what they've posted.
class TeacherAnnouncementsScreen extends ConsumerWidget {
  const TeacherAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final courses = ref.watch(coursesForTeacherProvider(user?.id ?? ''));
    final posts = ref.watch(announcementsForTeacherProvider(user?.id ?? ''));

    return Scaffold(
      drawer: const AppDrawer(role: UserRole.teacher),
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Announcements',
                subtitle: 'Broadcast updates to your course students',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GradientButton(
                  label: 'New announcement',
                  icon: Icons.campaign_rounded,
                  onPressed: () {
                    final list = courses.value ?? const [];
                    if (list.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('You have no assigned courses yet.')),
                      );
                      return;
                    }
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _ComposeSheet(courses: list),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: posts.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (items) {
                    if (items.isEmpty) {
                      return const EmptyState(
                        icon: Icons.campaign_outlined,
                        title: 'No announcements yet',
                        body: 'Posts you send to your courses will appear here.',
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final a = items[i];
                        return GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppBrand.ink,
                                      fontSize: 15)),
                              const SizedBox(height: 6),
                              Text(a.body,
                                  style: const TextStyle(
                                      color: AppBrand.inkSoft, height: 1.45, fontSize: 13)),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposeSheet extends ConsumerStatefulWidget {
  const _ComposeSheet({required this.courses});
  final List<CourseModel> courses;

  @override
  ConsumerState<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends ConsumerState<_ComposeSheet> {
  late String _courseId = widget.courses.first.id;
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await ref.read(announcementControllerProvider).post(
          courseId: _courseId,
          title: _title.text.trim(),
          body: _body.text.trim(),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppBrand.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New announcement',
                style: TextStyle(fontWeight: FontWeight.w800, color: AppBrand.ink, fontSize: 17)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _courseId,
              decoration: const InputDecoration(labelText: 'Course'),
              items: [
                for (final c in widget.courses)
                  DropdownMenuItem(value: c.id, child: Text(c.title)),
              ],
              onChanged: (v) => setState(() => _courseId = v ?? _courseId),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _body,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 18),
            GradientButton(
              label: 'Post announcement',
              loading: _saving,
              onPressed: _post,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
