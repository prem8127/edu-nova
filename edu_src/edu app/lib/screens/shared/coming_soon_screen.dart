import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Lightweight placeholder for nav destinations that exist in the Aditya
/// Globals prototype but don't have a real screen built yet. Keeps the
/// hamburger drawer fully navigable (nothing 404s) while making it obvious
/// which features are still pending.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, this.icon = Icons.hourglass_top_rounded});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppBrand.purple.withValues(alpha: .14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppBrand.purple, size: 30),
            ),
            const SizedBox(height: 18),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: AppBrand.ink)),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'This section is coming soon.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppBrand.inkSoft, fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
