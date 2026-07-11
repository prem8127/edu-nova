import '../core/constants/app_enums.dart';

/// Paid-course model: every course requires purchase unless price is
/// explicitly 0. There's no separate "isPaywalled" flag anymore — that
/// was redundant with price and let a course be both priced AND marked
/// free, which doesn't match "each individual course must be bought."
class CourseModel {
  final String id;
  final String title;
  final String description;
  final Subject subject;
  final Grade grade;
  final String teacherId;
  final double price; // 0 = free/intro course; >0 = must be purchased
  final String? gameId; // the single course-tied game, if any
  final List<String> quizIds;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.grade,
    required this.teacherId,
    required this.price,
    this.gameId,
    this.quizIds = const [],
  });

  bool get requiresPurchase => price > 0;

  CourseModel copyWith({
    String? title,
    String? description,
    double? price,
    String? gameId,
    List<String>? quizIds,
  }) {
    return CourseModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject,
      grade: grade,
      teacherId: teacherId,
      price: price ?? this.price,
      gameId: gameId ?? this.gameId,
      quizIds: quizIds ?? this.quizIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'subject': subject.name,
        'grade': grade.name,
        'teacherId': teacherId,
        'price': price,
        'gameId': gameId,
        'quizIds': quizIds,
      };

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        subject: Subject.values.byName(json['subject'] as String),
        grade: Grade.values.byName(json['grade'] as String),
        teacherId: json['teacherId'] as String,
        price: (json['price'] as num).toDouble(),
        gameId: json['gameId'] as String?,
        quizIds: (json['quizIds'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
      );
}
