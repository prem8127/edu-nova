import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'class6/effects/adventure_effects.dart';
import 'grade_nav.dart';

class PremiumSubject {
  const PremiumSubject(this.name, this.icon, this.color, this.progress, this.detail);
  final String name;
  final IconData icon;
  final Color color;
  final double progress;
  final String detail;
}

class PremiumDashboardConfig {
  const PremiumDashboardConfig({
    required this.name,
    required this.title,
    required this.subtitle,
    required this.themeLabel,
    required this.avatar,
    required this.level,
    required this.streak,
    required this.xp,
    required this.xpTarget,
    required this.rank,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.warm,
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.navColor,
    required this.heroTitle,
    required this.heroAction,
    required this.subjects,
    required this.continueLessons,
    required this.missions,
    required this.rewards,
    required this.mentorTitle,
    required this.mentorMessage,
    required this.challengeTitle,
    required this.challengeDetail,
    required this.analyticsTitle,
    required this.analyticsValues,
    required this.upcoming,
    required this.recommendations,
    required this.leaderboard,
    required this.funFact,
    this.examMode = false,
    this.petMode = true,
    this.castleMode = true,
    this.examCountdown,
    this.prepHubTitle,
    this.prepHubItems = const [],
  });

  final String name;
  final String title;
  final String subtitle;
  final String themeLabel;
  final String avatar;
  final int level;
  final int streak;
  final int xp;
  final int xpTarget;
  final String rank;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color warm;
  final Color backgroundTop;
  final Color backgroundBottom;
  final Color navColor;
  final String heroTitle;
  final String heroAction;
  final List<PremiumSubject> subjects;
  final List<String> continueLessons;
  final List<String> missions;
  final List<String> rewards;
  final String mentorTitle;
  final String mentorMessage;
  final String challengeTitle;
  final String challengeDetail;
  final String analyticsTitle;
  final List<double> analyticsValues;
  final List<String> upcoming;
  final List<String> recommendations;
  final List<String> leaderboard;
  final String funFact;
  final bool examMode;
  final bool petMode;
  final bool castleMode;
  final String? examCountdown;
  final String? prepHubTitle;
  final List<String> prepHubItems;
}

class PremiumStudentDashboard extends StatefulWidget {
  const PremiumStudentDashboard({super.key, required this.config});
  final PremiumDashboardConfig config;

  @override
  State<PremiumStudentDashboard> createState() => _PremiumStudentDashboardState();
}

class _PremiumStudentDashboardState extends State<PremiumStudentDashboard> {
  final _confetti = ConfettiController();
  int _selectedMission = 0;
  bool _chestOpen = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    return Theme(
      data: _theme(c),
      child: Builder(
        builder: (context) => Scaffold(
          extendBody: true,
          bottomNavigationBar: GradeBottomNav(color: c.navColor),
          body: ConfettiLayer(
            controller: _confetti,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c.backgroundTop, c.backgroundBottom]),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: FloatingParticles(count: 26, colors: [Colors.white.withValues(alpha: .72), c.accent.withValues(alpha: .45), c.warm.withValues(alpha: .42)], maxSize: 4, seed: c.level)),
                  SafeArea(
                    bottom: false,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 112),
                      children: [
                        _Hero(config: c, onCelebrate: _celebrate),
                        const SizedBox(height: 22),
                        _Section('Continue Learning', Icons.play_circle_rounded),
                        const SizedBox(height: 12),
                        _ContinueLearning(config: c),
                        const SizedBox(height: 22),
                        _DailyMissions(config: c, selected: _selectedMission, onTap: (i) {
                          setState(() => _selectedMission = i);
                          _celebrate();
                        }),
                        const SizedBox(height: 18),
                        if (c.examCountdown != null) ...[
                          _CountdownCard(config: c),
                          const SizedBox(height: 18),
                        ],
                        if (c.prepHubItems.isNotEmpty) ...[
                          _PrepHub(config: c),
                          const SizedBox(height: 18),
                        ],
                        _RewardsStrip(config: c, onOpen: () {
                          setState(() => _chestOpen = true);
                          _confetti.burst(count: 72, at: const Offset(.5, .44));
                        }, chestOpen: _chestOpen),
                        const SizedBox(height: 22),
                        _MentorAndCompanion(config: c, onCelebrate: _celebrate),
                        const SizedBox(height: 22),
                        _Section(c.examMode ? 'Performance Analytics' : 'Mini Learning Games', c.examMode ? Icons.insights_rounded : Icons.sports_esports_rounded),
                        const SizedBox(height: 12),
                        c.examMode ? _SubjectAnalytics(config: c) : _MiniGames(config: c, onTap: _celebrate),
                        const SizedBox(height: 22),
                        _ChallengeCard(config: c),
                        const SizedBox(height: 22),
                        _Leaderboard(config: c),
                        const SizedBox(height: 22),
                        _Upcoming(config: c),
                        const SizedBox(height: 22),
                        _XpAnalytics(config: c),
                        const SizedBox(height: 22),
                        _Recommendations(config: c),
                        const SizedBox(height: 22),
                        _FunFact(config: c),
                        const SizedBox(height: 22),
                        if (c.castleMode) _ProgressCastle(config: c) else _Journey(config: c),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _celebrate() => _confetti.burst(at: const Offset(.5, .38), count: 38);

  ThemeData _theme(PremiumDashboardConfig c) {
    final base = ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: c.primary, primary: c.primary, secondary: c.secondary, tertiary: c.accent), fontFamily: 'Arial');
    return base.copyWith(
      scaffoldBackgroundColor: c.backgroundBottom,
      textTheme: base.textTheme.copyWith(
        headlineMedium: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: Color(0xFF101828)),
        titleLarge: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF101828)),
        bodyMedium: TextStyle(color: const Color(0xFF101828).withValues(alpha: .68), fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(elevation: 0, color: Colors.white.withValues(alpha: .82), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.config, required this.onCelebrate});
  final PremiumDashboardConfig config;
  final VoidCallback onCelebrate;

  @override
  Widget build(BuildContext context) {
    final progress = (config.xp / config.xpTarget).clamp(0.0, 1.0);
    return _Glass(
      padding: EdgeInsets.zero,
      borderColor: Colors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [config.primary, config.secondary, config.accent]),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _Pill(icon: Icons.auto_awesome_rounded, label: config.themeLabel),
                  const Spacer(),
                  _Pill(icon: Icons.leaderboard_rounded, label: config.rank),
                ]),
                const SizedBox(height: 20),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  GlowPulse(
                    color: config.warm,
                    radius: 36,
                    child: GestureDetector(
                      onTap: onCelebrate,
                      child: Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .92), border: Border.all(color: Colors.white, width: 3)),
                        child: Center(child: Text(config.avatar, style: const TextStyle(fontSize: 34))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(config.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.05)),
                      const SizedBox(height: 7),
                      Text(config.subtitle, style: TextStyle(color: Colors.white.withValues(alpha: .78), fontWeight: FontWeight.w700, height: 1.35)),
                      const SizedBox(height: 13),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        _Pill(icon: Icons.shield_rounded, label: 'Level ${config.level}'),
                        _Pill(icon: Icons.local_fire_department_rounded, label: '${config.streak} day streak'),
                      ]),
                    ]),
                  ),
                ]),
                const SizedBox(height: 22),
                Text(config.heroTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 950),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) => Stack(children: [
                      Container(height: 15, color: Colors.white.withValues(alpha: .22)),
                      FractionallySizedBox(
                        widthFactor: value,
                        child: Container(height: 15, decoration: LinearGradient(colors: [config.warm, Colors.white]).toBoxDecoration()),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 9),
                Row(children: [
                  Text('${config.xp} / ${config.xpTarget} XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: onCelebrate,
                    icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                    label: Text(config.heroAction),
                    style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: config.primary),
                  ),
                ]),
              ]),
            ),
            Positioned(right: -52, top: -42, child: _Orb(size: 160, color: Colors.white.withValues(alpha: .12))),
            Positioned(right: 18, bottom: 72, child: _LottieBadge(color: config.warm)),
          ],
        ),
      ),
    );
  }
}

class _ContinueLearning extends StatelessWidget {
  const _ContinueLearning({required this.config});
  final PremiumDashboardConfig config;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 176,
        child: ListView.separated(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          itemCount: config.subjects.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, i) {
            final s = config.subjects[i];
            final lesson = config.continueLessons[i % config.continueLessons.length];
            return PressableScale(
              child: Container(
                width: 160,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [s.color, Color.lerp(s.color, Colors.black, .18)!]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: s.color.withValues(alpha: .28), blurRadius: 24, offset: const Offset(0, 14))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _IconCube(icon: s.icon, color: Colors.white),
                  const Spacer(),
                  Text(s.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(lesson, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: .78), fontWeight: FontWeight.w700, fontSize: 11)),
                  const SizedBox(height: 9),
                  ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: s.progress, minHeight: 7, color: Colors.white, backgroundColor: Colors.white24)),
                ]),
              ),
            );
          },
        ),
      );
}

class _DailyMissions extends StatelessWidget {
  const _DailyMissions({required this.config, required this.selected, required this.onTap});
  final PremiumDashboardConfig config;
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => _Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _IconBubble(icon: Icons.flag_rounded, color: config.warm),
            const SizedBox(width: 10),
            Expanded(child: Text(config.examMode ? 'Daily Goals & Challenges' : 'Daily Missions & Quest Rewards', style: Theme.of(context).textTheme.titleLarge)),
            Text('${selected + 1}/${config.missions.length}', style: TextStyle(color: config.primary, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 14),
          for (var i = 0; i < config.missions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PressableScale(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: i <= selected ? config.accent.withValues(alpha: .13) : Colors.white.withValues(alpha: .64),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: i <= selected ? config.accent.withValues(alpha: .42) : Colors.white),
                  ),
                  child: Row(children: [
                    Icon(i <= selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: i <= selected ? config.accent : Colors.black26),
                    const SizedBox(width: 11),
                    Expanded(child: Text(config.missions[i], style: const TextStyle(fontWeight: FontWeight.w800))),
                    Text('+${30 + i * 10} XP', style: TextStyle(color: config.primary, fontWeight: FontWeight.w900, fontSize: 12)),
                  ]),
                ),
              ),
            ),
        ]),
      );
}

class _RewardsStrip extends StatelessWidget {
  const _RewardsStrip({required this.config, required this.onOpen, required this.chestOpen});
  final PremiumDashboardConfig config;
  final VoidCallback onOpen;
  final bool chestOpen;

  @override
  Widget build(BuildContext context) => _Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _IconBubble(icon: Icons.workspace_premium_rounded, color: config.warm),
            const SizedBox(width: 10),
            Expanded(child: Text('XP Points & Badge System', style: Theme.of(context).textTheme.titleLarge)),
          ]),
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (final reward in config.rewards) _BadgeChip(label: reward, color: config.primary),
          ]),
          const SizedBox(height: 16),
          PressableScale(
            onTap: onOpen,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [config.warm, config.accent]), borderRadius: BorderRadius.circular(26)),
              child: Row(children: [
                AnimatedScale(duration: const Duration(milliseconds: 260), scale: chestOpen ? 1.18 : 1, child: const Text('Chest', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white))),
                const SizedBox(width: 14),
                Expanded(child: Text(chestOpen ? 'Magic Treasure Chest opened: +150 XP and a rare badge' : 'Magic Treasure Chest ready after today goals', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
                const Icon(Icons.lock_open_rounded, color: Colors.white),
              ]),
            ),
          ),
        ]),
      );
}

class _MentorAndCompanion extends StatelessWidget {
  const _MentorAndCompanion({required this.config, required this.onCelebrate});
  final PremiumDashboardConfig config;
  final VoidCallback onCelebrate;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
        final cards = [
          _InfoCard(icon: Icons.smart_toy_rounded, color: config.primary, title: config.mentorTitle, body: config.mentorMessage, action: 'Ask AI', onTap: onCelebrate),
          if (config.petMode)
            _InfoCard(icon: Icons.pets_rounded, color: config.accent, title: 'Pet Companion', body: 'Nova grows happier when you finish lessons, games, and streak goals.', action: 'Feed', onTap: onCelebrate)
          else
            _InfoCard(icon: Icons.calendar_month_rounded, color: config.accent, title: 'Smart Revision Planner', body: 'Auto-balances weak topics, mock tests, and exam dates into a daily plan.', action: 'Plan', onTap: onCelebrate),
        ];
        if (constraints.maxWidth > 640) return Row(children: cards.map((w) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: w))).toList());
        return Column(children: cards.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)).toList());
      });
}

class _MiniGames extends StatelessWidget {
  const _MiniGames({required this.config, required this.onTap});
  final PremiumDashboardConfig config;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.45,
        children: [
          _GameTile(icon: Icons.functions_rounded, title: 'Math Sprint', color: config.primary, onTap: onTap),
          _GameTile(icon: Icons.science_rounded, title: 'Lab Quest', color: config.accent, onTap: onTap),
          _GameTile(icon: Icons.menu_book_rounded, title: 'Word Wizard', color: config.warm, onTap: onTap),
          _GameTile(icon: Icons.memory_rounded, title: 'Code Arcade', color: config.secondary, onTap: onTap),
        ],
      );
}

class _SubjectAnalytics extends StatelessWidget {
  const _SubjectAnalytics({required this.config});
  final PremiumDashboardConfig config;

  @override
  Widget build(BuildContext context) => _Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final s in config.subjects)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(s.icon, color: s.color, size: 18), const SizedBox(width: 8), Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w900))), Text('${(s.progress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w900))]),
                const SizedBox(height: 7),
                ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: s.progress, minHeight: 9, color: s.color, backgroundColor: s.color.withValues(alpha: .13))),
                const SizedBox(height: 4),
                Text(s.detail, style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
        ]),
      );
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.config});
  final PremiumDashboardConfig config;

  @override
  Widget build(BuildContext context) => GlowPulse(
        color: config.accent,
        child: _Glass(
          gradient: LinearGradient(colors: [Colors.white.withValues(alpha: .90), config.accent.withValues(alpha: .18)]),
          child: Row(children: [
            _IconCube(icon: Icons.emoji_events_rounded, color: config.accent),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(config.challengeTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(config.challengeDetail, style: Theme.of(context).textTheme.bodyMedium),
            ])),
            Icon(Icons.chevron_right_rounded, color: config.primary),
          ]),
        ),
      );
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard({required this.config});
  final PremiumDashboardConfig config;

  @override
  Widget build(BuildContext context) => _Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_IconBubble(icon: Icons.leaderboard_rounded, color: config.primary), const SizedBox(width: 10), Expanded(child: Text('Leaderboard', style: Theme.of(context).textTheme.titleLarge))]),
          const SizedBox(height: 12),
          for (var i = 0; i < config.leaderboard.length; i++)
            _ListLine(icon: i == 0 ? Icons.workspace_premium_rounded : Icons.person_rounded, color: i == 1 ? config.accent : config.primary, title: config.leaderboard[i], subtitle: i == 1 ? 'You are climbing fast' : '${4200 - i * 360} XP this week'),
        ]),
      );
}

class _Upcoming extends StatelessWidget {
  const _Upcoming({required this.config});
  final PremiumDashboardConfig config;

  @override
  Widget build(BuildContext context) => _Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_IconBubble(icon: Icons.event_rounded, color: config.secondary), const SizedBox(width: 10), Expanded(child: Text('Upcoming Classes & Exams', style: Theme.of(context).textTheme.titleLarge))]),
          const SizedBox(height: 12),
          for (final item in config.upcoming) _ListLine(icon: Icons.schedule_rounded, color: config.secondary, title: item, subtitle: 'Live reminder enabled'),
        ]),
      );
}

class _XpAnalytics extends StatelessWidget {
  const _XpAnalytics({required this.config});
  final PremiumDashboardConfig config;

  @override
  Widget build(BuildContext context) => _Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_IconBubble(icon: Icons.bar_chart_rounded, color: config.accent), const SizedBox(width: 10), Expanded(child: Text(config.analyticsTitle, style: Theme.of(context).textTheme.titleLarge))]),
          const SizedBox(height: 18),
          SizedBox(
            height: 132,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (var i = 0; i < config.analyticsValues.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: config.analyticsValues[i]),
                      duration: Duration(milliseconds: 620 + i * 80),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, __) => Container(
                        height: 118 * value,
                        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [config.accent, config.primary]), borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 8),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('M'), Text('T'), Text('W'), Text('T'), Text('F'), Text('S'), Text('S')]),
        ]),
      );
}

class _Recommendations extends StatelessWidget {
  const _Recommendations({required this.config});
  final PremiumDashboardConfig config;

  @override
  Widget build(BuildContext context) => _Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_IconBubble(icon: Icons.tips_and_updates_rounded, color: config.warm), const SizedBox(width: 10), Expanded(child: Text(config.examMode ? 'Personalized Recommendations' : 'Achievement Center', style: Theme.of(context).textTheme.titleLarge))]),
          const SizedBox(height: 12),
          for (final item in config.recommendations) _ListLine(icon: Icons.auto_awesome_rounded, color: config.warm, title: item, subtitle: 'Matched to your learning pattern'),
        ]),
      );
}

class _FunFact extends StatelessWidget {
  const _FunFact({required this.config});
  final PremiumDashboardConfig config;

  @override
  Widget build(BuildContext context) => _Glass(
        gradient: LinearGradient(colors: [config.warm.withValues(alpha: .18), Colors.white.withValues(alpha: .88)]),
        child: Row(children: [
          _IconCube(icon: Icons.lightbulb_rounded, color: config.warm),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Fun Fact Card', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 5),
            Text(config.funFact, style: Theme.of(context).textTheme.bodyMedium),
          ])),
        ]),
      );
}

class _ProgressCastle extends StatelessWidget {
  const _ProgressCastle({required this.config});
  final PremiumDashboardConfig config;

  @override
  Widget build(BuildContext context) => _Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_IconBubble(icon: Icons.castle_rounded, color: config.primary), const SizedBox(width: 10), Expanded(child: Text('Progress Castle', style: Theme.of(context).textTheme.titleLarge))]),
          const SizedBox(height: 16),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (var i = 0; i < config.subjects.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500 + i * 80),
                      height: 58 + config.subjects[i].progress * 72,
                      decoration: BoxDecoration(gradient: LinearGradient(colors: [config.subjects[i].color, config.primary]), borderRadius: BorderRadius.circular(18)),
                      child: Icon(config.subjects[i].icon, color: Colors.white),
                    ),
                    const SizedBox(height: 7),
                    Text(config.subjects[i].name.split(' ').first, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                  ]),
                ),
              ),
          ]),
        ]),
      );
}

class _Journey extends StatelessWidget {
  const _Journey({required this.config});
  final PremiumDashboardConfig config;

  @override
  Widget build(BuildContext context) => _Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_IconBubble(icon: Icons.route_rounded, color: config.primary), const SizedBox(width: 10), Expanded(child: Text(config.examMode ? 'Progress Journey' : 'Goal Progress Dashboard', style: Theme.of(context).textTheme.titleLarge))]),
          const SizedBox(height: 14),
          for (var i = 0; i < config.subjects.length; i++) _ListLine(icon: config.subjects[i].icon, color: config.subjects[i].color, title: config.subjects[i].name, subtitle: config.subjects[i].detail),
        ]),
      );
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({required this.config});
  final PremiumDashboardConfig config;

  @override
  Widget build(BuildContext context) => _Glass(
        gradient: LinearGradient(colors: [config.primary.withValues(alpha: .92), config.secondary.withValues(alpha: .86)]),
        child: Row(children: [
          const Icon(Icons.timer_rounded, color: Colors.white, size: 38),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(config.examCountdown!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 4),
            Text('Board Exam Countdown', style: TextStyle(color: Colors.white.withValues(alpha: .76), fontWeight: FontWeight.w800)),
          ])),
        ]),
      );
}

class _PrepHub extends StatelessWidget {
  const _PrepHub({required this.config});
  final PremiumDashboardConfig config;

  @override
  Widget build(BuildContext context) => _Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_IconBubble(icon: Icons.school_rounded, color: config.primary), const SizedBox(width: 10), Expanded(child: Text(config.prepHubTitle ?? 'Preparation Hub', style: Theme.of(context).textTheme.titleLarge))]),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: [for (final item in config.prepHubItems) _BadgeChip(label: item, color: config.secondary)]),
        ]),
      );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.color, required this.title, required this.body, required this.action, required this.onTap});
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_IconCube(icon: icon, color: color), const Spacer(), TextButton(onPressed: onTap, child: Text(action))]),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ]),
      );
}

class _GameTile extends StatelessWidget {
  const _GameTile({required this.icon, required this.title, required this.color, required this.onTap});
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PressableScale(
        onTap: onTap,
        child: _Glass(
          padding: const EdgeInsets.all(14),
          borderColor: color,
          child: Row(children: [_IconCube(icon: icon, color: color), const SizedBox(width: 11), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)))]),
        ),
      );
}

class _ListLine extends StatelessWidget {
  const _ListLine({required this.icon, required this.color, required this.title, required this.subtitle});
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .66), borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            _IconBubble(icon: icon, color: color),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(subtitle, style: Theme.of(context).textTheme.bodySmall)])),
            Icon(Icons.chevron_right_rounded, color: color),
          ]),
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.icon);
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ]);
}

class _Glass extends StatelessWidget {
  const _Glass({required this.child, this.padding = const EdgeInsets.all(18), this.borderColor, this.gradient});
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient ?? LinearGradient(colors: [Colors.white.withValues(alpha: .84), Colors.white.withValues(alpha: .58)]),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: (borderColor ?? Colors.white).withValues(alpha: .55), width: 1.2),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .07), blurRadius: 30, offset: const Offset(0, 18))],
            ),
            child: child,
          ),
        ),
      );
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: color.withValues(alpha: .14), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      );
}

class _IconCube extends StatelessWidget {
  const _IconCube({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withValues(alpha: .92), Color.lerp(color, Colors.black, .18)!]),
          borderRadius: BorderRadius.circular(17),
          boxShadow: [BoxShadow(color: color.withValues(alpha: .28), blurRadius: 16, offset: const Offset(0, 9))],
        ),
        child: Icon(icon, color: Colors.white),
      );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: BorderRadius.circular(99), border: Border.all(color: Colors.white24)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: Colors.white, size: 15), const SizedBox(width: 6), Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11))]),
      );
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(99), border: Border.all(color: color.withValues(alpha: .24))),
        child: Text(label, style: TextStyle(color: Color.lerp(color, Colors.black, .20), fontWeight: FontWeight.w900, fontSize: 12)),
      );
}

class _LottieBadge extends StatefulWidget {
  const _LottieBadge({required this.color});
  final Color color;

  @override
  State<_LottieBadge> createState() => _LottieBadgeState();
}

class _LottieBadgeState extends State<_LottieBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, math.sin(_controller.value * math.pi) * -8),
          child: Transform.rotate(
            angle: (_controller.value - .5) * .18,
            child: Icon(Icons.stars_rounded, color: widget.color.withValues(alpha: .86), size: 42),
          ),
        ),
      );
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}

extension on Gradient {
  BoxDecoration toBoxDecoration() => BoxDecoration(gradient: this);
}
