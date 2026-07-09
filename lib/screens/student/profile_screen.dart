import '../shared/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final stats = ref.watch(studentStatsProvider);
    final progress = ref.watch(subjectProgressProvider);

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppBrand.bg,
      drawer: const AppDrawer(role: UserRole.student),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ---- Gradient header ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
              decoration: const BoxDecoration(
                gradient: AppBrand.heroGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (ctx) => IconButton(
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                          icon: const Icon(Icons.menu_rounded, color: Colors.white),
                          tooltip: 'Menu',
                        ),
                      ),
                      const Spacer(),
                      const Text('Profile',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _showSettings(context, ref),
                        icon: const Icon(Icons.settings_outlined, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 41,
                          backgroundColor: Colors.white.withValues(alpha: .25),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Photo upload coming soon')),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppBrand.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                size: 15, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(user.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      user.grade?.label ?? user.role.name.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // ---- Stats row (overlaps the header slightly) ----
            Transform.translate(
              offset: const Offset(0, -22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: stats.when(
                  data: (s) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: .06),
                            blurRadius: 16,
                            offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Row(
                      children: [
                        _StatItem(
                            icon: Icons.menu_book_rounded,
                            value: '${s.coursesEnrolled}',
                            label: 'Courses'),
                        const _StatDivider(),
                        _StatItem(
                            icon: Icons.local_fire_department_rounded,
                            value: '${s.streakDays}',
                            label: 'Day streak',
                            color: AppBrand.amber),
                        const _StatDivider(),
                        _StatItem(
                            icon: Icons.emoji_events_rounded,
                            value: '${s.overallAverage.round()}%',
                            label: 'Avg score',
                            color: AppBrand.green),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox(height: 90),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your progress by subject',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800, color: AppBrand.ink)),
                  const SizedBox(height: 10),
                  progress.when(
                    data: (list) => Column(
                      children: list.map((p) => _SubjectProgressRow(progress: p)).toList(),
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text('Could not load progress: $e'),
                  ),
                  const SizedBox(height: 22),
                  const Text('Account',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800, color: AppBrand.ink)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppBrand.line),
                    ),
                    child: Column(
                      children: [
                        _ProfileRow(icon: Icons.person_outline, label: 'Name', value: user.name),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _ProfileRow(
                            icon: Icons.class_outlined,
                            label: 'Class',
                            value: user.grade?.label ?? '—'),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _ProfileRow(
                            icon: Icons.cake_outlined,
                            label: 'Age',
                            value: user.age?.toString() ?? '—'),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _ProfileRow(
                            icon: Icons.badge_outlined,
                            label: 'Role',
                            value: user.role.name[0].toUpperCase() + user.role.name.substring(1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text('Support',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800, color: AppBrand.ink)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppBrand.line),
                    ),
                    child: Column(
                      children: [
                        _LinkRow(
                          icon: Icons.help_outline_rounded,
                          label: 'Help & Support',
                          onTap: () => _snack(context, 'Help center coming soon'),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _LinkRow(
                          icon: Icons.info_outline_rounded,
                          label: 'About Aditya Globals',
                          onTap: () => _snack(context, 'Aditya Globals v0.1.0'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                    onPressed: () => _confirmLogout(context, ref),
                    label: const Text('Log out'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            SwitchListTile(
              value: true,
              onChanged: (_) => _snack(context, 'Notification settings coming soon'),
              title: const Text('Push notifications'),
              secondary: const Icon(Icons.notifications_none_rounded),
            ),
            SwitchListTile(
              value: false,
              onChanged: (_) => _snack(context, 'Dark mode coming soon'),
              title: const Text('Dark mode'),
              secondary: const Icon(Icons.dark_mode_outlined),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text("You'll need to sign in again to continue learning."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) context.go(AppRoutes.roleSelect);
    }
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppBrand.purple,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppBrand.ink)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppBrand.inkSoft)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: AppBrand.line);
}

class _SubjectProgressRow extends StatelessWidget {
  const _SubjectProgressRow({required this.progress});
  final SubjectProgress progress;

  @override
  Widget build(BuildContext context) {
    final started = progress.attemptCount > 0;
    final pct = started ? progress.averagePercentage / 100 : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppBrand.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(progress.subject.icon, size: 18, color: progress.subject.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(progress.subject.label,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppBrand.ink)),
              ),
              if (!started)
                const Text('Not started',
                    style: TextStyle(fontSize: 12, color: AppBrand.inkSoft))
              else if (progress.isLagging)
                _Badge(text: 'Lagging', color: Colors.red.shade600)
              else if (progress.averagePercentage >= 80)
                _Badge(text: 'Great', color: AppBrand.green)
              else
                _Badge(text: 'On track', color: AppBrand.purple),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: AppBrand.line,
              color: progress.isLagging ? Colors.red.shade400 : progress.subject.color,
            ),
          ),
          if (started) ...[
            const SizedBox(height: 6),
            Text(
              '${progress.averagePercentage.toStringAsFixed(0)}% avg over ${progress.attemptCount} quiz${progress.attemptCount == 1 ? '' : 'zes'}',
              style: const TextStyle(fontSize: 11.5, color: AppBrand.inkSoft),
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800)),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppBrand.purple),
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppBrand.inkSoft)),
      subtitle: Text(value,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: AppBrand.ink)),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppBrand.purple),
      title: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppBrand.ink, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppBrand.inkSoft),
      onTap: onTap,
    );
  }
}
