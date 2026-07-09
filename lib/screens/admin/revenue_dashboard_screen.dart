import 'package:flutter/material.dart';
import '../shared/app_drawer.dart';
import '../../core/constants/app_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/revenue_provider.dart';
import '../../shared/widgets/revenue_chart.dart';
import '../../shared/widgets/ui.dart';

class RevenueDashboardScreen extends ConsumerStatefulWidget {
  const RevenueDashboardScreen({super.key});

  @override
  ConsumerState<RevenueDashboardScreen> createState() => _RevenueDashboardScreenState();
}

class _RevenueDashboardScreenState extends ConsumerState<RevenueDashboardScreen> {
  RevenuePeriod _period = RevenuePeriod.monthly;

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(platformRevenueSummaryProvider(_period));
    final byTeacherAsync = ref.watch(revenueByTeacherProvider);

    return Scaffold(
      drawer: const AppDrawer(role: UserRole.admin),
      appBar: AppBar(title: const Text('Revenue Dashboard')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          summaryAsync.when(
            data: (summary) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Total Revenue',
                        value: summary.totalRevenue,
                        color: AppBrand.purple,
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        label: 'Platform Earnings',
                        value: summary.platformEarnings,
                        color: AppBrand.blue,
                        icon: Icons.savings_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Teacher Payouts',
                        value: summary.teacherPayouts,
                        color: AppBrand.green,
                        icon: Icons.groups_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CountCard(
                        label: 'Paid Enrollments',
                        value: summary.totalPaidTransactions,
                        color: AppBrand.amber,
                        icon: Icons.receipt_long_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Revenue trend',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppBrand.ink)),
                const SizedBox(height: 12),
                RevenuePeriodSelector(
                  selected: _period,
                  onChanged: (p) => setState(() => _period = p),
                ),
                const SizedBox(height: 16),
                GlassCard(child: RevenueBarChart(points: summary.trend)),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppBrand.inkSoft)),
          ),
          const SizedBox(height: 28),
          const Text('Revenue by teacher',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppBrand.ink)),
          const SizedBox(height: 12),
          byTeacherAsync.when(
            data: (rows) {
              if (rows.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No paid enrollments yet.',
                      style: TextStyle(color: AppBrand.inkSoft)),
                );
              }
              return Column(
                children: [
                  for (final row in rows)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppBrand.purple.withValues(alpha: .18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.co_present_rounded,
                                  color: AppBrand.purple, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(row.teacherName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppBrand.ink,
                                          fontSize: 14.5)),
                                  const SizedBox(height: 2),
                                  Text('${row.transactionCount} paid enrollments',
                                      style: const TextStyle(
                                          color: AppBrand.inkSoft, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text('₹${row.grossRevenue.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppBrand.green,
                                    fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppBrand.inkSoft)),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text('₹${value.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppBrand.ink)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppBrand.inkSoft, fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text('$value',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppBrand.ink)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppBrand.inkSoft, fontSize: 11.5)),
        ],
      ),
    );
  }
}
