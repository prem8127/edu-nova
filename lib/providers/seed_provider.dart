import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local/seed_data_service.dart';
import 'repository_providers.dart';

/// Runs once when the app first builds its provider tree. Populates demo
/// courses/teachers/quizzes/classes if (and only if) storage is empty —
/// see [SeedDataService.seedPlatformContent] for the idempotency check.
/// The router/splash watches this so the very first frame never shows an
/// empty app.
final platformSeedProvider = FutureProvider<void>((ref) async {
  await SeedDataService.seedPlatformContent(
    userRepo: ref.watch(userRepositoryProvider),
    courseRepo: ref.watch(courseRepositoryProvider),
    quizRepo: ref.watch(quizRepositoryProvider),
    scheduleRepo: ref.watch(scheduleRepositoryProvider),
    platformRepo: ref.watch(platformRepositoryProvider),
  );
});
