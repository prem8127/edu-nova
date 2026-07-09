import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_enums.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/grade_themes.dart';
import 'providers/auth_provider.dart';
import 'providers/seed_provider.dart';

void main() {
  runApp(const ProviderScope(child: EduNovaApp()));
}

class EduNovaApp extends ConsumerWidget {
  const EduNovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final seed = ref.watch(platformSeedProvider);

    // Each class gets its own theme: a signed-in student's grade drives the
    // whole app's look. Teachers / admins / logged-out users fall back to
    // the neutral dark base.
    final user = ref.watch(authControllerProvider).value;
    final theme = (user?.role == UserRole.student)
        ? gradeThemeFor(user?.grade)
        : AppTheme.dark;

    return MaterialApp.router(
      title: 'Aditya Globals',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
      // Demo courses/teachers/quizzes are seeded once on first launch;
      // this overlay covers that brief moment so nothing ever flashes an
      // empty dashboard before content exists.
      builder: (context, child) {
        return seed.when(
          data: (_) => child ?? const SizedBox.shrink(),
          loading: () => const _SplashScreen(),
          error: (e, _) => _SplashScreen(error: e.toString()),
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen({this.error});
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppBrand.heroGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 22),
              const Text('Aditya Globals',
                  style: TextStyle(
                      color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 18),
              if (error == null)
                const CircularProgressIndicator(color: Colors.white)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text('Could not load demo data:\n$error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
