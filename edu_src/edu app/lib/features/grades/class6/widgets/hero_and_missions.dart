import 'package:flutter/material.dart';

import '../effects/adventure_effects.dart';
import '../models.dart';
import '../theme/adventure_theme.dart';

/// Top hero banner: avatar, level ring, streak flame, XP progress.
class HeroBanner extends StatelessWidget {
  const HeroBanner({
    super.key,
    required this.name,
    required this.level,
    required this.streak,
    required this.xp,
    required this.xpTarget,
    required this.coins,
    required this.onAvatarTap,
  });

  final String name;
  final int level;
  final int streak;
  final int xp;
  final int xpTarget;
  final int coins;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final progress = (xp / xpTarget).clamp(0.0, 1.0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AdventureGradients.hero),
                ),
              ),
              Positioned.fill(
                child: FloatingParticles(count: 22, colors: const [Colors.white, AdventureColors.yellowLight], maxSize: 4, seed: 3),
              ),
              Positioned(
                right: -30,
                top: -30,
                child: Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .08))),
              ),
              Positioned(
                left: -20,
                bottom: -40,
                child: Container(width: 110, height: 110, decoration: BoxDecoration(shape: BoxShape.circle, color: AdventureColors.yellow.withValues(alpha: .16))),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PressableScale(
                          onTap: onAvatarTap,
                          child: GlowPulse(
                            color: AdventureColors.yellow,
                            radius: 40,
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AdventureGradients.gold,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Center(child: Text('🦁', style: TextStyle(fontSize: 32))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('WELCOME BACK, EXPLORER', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                              const SizedBox(height: 3),
                              Text('$name 🌟', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 8),
                              Row(children: [
                                _LevelChip(level: level),
                                const SizedBox(width: 8),
                                _StreakChip(streak: streak),
                              ]),
                            ],
                          ),
                        ),
                        GlowStat(icon: Icons.monetization_on_rounded, label: '$coins', color: AdventureColors.yellowDeep),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: AdventureColors.yellow, size: 18),
                        const SizedBox(width: 5),
                        Text('$xp / $xpTarget XP to Level ${level + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => Stack(children: [
                          Container(height: 14, color: Colors.white.withValues(alpha: .22)),
                          FractionallySizedBox(
                            widthFactor: value,
                            child: Container(height: 14, decoration: const BoxDecoration(gradient: AdventureGradients.energy)),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level});
  final int level;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .22), borderRadius: BorderRadius.circular(14)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.shield_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text('Level $level', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11.5)),
        ]),
      );
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak});
  final int streak;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: AdventureColors.orange, borderRadius: BorderRadius.circular(14)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('🔥', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text('$streak-day streak', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11.5)),
        ]),
      );
}

/// "Continue Learning" — horizontal shelf of in-progress lessons per realm.
class ContinueLearningSection extends StatelessWidget {
  const ContinueLearningSection({super.key, required this.realms, required this.onTapRealm});
  final List<Realm> realms;
  final ValueChanged<Realm> onTapRealm;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 168,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: realms.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, i) {
            final realm = realms[i];
            return PressableScale(
              onTap: () => onTapRealm(realm),
              child: Container(
                width: 148,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [realm.color, realm.deep]),
                  boxShadow: [BoxShadow(color: realm.color.withValues(alpha: .35), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .22), borderRadius: BorderRadius.circular(14)),
                      child: Center(child: Text(realm.emoji, style: const TextStyle(fontSize: 22))),
                    ),
                    const Spacer(),
                    Text(realm.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15.5)),
                    const SizedBox(height: 3),
                    Text('${(realm.progress * 100).round()}% complete', style: TextStyle(color: Colors.white.withValues(alpha: .85), fontWeight: FontWeight.w700, fontSize: 11)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(value: realm.progress, minHeight: 7, backgroundColor: Colors.white.withValues(alpha: .25), color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
}

/// Daily Missions & Quest Rewards checklist card.
class DailyMissionsCard extends StatelessWidget {
  const DailyMissionsCard({super.key, required this.missions, required this.onToggle});
  final List<Mission> missions;
  final ValueChanged<Mission> onToggle;

  @override
  Widget build(BuildContext context) {
    final doneCount = missions.where((m) => m.done).length;
    return GlassCard(
      borderColor: AdventureColors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🗺️', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            const Expanded(child: Text('Daily Missions', style: AdventureText.h2)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AdventureColors.orange.withValues(alpha: .15), borderRadius: BorderRadius.circular(14)),
              child: Text('$doneCount/${missions.length}', style: const TextStyle(color: AdventureColors.orangeDeep, fontWeight: FontWeight.w900, fontSize: 12.5)),
            ),
          ]),
          const SizedBox(height: 4),
          const Text('Finish quests today to unlock the Treasure Chest!', style: AdventureText.body),
          const SizedBox(height: 14),
          ...missions.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PressableScale(
                onTap: () => onToggle(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: m.done ? m.color.withValues(alpha: .12) : Colors.white.withValues(alpha: .7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: m.done ? m.color.withValues(alpha: .4) : Colors.transparent, width: 1.4),
                  ),
                  child: Row(children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: m.color.withValues(alpha: .18), shape: BoxShape.circle),
                      child: Icon(m.icon, color: m.color, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        m.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: AdventureColors.ink,
                          decoration: m.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    Text('+${m.xp} XP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, color: m.color)),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        m.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        key: ValueKey(m.done),
                        color: m.done ? AdventureColors.lime : Colors.black26,
                        size: 22,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
