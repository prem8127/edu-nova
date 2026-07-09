import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/revenue_provider.dart';

/// A lightweight, dependency-free bar chart for revenue trends. Avoids
/// pulling in a charting package for what is fundamentally a handful of
/// bars — keeps the app's dependency footprint small.
class RevenueBarChart extends StatelessWidget {
  const RevenueBarChart({
    super.key,
    required this.points,
    this.color = AppBrand.purple,
    this.height = 160,
  });

  final List<RevenuePoint> points;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty || points.every((p) => p.amount == 0)) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('No revenue in this period yet',
              style: TextStyle(color: AppBrand.inkSoft, fontSize: 13)),
        ),
      );
    }

    final maxAmount = points.map((p) => p.amount).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final point in points)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      point.amount >= 1000
                          ? '₹${(point.amount / 1000).toStringAsFixed(1)}k'
                          : '₹${point.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 9.5, color: AppBrand.inkSoft, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      child: Container(
                        height: maxAmount == 0
                            ? 4
                            : (4 + (point.amount / maxAmount) * (height - 46)).clamp(4, height - 46),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [color, color.withValues(alpha: .45)],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(point.label,
                        style: const TextStyle(fontSize: 10.5, color: AppBrand.inkSoft)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Chip row for switching between [RevenuePeriod]s — shared by the admin
/// revenue dashboard and the teacher earnings screen.
class RevenuePeriodSelector extends StatelessWidget {
  const RevenuePeriodSelector({super.key, required this.selected, required this.onChanged});

  final RevenuePeriod selected;
  final ValueChanged<RevenuePeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final period in RevenuePeriod.values) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected == period ? AppBrand.purple : AppBrand.card,
                  borderRadius: BorderRadius.circular(AppBrand.radiusPill),
                  border: Border.all(
                    color: selected == period ? Colors.transparent : AppBrand.line,
                  ),
                ),
                child: Center(
                  child: Text(
                    period.label,
                    style: TextStyle(
                      color: selected == period ? Colors.white : AppBrand.inkSoft,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (period != RevenuePeriod.values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}
