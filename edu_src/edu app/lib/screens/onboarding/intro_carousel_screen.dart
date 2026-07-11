import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

/// Udemy-style intro carousel shown before sign-in: three swipeable slides
/// with hand-drawn black-and-white art, a serif headline, muted body copy,
/// dot indicators and a white "Browse | Sign In" bottom bar.
class IntroCarouselScreen extends StatefulWidget {
  const IntroCarouselScreen({super.key});

  @override
  State<IntroCarouselScreen> createState() => _IntroCarouselScreenState();
}

class _IntroCarouselScreenState extends State<IntroCarouselScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = <_Slide>[
    _Slide(
      image: 'assets/onboarding/slide_courses.png',
      title: 'Take Video Courses',
      body: 'From cooking to coding\nand everything in between',
    ),
    _Slide(
      image: 'assets/onboarding/slide_instructors.png',
      title: 'Learn from the Best',
      body: 'Approachable expert-instructors,\nvetted by more than\n50 million learners',
    ),
    _Slide(
      image: 'assets/onboarding/slide_pace.png',
      title: 'Go at Your Own Pace',
      body: 'Lifetime access to\npurchased courses,\nanytime, anywhere',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToSignIn() => context.go(AppRoutes.roleSelect);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppBrand.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Swipeable slides ----
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
              ),
            ),

            // ---- Dot indicators ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: active ? 10 : 8,
                  height: active ? 10 : 8,
                  decoration: BoxDecoration(
                    color: active ? AppBrand.ink : AppBrand.inkSoft.withValues(alpha: .4),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 22),

            // ---- Current slide text ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    _slides[_page].title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppBrand.ink,
                      letterSpacing: -.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _slides[_page].body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.4,
                      color: AppBrand.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ---- White Browse | Sign In bar ----
            const _BottomBar(),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Image.asset(
          slide.image,
          fit: BoxFit.contain,
          // Keep the illustration crisp even if the asset fails to resolve.
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_IntroCarouselScreenState>();
    return Container(
      color: AppBrand.ink,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _BarButton(label: 'Browse', onTap: () => state?._goToSignIn()),
          ),
          Container(width: 1, height: 34, color: Colors.black.withValues(alpha: .12)),
          Expanded(
            child: _BarButton(label: 'Sign In', onTap: () => state?._goToSignIn()),
          ),
        ],
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({required this.image, required this.title, required this.body});
  final String image;
  final String title;
  final String body;
}
