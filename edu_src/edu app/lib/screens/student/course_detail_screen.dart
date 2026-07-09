import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/doubt_chat_provider.dart';
import '../../providers/repository_providers.dart';
import '../../shared/widgets/ui.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseRepositoryProvider).getCourseById(courseId);
    final unlockedAsync = ref.watch(isCourseUnlockedProvider(courseId));
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: FutureBuilder(
          future: courseAsync,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final course = snapshot.data;
            if (course == null) {
              return const Center(
                child: Text('Course not found', style: TextStyle(color: AppBrand.ink)),
              );
            }
            final subjectColor = course.subject.color;
            return unlockedAsync.when(
              data: (unlocked) => Stack(
                children: [
                  ListView(
                    padding: EdgeInsets.only(
                      bottom: 24 + MediaQuery.of(context).padding.bottom + 84,
                    ),
                    children: [
                      _CoverHeader(
                        color: subjectColor,
                        icon: course.subject.icon,
                        label: course.subject.label,
                        onBack: () => context.pop(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppBrand.ink,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _MetaChip(
                                  icon: Icons.play_circle_outline,
                                  label: '${course.quizIds.length} quizzes',
                                ),
                                const SizedBox(width: 8),
                                if (course.gameId != null)
                                  const _MetaChip(
                                    icon: Icons.videogame_asset_outlined,
                                    label: 'Game',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'About this course',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppBrand.ink,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              course.description,
                              style: const TextStyle(
                                color: AppBrand.inkSoft,
                                height: 1.5,
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(height: 22),
                            if (unlocked) ...[
                              const Text(
                                "What's inside",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppBrand.ink,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _DetailTile(
                                icon: Icons.quiz_outlined,
                                color: AppBrand.purple,
                                title: 'Quizzes',
                                subtitle: 'Test what you learned',
                                onTap: () {
                                  if (course.quizIds.isNotEmpty) {
                                    context.push('/student/quiz/${course.quizIds.first}');
                                  }
                                },
                              ),
                              if (course.gameId != null)
                                _DetailTile(
                                  icon: Icons.videogame_asset_outlined,
                                  color: AppBrand.amber,
                                  title: 'Course game',
                                  subtitle: 'Learn by playing',
                                  onTap: () {},
                                ),
                              Consumer(builder: (context, ref, _) {
                                final hasHadClassAsync =
                                    ref.watch(hasCourseHadClassProvider(course.id));
                                return hasHadClassAsync.when(
                                  data: (hasHadClass) => _DetailTile(
                                    icon: Icons.forum_outlined,
                                    color: AppBrand.green,
                                    title: 'Ask a doubt',
                                    subtitle: hasHadClass
                                        ? 'Chat with your teacher'
                                        : 'Unlocks after your first class',
                                    locked: !hasHadClass,
                                    onTap: !hasHadClass
                                        ? null
                                        : () async {
                                            if (user == null) return;
                                            final thread = await ref
                                                .read(openDoubtThreadProvider)(
                                              studentId: user.id,
                                              teacherId: course.teacherId,
                                              courseId: course.id,
                                            );
                                            if (context.mounted) {
                                              context
                                                  .push('/doubt-thread/${thread.id}');
                                            }
                                          },
                                  ),
                                  loading: () => const _DetailTile(
                                    icon: Icons.forum_outlined,
                                    color: AppBrand.green,
                                    title: 'Ask a doubt',
                                    subtitle: 'Checking availability…',
                                    locked: true,
                                  ),
                                  error: (e, _) => _DetailTile(
                                    icon: Icons.forum_outlined,
                                    color: AppBrand.green,
                                    title: 'Ask a doubt',
                                    subtitle: 'Error: $e',
                                    locked: true,
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  _StickyBottomBar(
                    unlocked: unlocked,
                    price: course.price,
                    onEnroll: () async {
                      await ref.read(purchaseCourseProvider)(courseId);
                      ref.invalidate(isCourseUnlockedProvider(courseId));
                    },
                    onContinue: () {
                      if (course.quizIds.isNotEmpty) {
                        context.push('/student/quiz/${course.quizIds.first}');
                      }
                    },
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error: $e', style: const TextStyle(color: AppBrand.ink)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CoverHeader extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onBack;

  const _CoverHeader({
    required this.color,
    required this.icon,
    required this.label,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      height: 230 + topPad,
      padding: EdgeInsets.only(top: topPad),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: .85), color.withValues(alpha: .35)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -10,
            child: Icon(icon, size: 180, color: Colors.white.withValues(alpha: .14)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CircleIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppBrand.cardAlt,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppBrand.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppBrand.inkSoft),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppBrand.inkSoft,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final bool locked;
  final VoidCallback? onTap;

  const _DetailTile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.locked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: locked ? AppBrand.cardAlt : color.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: locked ? AppBrand.inkSoft : color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppBrand.ink,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(color: AppBrand.inkSoft, fontSize: 12.5),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              locked ? Icons.lock_outline : Icons.chevron_right,
              size: locked ? 18 : 24,
              color: AppBrand.inkSoft,
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyBottomBar extends StatelessWidget {
  final bool unlocked;
  final double price;
  final VoidCallback onEnroll;
  final VoidCallback onContinue;

  const _StickyBottomBar({
    required this.unlocked,
    required this.price,
    required this.onEnroll,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          14,
          16,
          14 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppBrand.card,
          border: Border(top: BorderSide(color: AppBrand.line)),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          children: [
            if (!unlocked) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Price',
                    style: TextStyle(color: AppBrand.inkSoft, fontSize: 12),
                  ),
                  Text(
                    '₹${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppBrand.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GradientButton(
                  label: 'Enroll now',
                  icon: Icons.lock_open_rounded,
                  onPressed: onEnroll,
                ),
              ),
            ] else
              Expanded(
                child: GradientButton(
                  label: 'Continue learning',
                  icon: Icons.play_arrow_rounded,
                  onPressed: onContinue,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
