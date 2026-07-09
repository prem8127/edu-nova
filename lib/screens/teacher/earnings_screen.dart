import 'package:flutter/material.dart';
import '../shared/app_drawer.dart';
import '../../core/constants/app_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/revenue_provider.dart';
import '../../shared/widgets/revenue_chart.dart';
import '../../shared/widgets/ui.dart';

class TeacherEarningsScreen extends ConsumerStatefulWidget {
  const TeacherEarningsScreen({super.key});

  @override
  ConsumerState<TeacherEarningsScreen> createState() => _TeacherEarningsScreenState();
}

class _TeacherEarningsScreenState extends ConsumerState<TeacherEarningsScreen> {
  RevenuePeriod _period = RevenuePeriod.monthly;

  @override
  Widget build(BuildContext context) {
    final teacherId = ref.watch(authControllerProvider).value?.id;
    if (teacherId == null) {
      return const Scaffold(body: Center(child: Text('Not signed in.')));
    }

    final summaryAsync = ref.watch(
      teacherEarningsSummaryProvider((teacherId: teacherId, period: _period)),
    );

    return Scaffold(
      drawer: const AppDrawer(role: UserRole.teacher),
      appBar: AppBar(title: const Text('Earnings')),
      body: summaryAsync.when(
        data: (summary) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: _EarningsMetric(
                    label: 'Net earnings',
                    value: summary.netEarnings,
                    color: AppBrand.green,
                    icon: Icons.savings_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EarningsMetric(
                    label: 'Gross revenue',
                    value: summary.grossRevenue,
                    color: AppBrand.purple,
                    icon: Icons.account_balance_wallet_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _EarningsMetric(
                    label: 'Platform fee (${TransactionModel.platformFeePercent.toStringAsFixed(0)}%)',
                    value: summary.platformFee,
                    color: AppBrand.blue,
                    icon: Icons.percent_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EarningsCountMetric(
                    label: 'Paying students',
                    value: summary.paidStudents,
                    color: AppBrand.amber,
                    icon: Icons.groups_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Earnings trend (net)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppBrand.ink)),
            const SizedBox(height: 12),
            RevenuePeriodSelector(
              selected: _period,
              onChanged: (p) => setState(() => _period = p),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: RevenueBarChart(points: summary.trend, color: AppBrand.green),
            ),
            const SizedBox(height: 28),
            const Text('Earnings by course',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppBrand.ink)),
            const SizedBox(height: 12),
            if (summary.byCourse.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No paid enrollments yet.', style: TextStyle(color: AppBrand.inkSoft)),
              )
            else
              for (final row in summary.byCourse)
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
                            color: AppBrand.green.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.menu_book_rounded, color: AppBrand.green, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(row.courseTitle,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800, color: AppBrand.ink, fontSize: 14.5)),
                              const SizedBox(height: 2),
                              Text('${row.purchaseCount} enrollment${row.purchaseCount == 1 ? '' : 's'}',
                                  style: const TextStyle(color: AppBrand.inkSoft, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('₹${row.netEarnings.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, color: AppBrand.green, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: AppBrand.inkSoft)),
        ),
      ),
    );
  }
}

class _EarningsMetric extends StatelessWidget {
  const _EarningsMetric({
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

class _EarningsCountMetric extends StatelessWidget {
  const _EarningsCountMetric({
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
