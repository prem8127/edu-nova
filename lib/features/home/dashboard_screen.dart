import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../shared/widgets/ui.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => DotGridBackground(child: ResponsiveContent(child: CustomScrollView(slivers: [
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 0), child: Row(children: [
      const BrandMark(compact: true), const Spacer(), RoundIconButton(icon: Icons.notifications_none_rounded, badge: true, onTap: () => context.push('/notifications')), const SizedBox(width: 10),
      GestureDetector(onTap: () => context.go('/profile'), child: const CircleAvatar(radius: 21, backgroundColor: AppColors.orangeSoft, child: Text('AK', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900)))),
    ]))),
    SliverPadding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 26), sliver: SliverList(delegate: SliverChildListDelegate([
      Text('Good morning, Alex 👋', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 5), Text('What will you\nmaster today?', style: Theme.of(context).textTheme.displayMedium),
      const SizedBox(height: 20), const SearchBox(), const SizedBox(height: 22),
      _HeroCard(onTap: () => context.go('/mentor')), const SizedBox(height: 26),
      const SectionHeader(title: 'Your progress'), const SizedBox(height: 12), const _ProgressOverview(), const SizedBox(height: 28),
      SectionHeader(title: 'Continue learning', action: 'See all', onTap: () => context.go('/courses')), const SizedBox(height: 12),
      SizedBox(height: 278, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: 2, separatorBuilder: (_, __) => const SizedBox(width: 14), itemBuilder: (_, i) => SizedBox(width: 238, child: CourseCard(course: MockData.courses[i], onTap: () => context.push('/courses/details'))))),
      const SizedBox(height: 28), const SectionHeader(title: 'Quick actions'), const SizedBox(height: 12), _QuickActions(),
      const SizedBox(height: 28), SectionHeader(title: 'Recommended for you', action: 'Explore', onTap: () => context.go('/explore')), const SizedBox(height: 12),
      CourseCard(course: MockData.courses[2], horizontal: true, onTap: () => context.push('/courses/details')), const SizedBox(height: 14),
      CourseCard(course: MockData.courses[3], horizontal: true, onTap: () => context.push('/courses/details')), const SizedBox(height: 28),
      const SectionHeader(title: 'Upcoming events'), const SizedBox(height: 12), const _EventCard(), const SizedBox(height: 10),
    ]))),
  ])));
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: AppColors.navy.withValues(alpha: .22), blurRadius: 26, offset: const Offset(0, 12))]),
    child: Stack(children: [
      Positioned(right: -20, top: -50, child: Container(width: 170, height: 170, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: .07), width: 28)))),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StatusPill('AI POWERED', color: AppColors.orange, foreground: Colors.white, icon: Icons.auto_awesome_rounded), const SizedBox(height: 18),
        const Text('Your next move,\nmade clearer.', style: TextStyle(color: Colors.white, fontSize: 28, height: 1.04, fontWeight: FontWeight.w900, letterSpacing: -1)), const SizedBox(height: 9),
        const Text('Get a personalized study plan in 60 seconds.', style: TextStyle(color: Colors.white70, height: 1.4)), const SizedBox(height: 19),
        FilledButton.icon(onPressed: onTap, style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)), icon: const Icon(Icons.arrow_outward_rounded), label: const Text('Ask Nova', style: TextStyle(fontWeight: FontWeight.w900))),
      ]),
    ]),
  );
}

class _ProgressOverview extends StatelessWidget {
  const _ProgressOverview();
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
    const ProgressRing(value: .68, size: 82), const SizedBox(width: 18),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Weekly learning goal', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 5), const Text('4h 45m of 7 hours', style: TextStyle(color: AppColors.muted)), const SizedBox(height: 13), const Row(children: [Icon(Icons.local_fire_department_rounded, color: AppColors.orange, size: 19), SizedBox(width: 5), Text('12 day streak', style: TextStyle(fontWeight: FontWeight.w800)), Spacer(), Text('+18%', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w900))])])),
  ])));
}

class _QuickActions extends StatelessWidget {
  final items = const [
    ('Build roadmap', Icons.route_rounded, Color(0xFFFFD7C2), '/roadmap'),
    ('Find internships', Icons.work_outline_rounded, Color(0xFFDDE7FF), '/internships'),
    ('Prepare exams', Icons.workspace_premium_rounded, Color(0xFFFFE9AF), '/exams'),
    ('Meet mentors', Icons.groups_rounded, Color(0xFFE7F5DF), '/influencers'),
  ];
  @override
  Widget build(BuildContext context) => GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.35, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: items.length, itemBuilder: (_, i) {
    final item = items[i];
    return Card(child: InkWell(borderRadius: BorderRadius.circular(26), onTap: () => context.push(item.$4), child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: item.$3, borderRadius: BorderRadius.circular(14)), child: Icon(item.$2, color: AppColors.navy)), Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.heading))]))));
  });
}

class _EventCard extends StatelessWidget {
  const _EventCard();
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [
    Container(width: 76, height: 88, decoration: BoxDecoration(color: AppColors.orangeSoft, borderRadius: BorderRadius.circular(20)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('18', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.navy)), Text('JUL', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.orange))])),
    const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const StatusPill('LIVE WORKSHOP', color: Color(0xFFE7F5DF), foreground: AppColors.green), const SizedBox(height: 8), Text('Portfolio reviews that get noticed', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 5), const Text('6:00 PM · with Maya Sharma', style: TextStyle(color: AppColors.muted))])),
    const Icon(Icons.arrow_forward_ios_rounded, size: 17), const SizedBox(width: 8),
  ])));
}
