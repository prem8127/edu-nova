import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../shared/app_drawer.dart';

const _bg = Color(0xFFF5F7FA);
const _surface = Colors.white;
const _navy = Color(0xFF102D4F);
const _text = Color(0xFF10233F);
const _muted = Color(0xFF66758D);
const _line = Color(0xFFE2E8F0);
const _orange = Color(0xFFFF7A00);
const _green = Color(0xFF16A34A);

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final initial = (user?.name.trim().isNotEmpty ?? false) ? user!.name.trim()[0] : 'A';

    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppDrawer(role: UserRole.admin),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(initial: initial),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 920;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      desktop ? 29 : 16,
                      desktop ? 25 : 16,
                      desktop ? 28 : 16,
                      24,
                    ),
                    child: Column(
                      children: [
                        _StatsGrid(
                          desktop: desktop,
                          cards: const [
                            _StatData('Total Students', '1,248', '↑ 6.2% MoM'),
                            _StatData('Active Teachers', '27', '↑ 2 this month'),
                            _StatData('Live Classes Today', '34', 'On schedule'),
                            _StatData('Collections (MTD)', '₹8.4L', '↑ 11% vs last month'),
                          ],
                        ),
                        SizedBox(height: desktop ? 18 : 14),
                        desktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 250,
                                      child: _ContentLibraryCard(
                                        onManage: () => context.push(AppRoutes.adminCourses),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: SizedBox(
                                      height: 250,
                                      child: _BatchHealthCard(
                                        onAction: () => context.push(AppRoutes.adminClasses),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _ContentLibraryCard(onManage: () => context.push(AppRoutes.adminCourses)),
                                  const SizedBox(height: 14),
                                  _BatchHealthCard(onAction: () => context.push(AppRoutes.adminClasses)),
                                ],
                              ),
                        SizedBox(height: desktop ? 18 : 14),
                        _UserManagementCard(
                          onAction: () => context.push(AppRoutes.adminManageTeachers),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 73,
      padding: const EdgeInsets.fromLTRB(29, 0, 30, 0),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) => InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.menu_rounded, color: _text, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Platform Overview',
                  style: TextStyle(
                    color: _text,
                    fontSize: 21,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Aditya Globals · Andhra Pradesh Region',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12.5,
                    height: 1.1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.notifications_none_rounded, color: Color(0xFF61708A), size: 21),
          const SizedBox(width: 18),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFFF941F),
            child: Text(
              initial.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: child,
    );
  }
}

class _StatData {
  const _StatData(this.label, this.value, this.note);
  final String label;
  final String value;
  final String note;
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.desktop, required this.cards});

  final bool desktop;
  final List<_StatData> cards;

  @override
  Widget build(BuildContext context) {
    if (desktop) {
      return Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            Expanded(child: _StatCard(cards[i])),
            if (i != cards.length - 1) const SizedBox(width: 18),
          ],
        ],
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final card in cards)
          SizedBox(width: 260, child: _StatCard(card)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.data);

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 15),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            style: const TextStyle(
              color: Color(0xFFB8CEE8),
              fontSize: 12,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            data.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: .9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            data.note,
            style: const TextStyle(
              color: _green,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.action,
    required this.onAction,
  });

  final String icon;
  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _text,
              fontSize: 16,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            action,
            style: const TextStyle(color: _orange, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _ContentLibraryCard extends StatelessWidget {
  const _ContentLibraryCard({required this.onManage});

  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        children: [
          _SectionHeader(
            icon: '📚',
            title: 'Content Library',
            action: 'Manage',
            onAction: onManage,
          ),
          const SizedBox(height: 17),
          const _LibraryRow(
            icon: Icons.article_outlined,
            iconColor: _orange,
            iconBg: Color(0xFFFFF0DE),
            title: 'Class Notes',
            subtitle: '842 documents',
          ),
          const Divider(height: 1, color: _line),
          const _LibraryRow(
            icon: Icons.play_arrow_rounded,
            iconColor: Color(0xFF2F6FB0),
            iconBg: Color(0xFFEAF3FF),
            title: 'Recorded Videos',
            subtitle: '603 sessions · 410 hrs',
          ),
          const Divider(height: 1, color: _line),
          const _LibraryRow(
            icon: Icons.grid_view_rounded,
            iconColor: _green,
            iconBg: Color(0xFFE6F7ED),
            title: 'MCQ Test Bank',
            subtitle: '1,120 questions',
          ),
        ],
      ),
    );
  }
}

class _LibraryRow extends StatelessWidget {
  const _LibraryRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: _muted, fontSize: 11.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchHealthCard extends StatelessWidget {
  const _BatchHealthCard({required this.onAction});

  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        children: [
          _SectionHeader(
            icon: '🏫',
            title: 'Batch Health',
            action: 'All batches',
            onAction: onAction,
          ),
          const SizedBox(height: 17),
          const _HealthRow('Batch A', .85, '85%', _green),
          const SizedBox(height: 15),
          const _HealthRow('Batch B', .66, '66%', _orange),
          const SizedBox(height: 15),
          const _HealthRow('Batch C', .90, '90%', _green),
        ],
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow(this.label, this.value, this.percent, this.color);

  final String label;
  final double value;
  final String percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              color: color,
              backgroundColor: const Color(0xFFF0F3F7),
            ),
          ),
        ),
        const SizedBox(width: 25),
        SizedBox(
          width: 34,
          child: Text(
            percent,
            textAlign: TextAlign.right,
            style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _UserManagementCard extends StatelessWidget {
  const _UserManagementCard({required this.onAction});

  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        children: [
          _SectionHeader(
            icon: '👤',
            title: 'User Management',
            action: 'All users',
            onAction: onAction,
          ),
          const SizedBox(height: 12),
          const _UsersHeader(),
          const Divider(height: 1, color: _line),
          const _UserRow('Kiran Kumar', 'Teacher', 'Batch A, B', 'Jan 2026', 'Active', _green),
          const _UserRow('Meher Reddy', 'Student', 'Batch B', 'Mar 2026', 'Active', _green),
          const _UserRow('Priya Sharma', 'Teacher', 'Batch C', 'Feb 2026', 'Active', _green),
          const _UserRow('Arjun Naidu', 'Student', 'Batch A', 'Jun 2026', 'Inactive', _orange),
        ],
      ),
    );
  }
}

class _UsersHeader extends StatelessWidget {
  const _UsersHeader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 27,
      child: Row(
        children: [
          Expanded(flex: 3, child: _TableHead('NAME')),
          Expanded(flex: 2, child: _TableHead('ROLE')),
          Expanded(flex: 2, child: _TableHead('BATCH(ES)')),
          Expanded(flex: 2, child: _TableHead('JOINED')),
          Expanded(flex: 2, child: _TableHead('STATUS')),
        ],
      ),
    );
  }
}

class _TableHead extends StatelessWidget {
  const _TableHead(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: _muted, fontSize: 10.5, fontWeight: FontWeight.w900),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow(
    this.name,
    this.role,
    this.batch,
    this.joined,
    this.status,
    this.statusColor,
  );

  final String name;
  final String role;
  final String batch;
  final String joined;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _line))),
      child: Row(
        children: [
          Expanded(flex: 3, child: _CellText(name)),
          Expanded(flex: 2, child: _CellText(role)),
          Expanded(flex: 2, child: _CellText(batch)),
          Expanded(flex: 2, child: _CellText(joined)),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 10.5, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CellText extends StatelessWidget {
  const _CellText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: _text, fontSize: 12.5, fontWeight: FontWeight.w500),
    );
  }
}
