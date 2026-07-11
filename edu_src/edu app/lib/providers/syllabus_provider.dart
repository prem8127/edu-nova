import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/syllabus_model.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// Full Class 6–10 roadmap, in class order — used by the Teacher and Admin
/// syllabus screens (which browse every class via tabs).
final syllabusDataProvider = FutureProvider<List<SyllabusClassPlan>>((ref) async {
  final repo = ref.watch(syllabusRepositoryProvider);
  return repo.getSyllabus();
});

/// Level -> book titles, shown under every class's curriculum.
final essentialBooksProvider = FutureProvider<Map<String, List<String>>>((ref) async {
  final repo = ref.watch(syllabusRepositoryProvider);
  return repo.getEssentialBooks();
});

/// The single class plan matching the signed-in student's grade. The
/// roadmap only goes up to Class 10, so Intermediate students see the
/// Class 10 (final) stage as the closest match.
final currentStudentSyllabusProvider = FutureProvider<SyllabusClassPlan?>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user?.grade == null) return null;
  final all = await ref.watch(syllabusDataProvider.future);
  if (all.isEmpty) return null;
  final match = all.where((s) => s.grade == user!.grade);
  if (match.isNotEmpty) return match.first;
  // Grade.intermediate1 / intermediate2 aren't in the roadmap yet — fall
  // back to the last (most advanced) class plan.
  return all.last;
});
