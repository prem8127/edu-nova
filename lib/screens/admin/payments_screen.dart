import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/app_theme.dart';
import '../shared/app_drawer.dart';

enum _PayStatus { paid, pending, refunded, failed }

extension on _PayStatus {
  String get label => switch (this) {
        _PayStatus.paid => 'Paid',
        _PayStatus.pending => 'Pending',
        _PayStatus.refunded => 'Refunded',
        _PayStatus.failed => 'Failed',
      };
  Color get color => switch (this) {
        _PayStatus.paid => const Color(0xFF16A34A),
        _PayStatus.pending => const Color(0xFFF59E0B),
        _PayStatus.refunded => const Color(0xFF6366F1),
        _PayStatus.failed => const Color(0xFFEF4444),
      };
}

class _Payment {
  const _Payment(this.student, this.course, this.batch, this.amount, this.method, this.date, this.status);
  final String student;
  final String course;
  final String batch;
  final double amount;
  final String method;
  final String date;
  final _PayStatus status;
}

/// Admin — Payments. Payment history across the whole platform (course fee
/// collections), with status and quick filtering. Complements the Revenue
/// Dashboard (which aggregates totals/trends) by showing the individual
/// transaction-level record admins actually need when reconciling fees.
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  _PayStatus? _filter;

  static const _payments = <_Payment>[
    _Payment('Meher Reddy', 'Algebra Foundations', 'Class 8 — Morning', 4999, 'UPI', '10 Jul 2026', _PayStatus.paid),
    _Payment('Arjun Naidu', 'Physics in Motion', 'Intermediate 1 — Weekend', 6499, 'Card', '10 Jul 2026', _PayStatus.paid),
    _Payment('Sanjana Rao', 'The Water Cycle — Science', 'Class 10 — Evening', 3999, 'UPI', '9 Jul 2026', _PayStatus.pending),
    _Payment('Kavya Prasad', 'Business Basics', 'Class 10 — Evening', 5499, 'Net Banking', '9 Jul 2026', _PayStatus.paid),
    _Payment('Rohit Varma', 'Advanced Algebra', 'Class 8 — Morning', 4999, 'UPI', '8 Jul 2026', _PayStatus.failed),
    _Payment('Ishita Menon', 'Finance for Beginners', 'Intermediate 1 — Weekend', 7499, 'Card', '7 Jul 2026', _PayStatus.paid),
    _Payment('Vikram Chowdary', 'Content Creation 101', 'Class 10 — Evening', 3499, 'UPI', '6 Jul 2026', _PayStatus.refunded),
    _Payment('Ananya Pillai', 'Physics in Motion', 'Intermediate 1 — Weekend', 6499, 'UPI', '4 Jul 2026', _PayStatus.paid),
    _Payment('Divya Krishnan', 'Algebra Foundations', 'Class 8 — Morning', 4999, 'Card', '2 Jul 2026', _PayStatus.paid),
    _Payment('Farhan Sheikh', 'The Water Cycle — Science', 'Class 10 — Evening', 3999, 'UPI', '1 Jul 2026', _PayStatus.pending),
  ];

  List<_Payment> get _filtered =>
      _filter == null ? _payments : _payments.where((p) => p.status == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final total = _payments.where((p) => p.status == _PayStatus.paid).fold<double>(0, (s, p) => s + p.amount);
    final pending = _payments.where((p) => p.status == _PayStatus.pending).fold<double>(0, (s, p) => s + p.amount);
    final refunded = _payments.where((p) => p.status == _PayStatus.refunded).fold<double>(0, (s, p) => s + p.amount);

    return Scaffold(
      drawer: const AppDrawer(role: UserRole.admin),
      appBar: AppBar(title: const Text('Payments')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              Expanded(child: _SummaryCard(label: 'Collected', value: total, color: AppBrand.purple)),
              const SizedBox(width: 12),
              Expanded(child: _SummaryCard(label: 'Pending', value: pending, color: const Color(0xFFF59E0B))),
              const SizedBox(width: 12),
              Expanded(child: _SummaryCard(label: 'Refunded', value: refunded, color: const Color(0xFF6366F1))),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                for (final s in _PayStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _FilterChip(
                      label: s.label,
                      selected: _filter == s,
                      color: s.color,
                      onTap: () => setState(() => _filter = s),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('${_filtered.length} transactions', style: const TextStyle(color: AppBrand.inkSoft, fontSize: 12.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ..._filtered.map((p) => _PaymentRow(payment: p)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('₹${value.toStringAsFixed(0)}',
              style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppBrand.purple;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: c.withValues(alpha: .18),
      labelStyle: TextStyle(color: selected ? c : AppBrand.inkSoft, fontWeight: FontWeight.w700, fontSize: 12.5),
      side: BorderSide(color: selected ? c : AppBrand.inkSoft.withValues(alpha: .25)),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});
  final _Payment payment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppBrand.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppBrand.inkSoft.withValues(alpha: .12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppBrand.purple.withValues(alpha: .14),
            child: Text(payment.student[0], style: const TextStyle(color: AppBrand.purple, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.student, style: const TextStyle(fontWeight: FontWeight.w800, color: AppBrand.ink, fontSize: 13.5)),
                const SizedBox(height: 2),
                Text('${payment.course} · ${payment.batch}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppBrand.inkSoft, fontSize: 11.5)),
                const SizedBox(height: 2),
                Text('${payment.method} · ${payment.date}', style: const TextStyle(color: AppBrand.inkSoft, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${payment.amount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppBrand.ink, fontSize: 14)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: payment.status.color.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(payment.status.label,
                    style: TextStyle(color: payment.status.color, fontSize: 10.5, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
