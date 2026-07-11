import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/app_models.dart';

class DotGridBackground extends StatelessWidget {
  const DotGridBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _DotPainter(), child: child);
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.heading.withValues(alpha: .05);
    for (double x = 14; x < size.width; x += 18) {
      for (double y = 14; y < size.height; y += 18) {
        canvas.drawCircle(Offset(x, y), 1.05, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.light = false, this.compact = false});
  final bool light;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : AppColors.heading;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: compact ? 31 : 38,
        height: compact ? 31 : 38,
        decoration: BoxDecoration(color: light ? Colors.white : AppColors.orange, shape: BoxShape.circle),
        child: Icon(Icons.auto_awesome_rounded, size: compact ? 17 : 21, color: light ? AppColors.navy : Colors.white),
      ),
      const SizedBox(width: 10),
      Text('EduNova', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: compact ? 20 : 24, letterSpacing: -.8)),
    ]);
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle, this.trailing, this.showBack = true});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBack;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Only render a back arrow if there's actually somewhere to pop back
      // to (this screen was `push`ed). Screens reached from the drawer via
      // `go` have nothing to pop to, so they get a menu button that opens
      // the drawer instead — never a dead back arrow.
      Builder(builder: (context) {
        final canPop = showBack && context.canPop();
        return Row(children: [
          RoundIconButton(
            icon: canPop ? Icons.arrow_back_rounded : Icons.menu_rounded,
            onTap: canPop
                ? () => context.pop()
                : () => Scaffold.of(context).openDrawer(),
          ),
          const SizedBox(width: 14),
        ]);
      }),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium)],
      ])),
      if (trailing != null) trailing!,
    ]),
  );
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.onTap, this.dark = false, this.badge = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool dark;
  final bool badge;

  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, children: [
    Material(color: dark ? AppColors.navy : Colors.white, shape: const CircleBorder(), child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: Padding(padding: const EdgeInsets.all(12), child: Icon(icon, size: 21, color: dark ? Colors.white : AppColors.navy)))),
    if (badge) Positioned(right: 1, top: 0, child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle))),
  ]);
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
    if (action != null) TextButton(onPressed: onTap, child: Text(action!, style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800))),
  ]);
}

class SearchBox extends StatelessWidget {
  const SearchBox({super.key, this.hint = 'Search courses, skills and careers', this.onFilter});
  final String hint;
  final VoidCallback? onFilter;

  @override
  Widget build(BuildContext context) => TextField(
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: onFilter == null ? null : IconButton(onPressed: onFilter, icon: const Icon(Icons.tune_rounded)),
    ),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.text, {super.key, this.color = AppColors.orangeSoft, this.foreground = AppColors.navy, this.icon});
  final String text;
  final Color color;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [if (icon != null) ...[Icon(icon, size: 14, color: foreground), const SizedBox(width: 5)], Text(text, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: foreground))]),
  );
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.value, this.size = 70, this.lineWidth = 8, this.color = AppColors.orange, this.label});
  final double value;
  final double size;
  final double lineWidth;
  final Color color;
  final String? label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: _RingPainter(value: value, width: lineWidth, color: color),
      child: Center(child: Text(label ?? '${(value * 100).round()}%', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.heading, fontSize: size * .2))),
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.width, required this.color});
  final double value;
  final double width;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset(width / 2, width / 2) & Size(size.width - width, size.height - width);
    canvas.drawArc(rect, 0, math.pi * 2, false, Paint()..color = AppColors.line..style = PaintingStyle.stroke..strokeWidth = width..strokeCap = StrokeCap.round);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = width..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.value != value;
}

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, required this.onTap, this.horizontal = false});
  final Course course;
  final VoidCallback onTap;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final image = Container(
      height: horizontal ? 104 : 142,
      width: horizontal ? 112 : double.infinity,
      decoration: BoxDecoration(color: course.color, borderRadius: BorderRadius.circular(22)),
      child: Stack(children: [
        Positioned(right: -16, top: -20, child: Container(width: 86, height: 86, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.navy.withValues(alpha: .09), width: 16)))),
        Center(child: Icon(course.icon, size: 48, color: AppColors.navy)),
        Positioned(left: 11, top: 11, child: StatusPill(course.category, color: Colors.white.withValues(alpha: .8))),
      ]),
    );
    final info = Padding(
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(course.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 7),
        Text('${course.level}  ·  ${course.duration}', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 10),
        if (course.progress > 0) ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: course.progress, minHeight: 6, color: AppColors.orange, backgroundColor: AppColors.line)) else Row(children: [const Icon(Icons.star_rounded, color: AppColors.orange, size: 18), Text(' ${course.rating}', style: const TextStyle(fontWeight: FontWeight.w800))]),
      ]),
    );
    return Card(child: InkWell(borderRadius: BorderRadius.circular(26), onTap: onTap, child: horizontal ? Row(children: [Padding(padding: const EdgeInsets.all(9), child: image), Expanded(child: info)]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.all(9), child: image), info])));
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.body, this.action});
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? action;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(36), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 88, height: 88, decoration: const BoxDecoration(color: AppColors.orangeSoft, shape: BoxShape.circle), child: Icon(icon, size: 42, color: AppColors.orange)),
    const SizedBox(height: 20), Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
    const SizedBox(height: 8), Text(body, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
    if (action != null) ...[const SizedBox(height: 22), ElevatedButton(onPressed: action, child: const Text('Explore now'))],
  ])));
}

class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.height = 100, this.width = double.infinity});
  final double height;
  final double width;
  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: controller, builder: (_, __) => Container(width: widget.width, height: widget.height, decoration: BoxDecoration(color: Color.lerp(AppColors.line, Colors.white, controller.value), borderRadius: BorderRadius.circular(24))));
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const destinations = [('/home', Icons.home_rounded, 'Home'), ('/courses', Icons.menu_book_rounded, 'Learn'), ('/mentor', Icons.auto_awesome_rounded, 'AI Mentor'), ('/explore', Icons.explore_rounded, 'Explore'), ('/profile', Icons.person_rounded, 'Profile')];

  @override
  Widget build(BuildContext context) {
    final index = math.max(0, destinations.indexWhere((d) => location.startsWith(d.$1)));
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: SafeArea(top: false, child: Container(
        margin: const EdgeInsets.fromLTRB(14, 4, 14, 10),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(27), boxShadow: [BoxShadow(color: AppColors.navy.withValues(alpha: .2), blurRadius: 24, offset: const Offset(0, 10))]),
        child: Row(children: List.generate(destinations.length, (i) {
          final selected = i == index;
          final item = destinations[i];
          return Expanded(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => context.go(item.$1), child: AnimatedContainer(duration: const Duration(milliseconds: 240), padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: selected ? AppColors.orange : Colors.transparent, borderRadius: BorderRadius.circular(20)), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(item.$2, color: Colors.white, size: 22), const SizedBox(height: 3), Text(item.$3, maxLines: 1, style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: selected ? FontWeight.w900 : FontWeight.w600))]))));
        })),
      )),
    );
  }
}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({super.key, required this.child, this.maxWidth = 720});
  final Widget child;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.topCenter, child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child));
}

// ---------------------------------------------------------------------------
// Shared dark/gradient design system components.
// Every screen should pull CTAs and surfaces from here so the look stays
// consistent instead of rebuilding buttons/cards inline.
// ---------------------------------------------------------------------------

/// A full-screen deep navy → purple gradient backdrop. Wrap a Scaffold body
/// (with a transparent Scaffold background) to get the reference look.
class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({super.key, required this.child, this.gradient});
  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(gradient: gradient ?? AppBrand.bgGradient),
        child: child,
      );
}

/// The single primary CTA used across the app: a stadium-shaped
/// purple→blue gradient pill button with an optional leading icon and a
/// built-in loading state.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.gradient,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final Gradient? gradient;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final button = Opacity(
      opacity: enabled ? 1 : .6,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient ?? AppBrand.heroGradient,
          borderRadius: BorderRadius.circular(AppBrand.radiusPill),
          boxShadow: [
            BoxShadow(
              color: AppBrand.purple.withValues(alpha: enabled ? .40 : 0),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppBrand.radiusPill),
            onTap: enabled ? onPressed : null,
            child: Center(
              child: loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20, color: Colors.white),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: .2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// A rounded, softly-bordered surface that sits slightly above the dark
/// background — the base card used everywhere instead of heavy shadows.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppBrand.radiusCard,
    this.color,
    this.borderColor,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppBrand.card) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AppBrand.line),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

/// Alias kept for call-sites that prefer the "SoftCard" name.
class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GlassCard(padding: padding, onTap: onTap, child: child);
}
