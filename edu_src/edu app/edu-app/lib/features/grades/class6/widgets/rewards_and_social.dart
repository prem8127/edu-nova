import 'package:flutter/material.dart';

import '../effects/adventure_effects.dart';
import '../models.dart';
import '../theme/adventure_theme.dart';

/// XP Points & Badge System — horizontal shelf of earned/locked badges.
class BadgeShelf extends StatelessWidget {
  const BadgeShelf({super.key, required this.badges});
  final List<Badge_> badges;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 108,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: badges.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final b = badges[i];
            return Container(
              width: 88,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: (b.locked ? Colors.black : b.color).withValues(alpha: .12), blurRadius: 10, offset: const Offset(0, 6))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: b.locked ? null : RadialGradient(colors: [b.color.withValues(alpha: .85), b.color]),
                      color: b.locked ? Colors.black12 : null,
                    ),
                    child: Icon(b.locked ? Icons.lock_rounded : b.icon, color: b.locked ? Colors.black38 : Colors.white, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(b.label, textAlign: TextAlign.center, maxLines: 2, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: b.locked ? Colors.black38 : AdventureColors.ink)),
                ],
              ),
            );
          },
        ),
      );
}

/// Weekly Challenge — big countdown banner with a headline reward.
class WeeklyChallengeBanner extends StatelessWidget {
  const WeeklyChallengeBanner({super.key, required this.title, required this.progress, required this.reward, required this.daysLeft});
  final String title;
  final double progress;
  final String reward;
  final int daysLeft;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: AdventureGradients.growth,
          boxShadow: [BoxShadow(color: AdventureColors.lime.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .25), borderRadius: BorderRadius.circular(12)),
                child: Text('$daysLeft DAYS LEFT', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10.5, letterSpacing: .6)),
              ),
              const Spacer(),
              const Text('🏆', style: TextStyle(fontSize: 20)),
            ]),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 4),
            Text('Reward: $reward', style: TextStyle(color: Colors.white.withValues(alpha: .9), fontWeight: FontWeight.w700, fontSize: 12.5)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Colors.white.withValues(alpha: .28), color: Colors.white),
            ),
          ],
        ),
      );
}

/// Leaderboard — podium for top 3 plus a compact list for the rest.
class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard({super.key, required this.rows});
  final List<LeaderRow> rows;

  @override
  Widget build(BuildContext context) {
    final podium = rows.take(3).toList();
    final rest = rows.skip(3).toList();
    Widget podiumSpot(LeaderRow r, double height, Color color) => Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: r.rank == 1 ? 26 : 21, backgroundColor: color.withValues(alpha: .18), child: Text(r.emoji, style: TextStyle(fontSize: r.rank == 1 ? 24 : 19))),
              const SizedBox(height: 6),
              Text(r.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5), overflow: TextOverflow.ellipsis),
              Text('${r.xp} XP', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: color)),
              const SizedBox(height: 6),
              Container(
                height: height,
                decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 6),
                child: Text('${r.rank}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        );

    return GlassCard(
      borderColor: AdventureColors.yellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Text('🏅', style: TextStyle(fontSize: 20)), SizedBox(width: 8), Text('Realm Leaderboard', style: AdventureText.h2)]),
          const SizedBox(height: 14),
          if (podium.length == 3)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                podiumSpot(podium[1], 46, AdventureColors.blue),
                const SizedBox(width: 8),
                podiumSpot(podium[0], 66, AdventureColors.yellowDeep),
                const SizedBox(width: 8),
                podiumSpot(podium[2], 34, AdventureColors.orange),
              ],
            ),
          const SizedBox(height: 14),
          ...rest.map(
            (r) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: r.isMe ? AdventureColors.blue.withValues(alpha: .1) : Colors.white.withValues(alpha: .6),
                borderRadius: BorderRadius.circular(16),
                border: r.isMe ? Border.all(color: AdventureColors.blue.withValues(alpha: .4)) : null,
              ),
              child: Row(children: [
                Text('#${r.rank}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5, color: AdventureColors.inkSoft)),
                const SizedBox(width: 10),
                Text(r.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(child: Text(r.isMe ? '${r.name} (You)' : r.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
                Text('${r.xp} XP', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AdventureColors.ink)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Achievement Center — trophy wall grid.
class AchievementCenter extends StatelessWidget {
  const AchievementCenter({super.key, required this.badges});
  final List<Badge_> badges;

  @override
  Widget build(BuildContext context) => GlassCard(
        borderColor: AdventureColors.orange,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Text('🎖️', style: TextStyle(fontSize: 20)), SizedBox(width: 8), Text('Achievement Center', style: AdventureText.h2)]),
            const SizedBox(height: 4),
            const Text('Every quest completed leaves a trophy behind.', style: AdventureText.body),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 10,
              children: badges
                  .map(
                    (b) => Column(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: b.locked ? null : RadialGradient(colors: [b.color.withValues(alpha: .85), b.color]),
                            color: b.locked ? Colors.black12 : null,
                            boxShadow: b.locked ? null : [BoxShadow(color: b.color.withValues(alpha: .4), blurRadius: 8)],
                          ),
                          child: Icon(b.locked ? Icons.lock_outline_rounded : b.icon, color: b.locked ? Colors.black38 : Colors.white, size: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(b.label, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );
}

/// Upcoming Classes — simple timeline of the day's live sessions.
class UpcomingClassesCard extends StatelessWidget {
  const UpcomingClassesCard({super.key, required this.slots});
  final List<ClassSlot> slots;

  @override
  Widget build(BuildContext context) => GlassCard(
        borderColor: AdventureColors.blue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Text('📅', style: TextStyle(fontSize: 20)), SizedBox(width: 8), Text('Upcoming Classes', style: AdventureText.h2)]),
            const SizedBox(height: 12),
            ...List.generate(slots.length, (i) {
              final s = slots[i];
              final last = i == slots.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                      if (!last) Expanded(child: Container(width: 2, color: s.color.withValues(alpha: .25))),
                    ]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: last ? 0 : 16),
                        child: Row(children: [
                          Text(s.emoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.subject, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5)),
                                Text('${s.time} · ${s.teacher}', style: AdventureText.body.copyWith(fontSize: 11.5)),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
}

/// Weekly XP Analytics — a lightweight custom bar chart.
class WeeklyXpChart extends StatelessWidget {
  const WeeklyXpChart({super.key, required this.values, required this.labels});
  final List<double> values; // 0..1 normalized
  final List<String> labels;

  @override
  Widget build(BuildContext context) => GlassCard(
        borderColor: AdventureColors.blue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Text('📊', style: TextStyle(fontSize: 20)), SizedBox(width: 8), Text('Weekly XP Analytics', style: AdventureText.h2)]),
            const SizedBox(height: 4),
            const Text('You are on track to beat last week!', style: AdventureText.body),
            const SizedBox(height: 18),
            SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(values.length, (i) {
                  final isToday = i == values.length - 1;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: values[i]),
                            duration: Duration(milliseconds: 700 + i * 80),
                            curve: Curves.easeOutBack,
                            builder: (context, v, _) => Container(
                              height: 80 * v.clamp(0.0, 1.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: isToday ? [AdventureColors.orange, AdventureColors.yellow] : [AdventureColors.blue, AdventureColors.blueLight],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(labels[i], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isToday ? AdventureColors.orangeDeep : AdventureColors.inkSoft)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
}

/// Fun Fact Card — a flip card revealing a bite-sized fact.
class FunFactCard extends StatefulWidget {
  const FunFactCard({super.key, required this.fact});
  final String fact;

  @override
  State<FunFactCard> createState() => _FunFactCardState();
}

class _FunFactCardState extends State<FunFactCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  bool _revealed = false;

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  void _flip() {
    setState(() => _revealed = !_revealed);
    _revealed ? _ac.forward() : _ac.reverse();
  }

  @override
  Widget build(BuildContext context) => PressableScale(
        onTap: _flip,
        child: AnimatedBuilder(
          animation: _ac,
          builder: (context, child) {
            final angle = _ac.value * 3.14159;
            final showBack = _ac.value > .5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..setEntry(3, 2, .0012)..rotateY(angle),
              child: showBack ? Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateY(3.14159), child: _back()) : _front(),
            );
          },
        ),
      );

  Widget _front() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: AdventureGradients.energy),
        child: const Row(children: [
          Text('💡', style: TextStyle(fontSize: 26)),
          SizedBox(width: 12),
          Expanded(child: Text('Tap for today\'s Fun Fact!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15))),
          Icon(Icons.touch_app_rounded, color: Colors.white),
        ]),
      );

  Widget _back() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: AdventureGradients.oceanForest),
        child: Row(children: [
          const Text('🌟', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(child: Text(widget.fact, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5, height: 1.3))),
        ]),
      );
}
