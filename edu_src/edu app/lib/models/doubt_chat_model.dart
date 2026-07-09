/// A private 1:1 thread between exactly one student and one teacher.
/// Kept separate from group/course chat on purpose — doubt resolution
/// is intentionally not visible to other students.
class DoubtThread {
  final String id;
  final String studentId;
  final String teacherId;
  final String courseId;
  final DateTime createdAt;

  const DoubtThread({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.courseId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'teacherId': teacherId,
        'courseId': courseId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DoubtThread.fromJson(Map<String, dynamic> json) => DoubtThread(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        teacherId: json['teacherId'] as String,
        courseId: json['courseId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class DoubtMessage {
  final String id;
  final String threadId;
  final String senderId;
  final String text;
  final DateTime sentAt;

  const DoubtMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'threadId': threadId,
        'senderId': senderId,
        'text': text,
        'sentAt': sentAt.toIso8601String(),
      };

  factory DoubtMessage.fromJson(Map<String, dynamic> json) => DoubtMessage(
        id: json['id'] as String,
        threadId: json['threadId'] as String,
        senderId: json['senderId'] as String,
        text: json['text'] as String,
        sentAt: DateTime.parse(json['sentAt'] as String),
      );
}
