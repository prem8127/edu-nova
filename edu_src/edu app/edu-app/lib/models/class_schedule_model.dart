class ScheduledClass {
  final String id;
  final String courseId;
  final String teacherId;
  final String title;
  final DateTime dateTime;
  final int durationMinutes; // every EduNova live class is 1 hour by default
  final String? zoomLink; // manual link field, pasted by teacher

  const ScheduledClass({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.title,
    required this.dateTime,
    this.durationMinutes = 60,
    this.zoomLink,
  });

  DateTime get endTime => dateTime.add(Duration(minutes: durationMinutes));

  /// Used to gate the post-class doubt chat — a class only "counts" once
  /// it has finished, not just started.
  bool get hasEnded => DateTime.now().isAfter(endTime);

  ScheduledClass copyWith({
    String? zoomLink,
    DateTime? dateTime,
    int? durationMinutes,
  }) {
    return ScheduledClass(
      id: id,
      courseId: courseId,
      teacherId: teacherId,
      title: title,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      zoomLink: zoomLink ?? this.zoomLink,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'teacherId': teacherId,
        'title': title,
        'dateTime': dateTime.toIso8601String(),
        'durationMinutes': durationMinutes,
        'zoomLink': zoomLink,
      };

  factory ScheduledClass.fromJson(Map<String, dynamic> json) => ScheduledClass(
        id: json['id'] as String,
        courseId: json['courseId'] as String,
        teacherId: json['teacherId'] as String,
        title: json['title'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        durationMinutes: json['durationMinutes'] as int? ?? 60,
        zoomLink: json['zoomLink'] as String?,
      );
}
