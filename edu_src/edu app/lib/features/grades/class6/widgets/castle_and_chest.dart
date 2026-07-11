import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../effects/adventure_effects.dart';
import '../theme/adventure_theme.dart';

/// THE SIGNATURE ELEMENT of the dashboard.
///
/// Progress Castle: a five-tier tower where each tier IS a subject realm.
/// The tower rises Math → Science → English → Social → Computer, and each
/// tier's windows glow in proportion to that realm's mastery — so the
/// castle's skyline literally encodes the child's report card. Tapping any
/// tier jumps into that realm.
class ProgressCastle extends StatefulWidget {
  const ProgressCastle({super.key, required this.realms, required this.onTapRealm});
  final List<Realm> realms;
  final ValueChanged<Realm> onTapRealm;

  @override
  State<ProgressCastle> createState() => _ProgressCastleState();
}

class _ProgressCastleState extends State<ProgressCastle> with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
  int? _sparkTier;

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overall = widget.realms.map((r) => r.progress).reduce((a, b) => a + b) / widget.realms.length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: 340,
        decoration: const BoxDecoration(gradient: AdventureGradients.sky),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AnimatedBuilder(
              animation: _drift,
              builder: (context, _) => CustomPaint(size: Size.infinite, painter: _CloudPainter(_drift.value)),
            ),
            const Positioned.fill(child: FloatingParticles(count: 10, colors: [AdventureColors.yellow, Colors.white], maxSize: 3, seed: 21)),
            Positioned(
              top: 16,
              left: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .85), borderRadius: BorderRadius.circular(16)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🏰', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Text('Progress Castle · ${(overall * 100).round()}% built', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, color: AdventureColors.ink)),
                ]),
              ),
            ),
            Positioned(
              bottom: 18,
              child: GestureDetector(
                onTapUp: (details) => _handleTap(details, context),
                child: SizedBox(
                  width: 260,
                  height: 270,
                  child: CustomPaint(
                    painter: _CastlePainter(realms: widget.realms, sparkTier: _sparkTier),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(TapUpDetails details, BuildContext context) {
    // Five tiers stacked bottom→top inside a 270-tall canvas.
    final localY = details.localPosition.dy;
    final tierHeight = 270 / widget.realms.length;
    final tierFromTop = (localY / tierHeight).floor().clamp(0, widget.realms.length - 1);
    final realmIndex = widget.realms.length - 1 - tierFromTop;
    final realm = widget.realms[realmIndex.clamp(0, widget.realms.length - 1)];
    setState(() => _sparkTier = realmIndex);
    widget.onTapRealm(realm);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _sparkTier = null);
    });
  }
}

class _CloudPainter extends CustomPainter {
  _CloudPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .8);
    void cloud(double xBase, double y, double scale) {
      final x = (xBase + t * size.width * .3) % (size.width + 120) - 60;
      canvas.drawCircle(Offset(x, y), 18 * scale, paint);
      canvas.drawCircle(Offset(x + 20 * scale, y + 4), 14 * scale, paint);
      canvas.drawCircle(Offset(x - 18 * scale, y + 6), 12 * scale, paint);
    }

    cloud(20, 40, 1);
    cloud(160, 70, .7);
    cloud(-40, 100, .5);
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => true;
}

class _CastlePainter extends CustomPainter {
  _CastlePainter({required this.realms, required this.sparkTier});
  final List<Realm> realms;
  final int? sparkTier;

  @override
  void paint(Canvas canvas, Size size) {
    final n = realms.length;
    final tierH = size.height / n;
    // Draw from bottom (index 0) to top (index n-1), each tier a bit narrower.
    for (var i = 0; i < n; i++) {
      final realm = realms[i];
      final widthFactor = 1.0 - (i * .13);
      final w = size.width * widthFactor;
      final left = (size.width - w) / 2;
      final top = size.height - tierH * (i + 1);
      final rect = Rect.fromLTWH(left, top, w, tierH + 2);
      final rrect = RRect.fromRectAndCorners(rect, topLeft: const Radius.circular(14), topRight: const Radius.circular(14));

      final bodyPaint = Paint()..shader = LinearGradient(colors: [realm.color, realm.deep], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(rect);
      canvas.drawRRect(rrect, bodyPaint);

      // Brick seam.
      canvas.drawRRect(rrect, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = Colors.white.withValues(alpha: .25));

      // Windows: filled = mastered portion of this realm.
      final windowCount = 3;
      final litCount = (realm.progress * windowCount).round();
      for (var wIdx = 0; wIdx < windowCount; wIdx++) {
        final wx = left + w * (wIdx + 1) / (windowCount + 1);
        final wy = top + tierH / 2;
        final lit = wIdx < litCount;
        final glowPaint = Paint()
          ..color = (lit ? AdventureColors.yellow : Colors.black).withValues(alpha: lit ? .95 : .18)
          ..maskFilter = lit ? const MaskFilter.blur(BlurStyle.normal, 4) : null;
        canvas.drawCircle(Offset(wx, wy), 5.5, glowPaint);
      }

      // Sparkle ring if this tier was just tapped.
      if (sparkTier == i) {
        canvas.drawRRect(
          rrect.inflate(4),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = AdventureColors.yellow.withValues(alpha: .9),
        );
      }
    }

    // Flag on top tier.
    final topTierTop = size.height - tierH * n;
    final flagX = size.width / 2;
    canvas.drawLine(Offset(flagX, topTierTop), Offset(flagX, topTierTop - 30), Paint()..color = AdventureColors.ink..strokeWidth = 3);
    final flagPath = Path()
      ..moveTo(flagX, topTierTop - 30)
      ..lineTo(flagX + 24, topTierTop - 22)
      ..lineTo(flagX, topTierTop - 14)
      ..close();
    canvas.drawPath(flagPath, Paint()..color = AdventureColors.orange);
  }

  @override
  bool shouldRepaint(covariant _CastlePainter oldDelegate) => oldDelegate.sparkTier != sparkTier || oldDelegate.realms != realms;
}

/// Magic Treasure Chest — locked until missions are done, then a satisfying
/// tap-to-open moment with a bouncing lid, coin burst and confetti.
class TreasureChest extends StatefulWidget {
  const TreasureChest({super.key, required this.locked, required this.opened, required this.rewardXp, required this.rewardCoins, required this.onOpen});
  final bool locked;
  final bool opened;
  final int rewardXp;
  final int rewardCoins;
  final VoidCallback onOpen;

  @override
  State<TreasureChest> createState() => _TreasureChestState();
}

class _TreasureChestState extends State<TreasureChest> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));

  @override
  void initState() {
    super.initState();
    if (widget.opened) _ac.value = 1;
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  void _tap() {
    if (widget.locked || widget.opened) return;
    widget.onOpen();
    _ac.forward();
  }

  @override
  Widget build(BuildContext context) => PressableScale(
        onTap: _tap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.locked ? [Colors.grey.shade400, Colors.grey.shade500] : const [AdventureColors.yellow, AdventureColors.orangeDeep],
            ),
            boxShadow: [BoxShadow(color: (widget.locked ? Colors.black : AdventureColors.orange).withValues(alpha: .3), blurRadius: 18, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 76,
                height: 64,
                child: AnimatedBuilder(
                  animation: _ac,
                  builder: (context, _) => CustomPaint(painter: _ChestPainter(openT: _ac.value, locked: widget.locked)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.locked ? 'Magic Treasure Chest' : (widget.opened ? 'Treasure claimed!' : 'Chest unlocked!'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15.5),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.locked
                          ? 'Finish today\'s missions to unlock it'
                          : (widget.opened ? '+${widget.rewardXp} XP · +${widget.rewardCoins} coins added' : 'Tap to open · +${widget.rewardXp} XP · +${widget.rewardCoins} coins'),
                      style: TextStyle(color: Colors.white.withValues(alpha: .92), fontWeight: FontWeight.w700, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              if (widget.locked) const Icon(Icons.lock_rounded, color: Colors.white, size: 22) else if (!widget.opened) const Icon(Icons.touch_app_rounded, color: Colors.white, size: 22),
            ],
          ),
        ),
      );
}

class _ChestPainter extends CustomPainter {
  _ChestPainter({required this.openT, required this.locked});
  final double openT; // 0 closed -> 1 open
  final bool locked;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyColor = locked ? Colors.brown.shade300 : Colors.brown.shade400;
    final bandColor = locked ? Colors.grey.shade300 : AdventureColors.yellowLight;

    final bodyRect = Rect.fromLTWH(4, size.height * .45, size.width - 8, size.height * .5);
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, const Radius.circular(8));
    canvas.drawRRect(bodyRRect, Paint()..color = bodyColor);
    canvas.drawRect(Rect.fromLTWH(4, size.height * .68, size.width - 8, 5), Paint()..color = bandColor);

    // Lid rotates open around the top-back hinge.
    canvas.save();
    canvas.translate(size.width / 2, size.height * .45);
    canvas.rotate(-openT * 0.9);
    final lidRect = Rect.fromLTWH(-size.width / 2 + 4, -size.height * .32, size.width - 8, size.height * .32);
    final lidRRect = RRect.fromRectAndCorners(lidRect, topLeft: const Radius.circular(14), topRight: const Radius.circular(14));
    canvas.drawRRect(lidRRect, Paint()..color = locked ? Colors.brown.shade400 : Colors.brown.shade500);
    canvas.drawCircle(Offset(0, -2), 4, Paint()..color = bandColor);
    canvas.restore();

    // Golden glow / sparkle rays once opened.
    if (openT > .3) {
      final alpha = ((openT - .3) / .7).clamp(0.0, 1.0);
      final glow = Paint()
        ..color = AdventureColors.yellow.withValues(alpha: .5 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(size.width / 2, size.height * .3), 22 * alpha + 6, glow);
      final rand = math.Random(3);
      for (var i = 0; i < 6; i++) {
        final ang = (i / 6) * math.pi * 2;
        final len = 16 * alpha;
        final center = Offset(size.width / 2, size.height * .3);
        final p1 = center + Offset(math.cos(ang), math.sin(ang)) * 8;
        final p2 = center + Offset(math.cos(ang), math.sin(ang)) * (8 + len);
        canvas.drawLine(p1, p2, Paint()..color = AdventureColors.yellow.withValues(alpha: alpha)..strokeWidth = 2);
        rand.nextDouble(); // keep deterministic ray pattern stable across rebuilds
      }
    }

    if (locked) {
      final lockCenter = Offset(size.width / 2, size.height * .5);
      canvas.drawCircle(lockCenter, 9, Paint()..color = Colors.grey.shade600);
      canvas.drawRect(Rect.fromCenter(center: lockCenter, width: 6, height: 8), Paint()..color = Colors.grey.shade200);
    }
  }

  @override
  bool shouldRepaint(covariant _ChestPainter oldDelegate) => oldDelegate.openT != openT || oldDelegate.locked != locked;
}
