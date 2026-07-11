import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/ui.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () { if (mounted) context.go('/onboarding'); });
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: AppColors.navy, body: FadeTransition(opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut), child: ScaleTransition(scale: Tween(begin: .82, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack)), child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [BrandMark(light: true), SizedBox(height: 14), Text('Learn today. Lead tomorrow.', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))])))));
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int index = 0;
  static const pages = [
    (Icons.explore_rounded, 'Find your direction.', 'Discover courses, careers and opportunities shaped around your goals—not someone else’s.'),
    (Icons.auto_awesome_rounded, 'Meet your AI mentor.', 'Ask questions, build study plans and turn uncertainty into clear next steps.'),
    (Icons.rocket_launch_rounded, 'Move from learning to doing.', 'Build real skills, follow roadmaps and land opportunities that move you forward.'),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(body: DotGridBackground(child: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(22, 16, 14, 4), child: Row(children: [const BrandMark(compact: true), const Spacer(), TextButton(onPressed: () => context.go('/login'), child: const Text('Skip', style: TextStyle(color: AppColors.heading)))])),
    Expanded(child: PageView.builder(controller: controller, itemCount: pages.length, onPageChanged: (v) => setState(() => index = v), itemBuilder: (_, i) {
      final page = pages[i];
      return Padding(padding: const EdgeInsets.fromLTRB(24, 22, 24, 18), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(height: 280, width: double.infinity, decoration: BoxDecoration(color: i == 1 ? AppColors.orangeSoft : i == 2 ? const Color(0xFFE6EDFF) : const Color(0xFFFFE9AF), borderRadius: BorderRadius.circular(42)), child: Stack(children: [
          Positioned(right: -30, top: -30, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.navy.withValues(alpha: .08), width: 28)))),
          Center(child: Container(width: 118, height: 118, decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle), child: Icon(page.$1, color: Colors.white, size: 57))),
          Positioned(left: 24, top: 24, child: StatusPill('0${i + 1} / 03', color: Colors.white.withValues(alpha: .8))),
        ])),
        const SizedBox(height: 34), Text(page.$2, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 14), Text(page.$3, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.muted)),
      ]));
    })),
    Padding(padding: const EdgeInsets.fromLTRB(24, 4, 24, 22), child: Row(children: [
      Row(children: List.generate(pages.length, (i) => AnimatedContainer(duration: const Duration(milliseconds: 220), width: i == index ? 26 : 8, height: 8, margin: const EdgeInsets.only(right: 6), decoration: BoxDecoration(color: i == index ? AppColors.orange : AppColors.line, borderRadius: BorderRadius.circular(9))))),
      const Spacer(), FloatingActionButton.extended(backgroundColor: AppColors.navy, foregroundColor: Colors.white, onPressed: () { if (index == pages.length - 1) { context.go('/login'); } else { controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut); } }, label: Text(index == pages.length - 1 ? 'Get started' : 'Next'), icon: const Icon(Icons.arrow_forward_rounded)),
    ])),
  ]))));
}

class AuthFrame extends StatelessWidget {
  const AuthFrame({super.key, required this.title, required this.subtitle, required this.children, this.footer});
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? footer;
  @override
  Widget build(BuildContext context) => Scaffold(body: DotGridBackground(child: SafeArea(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.fromLTRB(22, 18, 22, 28), children: [
    Row(children: [if (context.canPop()) RoundIconButton(icon: Icons.arrow_back_rounded, onTap: () => context.pop()) else const BrandMark(compact: true)]),
    const SizedBox(height: 40), Text(title, style: Theme.of(context).textTheme.displayMedium), const SizedBox(height: 10), Text(subtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.muted)),
    const SizedBox(height: 30), Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: children))),
    if (footer != null) ...[const SizedBox(height: 24), footer!],
  ])))));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
enum _LoginRole { student, teacher, admin }

class _LoginScreenState extends State<LoginScreen> {
  bool hidden = true;
  _LoginRole role = _LoginRole.student;

  void _continue(BuildContext context) => context.go(switch (role) {
        _LoginRole.student => '/select-class',
        _LoginRole.teacher => '/teacher',
        _LoginRole.admin => '/admin',
      });

  @override
  Widget build(BuildContext context) => AuthFrame(title: 'Welcome back.', subtitle: 'Your next breakthrough is waiting.', children: [
    Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Expanded(
          child: _RoleTab(label: 'Student', icon: Icons.school_rounded, selected: role == _LoginRole.student, onTap: () => setState(() => role = _LoginRole.student)),
        ),
        Expanded(
          child: _RoleTab(label: 'Teacher', icon: Icons.co_present_rounded, selected: role == _LoginRole.teacher, onTap: () => setState(() => role = _LoginRole.teacher)),
        ),
        Expanded(
          child: _RoleTab(label: 'Admin', icon: Icons.admin_panel_settings_rounded, selected: role == _LoginRole.admin, onTap: () => setState(() => role = _LoginRole.admin)),
        ),
      ]),
    ),
    const SizedBox(height: 18),
    const TextField(decoration: InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline_rounded))), const SizedBox(height: 14),
    TextField(obscureText: hidden, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline_rounded), suffixIcon: IconButton(onPressed: () => setState(() => hidden = !hidden), icon: Icon(hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded)))),
    Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => context.push('/forgot-password'), child: const Text('Forgot password?', style: TextStyle(color: AppColors.orange)))),
    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _continue(context), child: const Text('Sign in  →'))),
    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or continue with')), Expanded(child: Divider())])),
    OutlinedButton.icon(onPressed: () => _continue(context), icon: const Text('G', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), label: const Text('Continue with Google'), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)))),
  ], footer: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('New to EduNova?'), TextButton(onPressed: () => context.push('/register'), child: const Text('Create account', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800)))]));
}

class _RoleTab extends StatelessWidget {
  const _RoleTab({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(color: selected ? AppColors.navy : Colors.transparent, borderRadius: BorderRadius.circular(11)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 17, color: selected ? Colors.white : AppColors.muted),
            const SizedBox(width: 7),
            Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: selected ? Colors.white : AppColors.muted)),
          ]),
        ),
      );
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) => AuthFrame(title: 'Create your future.', subtitle: 'Tell us a little about you to personalize your journey.', children: [
    const TextField(decoration: InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline_rounded))), const SizedBox(height: 14),
    const TextField(decoration: InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline_rounded))), const SizedBox(height: 14),
    const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Create password', prefixIcon: Icon(Icons.lock_outline_rounded))), const SizedBox(height: 18),
    Row(children: [Checkbox(value: true, onChanged: (_) {}), const Expanded(child: Text('I agree to the Terms and Privacy Policy', style: TextStyle(fontSize: 12)))]), const SizedBox(height: 12),
    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => context.push('/otp'), child: const Text('Create account  →'))),
  ], footer: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Already a member?'), TextButton(onPressed: () => context.pop(), child: const Text('Sign in', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800)))]));
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) => AuthFrame(title: 'Reset password.', subtitle: 'Enter your email and we’ll send a secure verification code.', children: [
    Container(width: 72, height: 72, decoration: const BoxDecoration(color: AppColors.orangeSoft, shape: BoxShape.circle), child: const Icon(Icons.mark_email_read_rounded, color: AppColors.orange, size: 34)), const SizedBox(height: 22),
    const TextField(decoration: InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline_rounded))), const SizedBox(height: 20),
    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => context.push('/otp'), child: const Text('Send verification code'))),
  ]);
}

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});
  @override
  Widget build(BuildContext context) => AuthFrame(title: 'Check your inbox.', subtitle: 'We sent a 4-digit code to alex@example.com', children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(4, (_) => SizedBox(width: 58, child: TextField(textAlign: TextAlign.center, keyboardType: TextInputType.number, maxLength: 1, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900), decoration: const InputDecoration(counterText: ''))))),
    const SizedBox(height: 22), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => context.go('/select-class'), child: const Text('Verify & continue'))),
    const SizedBox(height: 14), TextButton(onPressed: () {}, child: const Text('Didn’t receive it? Resend in 00:28', style: TextStyle(color: AppColors.muted))),
  ]);
}
