enum TransactionStatus { success, refunded }

/// A single course-purchase payment event. This is the source-of-truth
/// record that both the admin revenue dashboard and the teacher earnings
/// view are computed from — neither screen keeps its own running totals,
/// they just aggregate over [TransactionModel]s so the numbers can never
/// drift out of sync.
class TransactionModel {
  final String id;
  final String studentId;
  final String courseId;
  final String teacherId;
  final double amount; // gross amount paid by the student, in ₹
  final TransactionStatus status;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.teacherId,
    required this.amount,
    required this.createdAt,
    this.status = TransactionStatus.success,
  });

  /// Platform keeps [platformFeePercent]% of every successful transaction;
  /// the rest is the teacher's net payout. Centralized here so the admin
  /// revenue dashboard and teacher earnings view always agree on the cut.
  static const double platformFeePercent = 20;

  double get platformFee =>
      status == TransactionStatus.success ? amount * platformFeePercent / 100 : 0;

  double get netToTeacher =>
      status == TransactionStatus.success ? amount - platformFee : 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'courseId': courseId,
        'teacherId': teacherId,
        'amount': amount,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        courseId: json['courseId'] as String,
        teacherId: json['teacherId'] as String,
        amount: (json['amount'] as num).toDouble(),
        status: TransactionStatus.values.byName(json['status'] as String? ?? 'success'),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
