import 'package:flutter/material.dart';

import '../effects/adventure_effects.dart';
import '../theme/adventure_theme.dart';

/// AI Learning Buddy — a friendly floating owl mascot with rotating tips
/// and a tap-to-chat affordance.
class AiBuddyCard extends StatelessWidget {
  const AiBuddyCard({super.key, required this.tip, required this.onChat, required this.onNextTip});
  final String tip;
  final VoidCallback onChat;
  final VoidCallback onNextTip;

  @override
  Widget build(BuildContext context) => GlassCard(
        borderColor: AdventureColors.blue,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BobbingMascot(emoji: '🦉'),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Expanded(child: Text('Zuzu, your AI Buddy', style: AdventureText.h2)),
                    IconButton(
                      onPressed: onNextTip,
                      icon: const Icon(Icons.refresh_rounded, color: AdventureColors.blue),
                      tooltip: 'Another tip',
                      visualDensity: VisualDensity.compact,
                    ),
                  ]),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(tip),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AdventureColors.blue.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(tip, style: AdventureText.body.copyWith(color: AdventureColors.ink, fontStyle: FontStyle.italic)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PressableScale(
                    onTap: onChat,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(gradient: AdventureGradients.hero, borderRadius: BorderRadius.circular(16)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('Ask Zuzu a question', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _BobbingMascot extends StatefulWidget {
  const _BobbingMascot({required this.emoji});
  final String emoji;
  @override
  State<_BobbingMascot> createState() => _BobbingMascotState();
}

class _BobbingMascotState extends State<_BobbingMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ac,
        builder: (context, child) => Transform.translate(offset: Offset(0, -4 * _ac.value), child: child),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AdventureGradients.oceanForest,
            boxShadow: [BoxShadow(color: AdventureColors.blue.withValues(alpha: .35), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 30))),
        ),
      );
}

/// Pet Companion — a hatchling that grows happier / evolves with XP.
class PetCompanionCard extends StatelessWidget {
  const PetCompanionCard({super.key, required this.petName, required this.mood, required this.hunger, required this.onFeed, required this.onPlay});
  final String petName;
  final String mood; // e.g. "Happy", "Excited"
  final double hunger; // 0..1, 1 = full
  final VoidCallback onFeed;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) => GlassCard(
        borderColor: AdventureColors.lime,
        child: Row(
          children: [
            GlowPulse(
              color: AdventureColors.lime,
              radius: 40,
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AdventureGradients.growth),
                child: const Center(child: Text('🐲', style: TextStyle(fontSize: 38))),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$petName the Dragonling', style: AdventureText.h2.copyWith(fontSize: 16)),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Text('💚 ', style: TextStyle(fontSize: 12)),
                    Text('Mood: $mood', style: AdventureText.body.copyWith(fontSize: 12.5)),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(value: hunger, minHeight: 8, backgroundColor: AdventureColors.lime.withValues(alpha: .15), color: AdventureColors.lime),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _MiniAction(icon: Icons.restaurant_rounded, label: 'Feed', color: AdventureColors.orange, onTap: onFeed)),
                    const SizedBox(width: 8),
                    Expanded(child: _MiniAction(icon: Icons.sports_esports_rounded, label: 'Play', color: AdventureColors.blue, onTap: onPlay)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      );
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PressableScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)),
          ]),
        ),
      );
}

class MiniGame {
  const MiniGame({required this.title, required this.emoji, required this.color, required this.players});
  final String title;
  final String emoji;
  final Color color;
  final String players;

  static const all = [
    MiniGame(title: 'Number Ninja', emoji: '🥷', color: AdventureColors.blue, players: '2-min dash'),
    MiniGame(title: 'Word Wizard', emoji: '🧙', color: AdventureColors.yellowDeep, players: 'Spell & win'),
    MiniGame(title: 'Atom Blaster', emoji: '🚀', color: AdventureColors.lime, players: 'Solo quest'),
    MiniGame(title: 'Map Explorer', emoji: '🧭', color: AdventureColors.orange, players: 'Trivia race'),
  ];
}

/// Mini Learning Games grid — bite-sized, game-like subject practice.
class MiniGamesGrid extends StatelessWidget {
  const MiniGamesGrid({super.key, required this.onPlay});
  final ValueChanged<MiniGame> onPlay;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.35,
        children: MiniGame.all
            .map(
              (g) => PressableScale(
                onTap: () => onPlay(g),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: g.color.withValues(alpha: .28), blurRadius: 14, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [g.color.withValues(alpha: .9), g.color]),
                          boxShadow: [BoxShadow(color: g.color.withValues(alpha: .5), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Center(child: Text(g.emoji, style: const TextStyle(fontSize: 22))),
                      ),
                      const Spacer(),
                      Text(g.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AdventureColors.ink)),
                      const SizedBox(height: 2),
                      Text(g.players, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10.5, color: g.color)),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      );
}
