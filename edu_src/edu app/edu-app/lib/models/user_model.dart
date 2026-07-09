import '../core/constants/app_enums.dart';

/// Single user model shared by student/teacher/admin. Role-specific fields
/// are nullable rather than splitting into 3 classes — keeps local
/// persistence (JSON) trivial and mirrors how a real backend user table
/// would likely look (one users table + role column).
class AppUser {
  final String id;
  final String name;
  final UserRole role;

  // Email is collected at sign-up for student/teacher accounts. Nullable
  // because the seeded demo admin account doesn't have one.
  final String? email;

  // Student-only (collected at sign-up)
  final Grade? grade;
  final int? age;
  final String? gender;

  // Teacher-only
  final List<Subject> assignedSubjects;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.grade,
    this.age,
    this.gender,
    this.assignedSubjects = const [],
  });

  AppUser copyWith({
    String? name,
    String? email,
    Grade? grade,
    int? age,
    String? gender,
    List<Subject>? assignedSubjects,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      role: role,
      email: email ?? this.email,
      grade: grade ?? this.grade,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      assignedSubjects: assignedSubjects ?? this.assignedSubjects,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.name,
        'email': email,
        'grade': grade?.name,
        'age': age,
        'gender': gender,
        'assignedSubjects': assignedSubjects.map((s) => s.name).toList(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      role: UserRole.values.byName(json['role'] as String),
      email: json['email'] as String?,
      grade: json['grade'] != null
          ? Grade.values.byName(json['grade'] as String)
          : null,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      assignedSubjects: (json['assignedSubjects'] as List<dynamic>? ?? [])
          .map((s) => Subject.values.byName(s as String))
          .toList(),
    );
  }
}
