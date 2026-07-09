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
const _red = Color(0xFFE94B4B);

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final firstName = user?.name.trim().split(' ').first ?? 'Kiran';

    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppDrawer(role: UserRole.teacher),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              title: 'Welcome back, $firstName 👋',
              subtitle: '4 Batches · 118 Students',
              initial: firstName.isNotEmpty ? firstName[0] : 'K',
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 920;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      desktop ? 28 : 16,
                      desktop ? 25 : 16,
                      desktop ? 29 : 16,
                      24,
                    ),
                    child: Column(
                      children: [
                        _StatsGrid(
                          desktop: desktop,
                          cards: const [
                            _StatData('Batches Handled', '4', '↑ 1 new this month', _green),
                            _StatData('Total Students', '118', '↑ 12 this month', _green),
                            _StatData('Avg. Test Score', '73%', '↑ 4% vs last month', _green),
                            _StatData('Pending Grading', '9', 'Needs attention', _red),
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
                                      height: 245,
                                      child: _ScheduleCard(
                                        onCalendar: () => context.push(AppRoutes.teacherStartClass),
                                        onStart: () => context.push(AppRoutes.teacherStartClass),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: SizedBox(
                                      height: 245,
                                      child: _UploadContentCard(
                                        onOpen: () => context.push(AppRoutes.teacherContentUpload),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _ScheduleCard(
                                    onCalendar: () => context.push(AppRoutes.teacherStartClass),
                                    onStart: () => context.push(AppRoutes.teacherStartClass),
                                  ),
                                  const SizedBox(height: 14),
                                  _UploadContentCard(
                                    onOpen: () => context.push(AppRoutes.teacherContentUpload),
                                  ),
                                ],
                              ),
                        SizedBox(height: desktop ? 18 : 14),
                        _StudentPerformanceCard(
                          onAction: () => context.push(AppRoutes.teacherReviewQueue),
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
  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.initial,
  });

  final String title;
  final String subtitle;
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.fromLTRB(28, 0, 30, 0),
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 21,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
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
  const _StatData(this.label, this.value, this.note, this.noteColor);
  final String label;
  final String value;
  final String note;
  final Color noteColor;
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
    return SizedBox(
      height: 100,
      child: _DashboardCard(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.label,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              data.value,
              style: const TextStyle(
                color: _text,
                fontSize: 28,
                height: .9,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Text(
              data.note,
              style: TextStyle(
                color: data.noteColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
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

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.onCalendar,
    required this.onStart,
  });

  final VoidCallback onCalendar;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 17),
      child: Column(
        children: [
          _SectionHeader(
            icon: '🗓️',
            title: "Today's Schedule",
            action: 'Full calendar',
            onAction: onCalendar,
          ),
          const SizedBox(height: 17),
          _ScheduleRow(
            time: '2:00 PM',
            title: 'Batch A — Arrays & Strings',
            subtitle: '32 students enrolled',
            onStart: onStart,
          ),
          const Divider(height: 1, color: _line),
          _ScheduleRow(
            time: '4:00 PM',
            title: 'Batch B — Functions & Loops',
            subtitle: '28 students enrolled',
            onStart: onStart,
          ),
          const Divider(height: 1, color: _line),
          _ScheduleRow(
            time: '6:30 PM',
            title: 'Batch C — Doubt Clearing',
            subtitle: '41 students enrolled',
            onStart: onStart,
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.onStart,
  });

  final String time;
  final String title;
  final String subtitle;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Text(
              time,
              style: const TextStyle(
                color: Color(0xFF1E4B81),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          const SizedBox(width: 10),
          SizedBox(
            height: 26,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
              ),
              child: const Text('Start', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadContentCard extends StatelessWidget {
  const _UploadContentCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.article_outlined, 'Class Notes'),
      (Icons.check_circle_outline_rounded, 'Homework'),
      (Icons.play_arrow_rounded, 'Recording'),
      (Icons.grid_view_rounded, 'MCQ Test'),
      (Icons.add_rounded, 'New Batch'),
      (Icons.campaign_outlined, 'Announcement'),
    ];
    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        children: [
          _SectionHeader(
            icon: '📥',
            title: 'Upload Content',
            action: 'Open uploader',
            onAction: onOpen,
          ),
          const SizedBox(height: 17),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 11,
            crossAxisSpacing: 11,
            childAspectRatio: 1.35,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final item in items)
                InkWell(
                  borderRadius: BorderRadius.circular(9),
                  onTap: onOpen,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: _line, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.$1, color: _orange, size: 20),
                        const SizedBox(height: 10),
                        Text(
                          item.$2,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudentPerformanceCard extends StatelessWidget {
  const _StudentPerformanceCard({required this.onAction});

  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        children: [
          _SectionHeader(
            icon: '👥',
            title: 'Student Performance — Batch B',
            action: 'All batches',
            onAction: onAction,
          ),
          const SizedBox(height: 12),
          const _PerformanceHeader(),
          const Divider(height: 1, color: _line),
          const _PerformanceRow('Ananya R.', '96%', '92%', '10/10', 'On Track', _green),
          const _PerformanceRow('Vikram S.', '88%', '78%', '8/10', 'On Track', _green),
          const _PerformanceRow('Rahul M.', '62%', '54%', '4/10', 'At Risk', _orange),
          const _PerformanceRow('Sneha K.', '91%', '85%', '9/10', 'On Track', _green),
        ],
      ),
    );
  }
}

class _PerformanceHeader extends StatelessWidget {
  const _PerformanceHeader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 27,
      child: Row(
        children: [
          Expanded(flex: 2, child: _TableHead('STUDENT')),
          Expanded(flex: 2, child: _TableHead('ATTENDANCE')),
          Expanded(flex: 2, child: _TableHead('LAST TEST')),
          Expanded(flex: 2, child: _TableHead('HOMEWORK')),
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

class _PerformanceRow extends StatelessWidget {
  const _PerformanceRow(
    this.name,
    this.attendance,
    this.test,
    this.homework,
    this.status,
    this.statusColor,
  );

  final String name;
  final String attendance;
  final String test;
  final String homework;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _line))),
      child: Row(
        children: [
          Expanded(flex: 2, child: _CellText(name)),
          Expanded(flex: 2, child: _CellText(attendance)),
          Expanded(flex: 2, child: _CellText(test)),
          Expanded(flex: 2, child: _CellText(homework)),
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
