import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class EduNovaApp extends StatelessWidget {
  const EduNovaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'EduNova',
        debugShowCheckedModeBanner: false,
        // Neutral dark base for the login/dashboard shell. Per-grade bright
        // themes (Class 6–10) are applied lower in the tree once a student's
        // grade is known; Intermediate/College reuse this dark base.
        theme: AppTheme.dark,
        routerConfig: appRouter,
      );
}
