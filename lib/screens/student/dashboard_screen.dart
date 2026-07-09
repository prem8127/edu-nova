import '../shared/app_drawer.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';

String greetingForNow() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

const _bg = Color(0xFFF5F7FA);
const _surface = Colors.white;
const _navy = Color(0xFF102D4F);
const _text = Color(0xFF10233F);
const _muted = Color(0xFF66758D);
const _line = Color(0xFFE2E8F0);
const _orange = Color(0xFFFF7A00);
const _green = Color(0xFF16A34A);
const _red = Color(0xFFE94B4B);

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final firstName = (user?.name.trim().split(' ').first ?? 'Meher');
    final grade = user?.grade?.label ?? 'Class 9';

    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppDrawer(role: UserRole.student),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              title: 'Good afternoon, $firstName 👋',
              subtitle: '$grade · Full Stack Foundations Batch',
              initial: firstName.isNotEmpty ? firstName[0] : 'M',
              onBell: () => context.push(AppRoutes.studentNotifications),
              onAvatar: () => context.push(AppRoutes.studentProfile),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 920;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      desktop ? 24 : 16,
                      desktop ? 25 : 16,
                      desktop ? 30 : 16,
                      24,
                    ),
                    child: desktop
                        ? Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 163,
                                      child: _LiveClassHeroCard(
                                        onJoin: () => context.push(AppRoutes.studentLiveClasses),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  const Expanded(
                                    child: SizedBox(
                                      height: 163,
                                      child: _ProgressCard(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 19),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 446,
                                      child: _NotesHomeworkCard(
                                        onAction: () => context.push(AppRoutes.studentAssignments),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: SizedBox(
                                      height: 446,
                                      child: _RecordedVideosCard(
                                        onAction: () => context.push(AppRoutes.studentRecordedVideos),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _LiveClassHeroCard(
                                onJoin: () => context.push(AppRoutes.studentLiveClasses),
                              ),
                              const SizedBox(height: 14),
                              const _ProgressCard(),
                              const SizedBox(height: 14),
                              _NotesHomeworkCard(
                                onAction: () => context.push(AppRoutes.studentAssignments),
                              ),
                              const SizedBox(height: 14),
                              _RecordedVideosCard(
                                onAction: () => context.push(AppRoutes.studentRecordedVideos),
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
    required this.onBell,
    required this.onAvatar,
  });

  final String title;
  final String subtitle;
  final String initial;
  final VoidCallback onBell;
  final VoidCallback onAvatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 73,
      padding: const EdgeInsets.fromLTRB(25, 0, 30, 0),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) => _IconOnlyButton(
              icon: Icons.menu_rounded,
              onTap: () => Scaffold.of(context).openDrawer(),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          _IconOnlyButton(icon: Icons.notifications_none_rounded, onTap: onBell),
          const SizedBox(width: 14),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onAvatar,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFFF941F),
              child: Text(
                initial.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconOnlyButton extends StatelessWidget {
  const _IconOnlyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(icon, color: const Color(0xFF61708A), size: 21),
      tooltip: 'Notifications',
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
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
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            action,
            style: const TextStyle(
              color: _orange,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _LiveClassHeroCard extends StatelessWidget {
  const _LiveClassHeroCard({required this.onJoin});

  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 168,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF8C24).withValues(alpha: .35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB53250).withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 6, color: Color(0xFFFF6575)),
                    SizedBox(width: 6),
                    Text(
                      'LIVE IN 12 MIN',
                      style: TextStyle(
                        color: Color(0xFFFFC1CB),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              const Text(
                'Python Functions & Loops — Session 14',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Faculty: Mr. Kiran Kumar · 4:00 PM – 5:15 PM',
                style: TextStyle(
                  color: Color(0xFFD6E0EC),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 35,
                child: ElevatedButton(
                  onPressed: onJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 19),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Join Live Class →',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
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

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(22, 24, 24, 24),
      child: Row(
        children: [
          const _ProgressRing(value: .74),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Overall Progress',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Full Stack Foundations',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _text,
                    fontSize: 17,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '🔥 12-day streak · 3 modules left',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: CustomPaint(
        painter: _RingPainter(value),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '74%',
                style: TextStyle(
                  color: _text,
                  fontSize: 20,
                  height: .95,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'COURSE',
                style: TextStyle(
                  color: _muted,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    const width = 8.0;
    final rect = Offset(width / 2, width / 2) & Size(size.width - width, size.height - width);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = const Color(0xFFE9EDF3)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..color = _orange
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.value != value;
}

class _NotesHomeworkCard extends StatelessWidget {
  const _NotesHomeworkCard({required this.onAction});

  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        children: [
          _SectionTitle(
            icon: '📋',
            title: "Today's Notes & Homework",
            action: 'View all',
            onAction: onAction,
          ),
          const SizedBox(height: 18),
          const _NoteRow(
            icon: Icons.article_outlined,
            iconColor: _orange,
            iconBg: Color(0xFFFFF0DE),
            title: 'Loops & Iteration — Class Notes',
            subtitle: 'Uploaded today, 4:10 PM',
            badge: 'NEW',
            badgeFg: Color(0xFF215E9C),
            badgeBg: Color(0xFFEAF3FF),
          ),
          const _RowDivider(),
          const _NoteRow(
            icon: Icons.schedule_rounded,
            iconColor: Color(0xFF2F6FB0),
            iconBg: Color(0xFFEAF3FF),
            title: 'Homework 14 — 10 Practice Problems',
            subtitle: 'Due tomorrow, 9:00 AM',
            badge: 'DUE',
            badgeFg: _orange,
            badgeBg: Color(0xFFFFF0DE),
          ),
          const _RowDivider(),
          const _NoteRow(
            icon: Icons.check_circle_outline_rounded,
            iconColor: _green,
            iconBg: Color(0xFFE6F7ED),
            title: 'Homework 13 — Variables & Data Types',
            subtitle: 'Submitted · Reviewed',
            badge: 'DONE',
            badgeFg: _green,
            badgeBg: Color(0xFFE6F7ED),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: _line, indent: 0, endIndent: 0);
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeFg,
    required this.badgeBg,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeFg;
  final Color badgeBg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
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
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 13,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: badgeFg,
                fontSize: 10,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordedVideosCard extends StatelessWidget {
  const _RecordedVideosCard({required this.onAction});

  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: [
          _SectionTitle(
            icon: '🎬',
            title: 'Recorded Videos',
            action: 'Library',
            onAction: onAction,
          ),
          const SizedBox(height: 17),
          const _VideoCard(session: 'Session 13', topic: 'Data Types', duration: '42:10'),
          const SizedBox(height: 12),
          const _VideoCard(session: 'Session 12', topic: 'Variables', duration: '38:55'),
          const SizedBox(height: 12),
          const _VideoCard(session: 'Session 11', topic: 'Intro to Python', duration: '45:20'),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.session,
    required this.topic,
    required this.duration,
  });

  final String session;
  final String topic;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 70,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: _navy),
                const Center(
                  child: Icon(Icons.play_arrow_rounded, size: 28, color: Color(0xFFDCE7F2)),
                ),
                Positioned(
                  right: 7,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .72),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    session,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 12,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    topic,
                    style: const TextStyle(color: _muted, fontSize: 10.5),
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
