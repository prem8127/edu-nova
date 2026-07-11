import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_enums.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/grade_themes.dart';
import 'providers/auth_provider.dart';
import 'providers/seed_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Mobile-only: lock the whole app to portrait so it never rotates
  // into a tablet / landscape layout.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
        final content = seed.when(
          data: (_) => child ?? const SizedBox.shrink(),
          loading: () => const _SplashScreen(),
          error: (e, _) => _SplashScreen(error: e.toString()),
        );
        // Mobile-only presentation: keep everything inside a phone-width
        // viewport, centered on black, so wider screens (web/tablet) still
        // render the app as a single mobile column rather than stretching.
        return ColoredBox(
          color: AppBrand.bg,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: content,
            ),
          ),
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
      backgroundColor: AppBrand.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Wordmark: navy "Aditya" + orange "Globals".
            RichText(
              text: TextSpan(
                style: GoogleFonts.sora(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.5,
                  color: AppBrand.ink,
                ),
                children: const [
                  TextSpan(text: 'Aditya '),
                  TextSpan(text: 'Globals', style: TextStyle(color: AppBrand.purple)),
                ],
              ),
            ),
            const SizedBox(height: 26),
            if (error == null)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.6, color: AppBrand.purple),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text('Could not load demo data:\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppBrand.inkSoft)),
              ),
          ],
        ),
      ),
    );
  }
}
