import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_model.dart';
import 'repository_providers.dart';

/// Every transaction ever recorded (all students, all teachers). Both the
/// admin revenue dashboard and the teacher earnings view derive from this
/// single provider so numbers can't drift apart.
final allTransactionsProvider = FutureProvider<List<TransactionModel>>((ref) async {
  return ref.watch(transactionRepositoryProvider).getAllTransactions();
});

final transactionsForTeacherProvider =
    FutureProvider.family<List<TransactionModel>, String>((ref, teacherId) async {
  final all = await ref.watch(allTransactionsProvider.future);
  return all.where((t) => t.teacherId == teacherId).toList();
});

enum RevenuePeriod { daily, weekly, monthly, yearly }

extension RevenuePeriodLabel on RevenuePeriod {
  String get label {
    switch (this) {
      case RevenuePeriod.daily:
        return 'Daily';
      case RevenuePeriod.weekly:
        return 'Weekly';
      case RevenuePeriod.monthly:
        return 'Monthly';
      case RevenuePeriod.yearly:
        return 'Yearly';
    }
  }

  /// How many buckets to show on the trend chart for this period.
  int get bucketCount {
    switch (this) {
      case RevenuePeriod.daily:
        return 7;
      case RevenuePeriod.weekly:
        return 6;
      case RevenuePeriod.monthly:
        return 6;
      case RevenuePeriod.yearly:
        return 4;
    }
  }
}

/// One bar on the revenue trend chart.
class RevenuePoint {
  final String label;
  final double amount;
  const RevenuePoint({required this.label, required this.amount});
}

/// Buckets [transactions] (successful only) into [period]-sized windows
/// ending today, oldest first — the shared aggregation logic behind both
/// the admin's platform-wide chart and a single teacher's earnings chart.
List<RevenuePoint> bucketTransactionsByPeriod(
  List<TransactionModel> transactions,
  RevenuePeriod period, {
  bool netToTeacher = false,
}) {
  final now = DateTime.now();
  final successful = transactions.where((t) => t.status == TransactionStatus.success).toList();
  final points = <RevenuePoint>[];

  for (var i = period.bucketCount - 1; i >= 0; i--) {
    late DateTime start;
    late DateTime end;
    late String label;

    switch (period) {
      case RevenuePeriod.daily:
        final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        start = day;
        end = day.add(const Duration(days: 1));
        label = _weekdayShort(day.weekday);
        break;
      case RevenuePeriod.weekly:
        final weekStart = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1))
            .subtract(Duration(days: 7 * i));
        start = weekStart;
        end = weekStart.add(const Duration(days: 7));
        label = 'W${_isoWeekNumber(weekStart)}';
        break;
      case RevenuePeriod.monthly:
        final monthDate = DateTime(now.year, now.month - i, 1);
        start = monthDate;
        end = DateTime(monthDate.year, monthDate.month + 1, 1);
        label = _monthShort(monthDate.month);
        break;
      case RevenuePeriod.yearly:
        final year = now.year - i;
        start = DateTime(year, 1, 1);
        end = DateTime(year + 1, 1, 1);
        label = '$year';
        break;
    }

    final bucketTotal = successful
        .where((t) => !t.createdAt.isBefore(start) && t.createdAt.isBefore(end))
        .fold<double>(0, (sum, t) => sum + (netToTeacher ? t.netToTeacher : t.amount));

    points.add(RevenuePoint(label: label, amount: bucketTotal));
  }

  return points;
}

String _weekdayShort(int weekday) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];

String _monthShort(int month) => const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][month - 1];

int _isoWeekNumber(DateTime date) {
  final dayOfYear = int.parse(_dayOfYear(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}

String _dayOfYear(DateTime date) =>
    date.difference(DateTime(date.year, 1, 1)).inDays.toString();

/// ── Admin: platform-wide revenue ────────────────────────────────────────

class PlatformRevenueSummary {
  final double totalRevenue; // gross, all-time, successful only
  final double platformEarnings; // platform's cut across all transactions
  final double teacherPayouts; // total paid out to teachers
  final int totalPaidTransactions;
  final List<RevenuePoint> trend;

  const PlatformRevenueSummary({
    required this.totalRevenue,
    required this.platformEarnings,
    required this.teacherPayouts,
    required this.totalPaidTransactions,
    required this.trend,
  });
}

final platformRevenueSummaryProvider =
    FutureProvider.family<PlatformRevenueSummary, RevenuePeriod>((ref, period) async {
  final all = await ref.watch(allTransactionsProvider.future);
  final successful = all.where((t) => t.status == TransactionStatus.success).toList();

  final total = successful.fold<double>(0, (sum, t) => sum + t.amount);
  final platformCut = successful.fold<double>(0, (sum, t) => sum + t.platformFee);

  return PlatformRevenueSummary(
    totalRevenue: total,
    platformEarnings: platformCut,
    teacherPayouts: total - platformCut,
    totalPaidTransactions: successful.length,
    trend: bucketTransactionsByPeriod(all, period),
  );
});

/// Revenue grouped by teacher — the rows of the admin revenue dashboard's
/// "top earning courses/teachers" list.
class TeacherRevenueRow {
  final String teacherId;
  final String teacherName;
  final double grossRevenue;
  final int transactionCount;
  const TeacherRevenueRow({
    required this.teacherId,
    required this.teacherName,
    required this.grossRevenue,
    required this.transactionCount,
  });
}

final revenueByTeacherProvider = FutureProvider<List<TeacherRevenueRow>>((ref) async {
  final all = await ref.watch(allTransactionsProvider.future);
  final userRepo = ref.watch(userRepositoryProvider);
  final successful = all.where((t) => t.status == TransactionStatus.success);

  final byTeacher = <String, List<TransactionModel>>{};
  for (final t in successful) {
    byTeacher.putIfAbsent(t.teacherId, () => []).add(t);
  }

  final rows = <TeacherRevenueRow>[];
  for (final entry in byTeacher.entries) {
    final teacher = await userRepo.getUserById(entry.key);
    rows.add(TeacherRevenueRow(
      teacherId: entry.key,
      teacherName: teacher?.name ?? 'Unknown teacher',
      grossRevenue: entry.value.fold<double>(0, (sum, t) => sum + t.amount),
      transactionCount: entry.value.length,
    ));
  }
  rows.sort((a, b) => b.grossRevenue.compareTo(a.grossRevenue));
  return rows;
});

/// ── Teacher: personal earnings ──────────────────────────────────────────

class TeacherEarningsSummary {
  final double grossRevenue; // all-time, from this teacher's courses
  final double platformFee;
  final double netEarnings; // what the teacher actually gets paid
  final int paidStudents;
  final List<RevenuePoint> trend; // net-to-teacher, per bucket
  final List<CourseEarningsRow> byCourse;

  const TeacherEarningsSummary({
    required this.grossRevenue,
    required this.platformFee,
    required this.netEarnings,
    required this.paidStudents,
    required this.trend,
    required this.byCourse,
  });
}

class CourseEarningsRow {
  final String courseId;
  final String courseTitle;
  final double netEarnings;
  final int purchaseCount;
  const CourseEarningsRow({
    required this.courseId,
    required this.courseTitle,
    required this.netEarnings,
    required this.purchaseCount,
  });
}

final teacherEarningsSummaryProvider = FutureProvider.family<TeacherEarningsSummary,
    ({String teacherId, RevenuePeriod period})>((ref, args) async {
  final transactions = await ref.watch(transactionsForTeacherProvider(args.teacherId).future);
  final courseRepo = ref.watch(courseRepositoryProvider);
  final successful = transactions.where((t) => t.status == TransactionStatus.success).toList();

  final gross = successful.fold<double>(0, (sum, t) => sum + t.amount);
  final fee = successful.fold<double>(0, (sum, t) => sum + t.platformFee);

  final byCourseMap = <String, List<TransactionModel>>{};
  for (final t in successful) {
    byCourseMap.putIfAbsent(t.courseId, () => []).add(t);
  }
  final byCourse = <CourseEarningsRow>[];
  for (final entry in byCourseMap.entries) {
    final course = await courseRepo.getCourseById(entry.key);
    byCourse.add(CourseEarningsRow(
      courseId: entry.key,
      courseTitle: course?.title ?? 'Unknown course',
      netEarnings: entry.value.fold<double>(0, (sum, t) => sum + t.netToTeacher),
      purchaseCount: entry.value.length,
    ));
  }
  byCourse.sort((a, b) => b.netEarnings.compareTo(a.netEarnings));

  return TeacherEarningsSummary(
    grossRevenue: gross,
    platformFee: fee,
    netEarnings: gross - fee,
    paidStudents: successful.map((t) => t.studentId).toSet().length,
    trend: bucketTransactionsByPeriod(transactions, args.period, netToTeacher: true),
    byCourse: byCourse,
  );
});
