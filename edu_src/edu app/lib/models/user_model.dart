import '../core/constants/app_enums.dart';

/// Single user model shared by student/teacher/admin. Role-specific fields
/// are nullable rather than splitting into 3 classes — keeps local
/// persistence (JSON) trivial and mirrors how a real backend user table
/// would likely look (one users table + role column).
class AppUser {
  final String id;
  final String name;
  final UserRole role;

  // Student-only (collected at onboarding)
  final Grade? grade;
  final int? age;

  // Teacher-only
  final List<Subject> assignedSubjects;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.grade,
    this.age,
    this.assignedSubjects = const [],
  });

  AppUser copyWith({
    String? name,
    Grade? grade,
    int? age,
    List<Subject>? assignedSubjects,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      role: role,
      grade: grade ?? this.grade,
      age: age ?? this.age,
      assignedSubjects: assignedSubjects ?? this.assignedSubjects,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.name,
        'grade': grade?.name,
        'age': age,
        'assignedSubjects': assignedSubjects.map((s) => s.name).toList(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      role: UserRole.values.byName(json['role'] as String),
      grade: json['grade'] != null
          ? Grade.values.byName(json['grade'] as String)
          : null,
      age: json['age'] as int?,
      assignedSubjects: (json['assignedSubjects'] as List<dynamic>? ?? [])
          .map((s) => Subject.values.byName(s as String))
          .toList(),
    );
  }
}
