import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/adventure_theme.dart';

/// A frosted "glassmorphism" surface: blurred, semi-transparent, glowing rim.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderColor,
    this.radius = 30,
    this.gradient,
    this.blur = 18,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final double radius;
  final Gradient? gradient;
  final double blur;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white.withValues(alpha: .78), Colors.white.withValues(alpha: .52)],
                  ),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: (borderColor ?? Colors.white).withValues(alpha: .55), width: 1.4),
              boxShadow: [BoxShadow(color: AdventureColors.ink.withValues(alpha: .06), blurRadius: 24, offset: const Offset(0, 12))],
            ),
            child: child,
          ),
        ),
      );
}

/// Wraps a child in a soft, breathing colored glow — used to make key
/// elements (chest, buddy, streak flame) feel alive and "tappable".
class GlowPulse extends StatefulWidget {
  const GlowPulse({super.key, required this.child, required this.color, this.minBlur = 12, this.maxBlur = 30, this.radius = 30});
  final Widget child;
  final Color color;
  final double minBlur;
  final double maxBlur;
  final double radius;

  @override
  State<GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<GlowPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900))..repeat(reverse: true);

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ac,
        builder: (context, child) => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: .38 + _ac.value * .18),
                blurRadius: widget.minBlur + (widget.maxBlur - widget.minBlur) * _ac.value,
                spreadRadius: 1 + _ac.value,
              ),
            ],
          ),
          child: child,
        ),
        child: widget.child,
      );
}

/// Tap-scale micro-interaction wrapper for any card/button.
class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? .96 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}

/// Ambient drifting particles (stars / sparkles) for backgrounds.
class FloatingParticles extends StatefulWidget {
  const FloatingParticles({super.key, this.count = 16, this.colors = const [Colors.white], this.maxSize = 5, this.seed = 7});
  final int count;
  final List<Color> colors;
  final double maxSize;
  final int seed;

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _Particle {
  _Particle({required this.dx, required this.dy, required this.size, required this.speed, required this.color, required this.phase});
  final double dx, dy, size, speed, phase;
  final Color color;
}

class _FloatingParticlesState extends State<FloatingParticles> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final r = math.Random(widget.seed);
    _particles = List.generate(
      widget.count,
      (_) => _Particle(
        dx: r.nextDouble(),
        dy: r.nextDouble(),
        size: 1.5 + r.nextDouble() * widget.maxSize,
        speed: .25 + r.nextDouble() * .6,
        color: widget.colors[r.nextInt(widget.colors.length)],
        phase: r.nextDouble(),
      ),
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _ac,
          builder: (context, _) => CustomPaint(size: Size.infinite, painter: _ParticlePainter(_particles, _ac.value)),
        ),
      );
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, this.t);
  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final ty = (p.dy - t * p.speed) % 1.0;
      final wobble = math.sin((t + p.phase) * math.pi * 2) * 8;
      final offset = Offset(p.dx * size.width + wobble, ty * size.height);
      final alpha = (math.sin((t + p.phase) * math.pi * 2) * .3 + .65).clamp(0.0, 1.0);
      canvas.drawCircle(offset, p.size, Paint()..color = p.color.withValues(alpha: alpha));
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

/// Controller that lets any widget below a [ConfettiLayer] trigger a burst.
class ConfettiController extends ChangeNotifier {
  final math.Random _rand = math.Random();
  List<_ConfettiPiece> pieces = const [];
  Offset origin = const Offset(.5, .35);

  void burst({int count = 42, Offset at = const Offset(.5, .35)}) {
    origin = at;
    pieces = List.generate(count, (_) => _ConfettiPiece.random(_rand));
    notifyListeners();
  }
}

class _ConfettiPiece {
  _ConfettiPiece({required this.angle, required this.speed, required this.color, required this.size, required this.spin});
  final double angle;
  final double speed;
  final Color color;
  final double size;
  final double spin;

  static _ConfettiPiece random(math.Random r) {
    const colors = [AdventureColors.blue, AdventureColors.lime, AdventureColors.orange, AdventureColors.yellow];
    return _ConfettiPiece(
      angle: r.nextDouble() * math.pi * 2,
      speed: 60 + r.nextDouble() * 170,
      color: colors[r.nextInt(colors.length)],
      size: 5 + r.nextDouble() * 6,
      spin: (r.nextDouble() - .5) * 12,
    );
  }
}

/// Wraps [child] and overlays an animated confetti burst whenever
/// [controller].burst() is called — used for reward/celebration moments.
class ConfettiLayer extends StatefulWidget {
  const ConfettiLayer({super.key, required this.controller, required this.child});
  final ConfettiController controller;
  final Widget child;

  @override
  State<ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<ConfettiLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700));

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onBurst);
  }

  void _onBurst() => _ac
    ..reset()
    ..forward();

  @override
  void dispose() {
    widget.controller.removeListener(_onBurst);
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          widget.child,
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ac,
              builder: (context, _) => CustomPaint(
                size: Size.infinite,
                painter: _ConfettiPainter(pieces: widget.controller.pieces, origin: widget.controller.origin, t: _ac.value),
              ),
            ),
          ),
        ],
      );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.pieces, required this.origin, required this.t});
  final List<_ConfettiPiece> pieces;
  final Offset origin;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final fade = (1 - t).clamp(0.0, 1.0);
    final start = Offset(origin.dx * size.width, origin.dy * size.height);
    for (final p in pieces) {
      final dx = math.cos(p.angle) * p.speed * t;
      final dy = math.sin(p.angle) * p.speed * t + 280 * t * t;
      final pos = start + Offset(dx, dy);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * t * math.pi);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 1.6),
        Paint()..color = p.color.withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

/// Small pill used across the dashboard for stat callouts (XP, coins…).
class GlowStat extends StatelessWidget {
  const GlowStat({super.key, required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withValues(alpha: .35), blurRadius: 12, offset: const Offset(0, 5))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color)),
        ]),
      );
}
