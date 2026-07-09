import 'package:flutter/material.dart';

class EliteAcademyApp extends StatelessWidget {
  const EliteAcademyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Elite Academy',
        theme: _Theme.light,
        home: const EliteRoot(),
      );
}

class EliteRoot extends StatefulWidget {
  const EliteRoot({super.key});

  @override
  State<EliteRoot> createState() => _EliteRootState();
}

class _EliteRootState extends State<EliteRoot> {
  bool authed = false;

  @override
  Widget build(BuildContext context) => authed ? const EliteHome() : AuthScreen(onEnter: () => setState(() => authed = true));
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onEnter});
  final VoidCallback onEnter;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool register = false;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 850;
    return Scaffold(
      backgroundColor: register ? _C.navy : _C.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: wide
                  ? Row(children: [
                      Expanded(child: _AuthHero(register: register)),
                      const SizedBox(width: 24),
                      SizedBox(width: 420, child: _AuthForm(register: register, onToggle: () => setState(() => register = !register), onEnter: widget.onEnter)),
                    ])
                  : _AuthForm(register: register, onToggle: () => setState(() => register = !register), onEnter: widget.onEnter),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero({required this.register});
  final bool register;

  @override
  Widget build(BuildContext context) => Container(
        height: 640,
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          color: _C.navy,
          borderRadius: BorderRadius.circular(34),
          image: const DecorationImage(image: NetworkImage(''), fit: BoxFit.cover, opacity: 0),
        ),
        child: Stack(children: [
          Positioned(right: -60, top: -50, child: _Glow(size: 260, color: _C.orange)),
          Positioned(left: -80, bottom: -80, child: _Glow(size: 280, color: const Color(0xFF2E5BFF))),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _Logo(light: true),
            const Spacer(),
            _Badge(text: register ? 'START YOUR PATH' : 'ELITE ACADEMY OS', dark: true),
            const SizedBox(height: 18),
            Text(register ? 'Choose a track. Learn with purpose.' : 'Focused learning for tech, business, creators, and govt prep.',
                style: const TextStyle(color: Colors.white, fontSize: 54, height: .94, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            const Text('A polished student experience built from the Figma direction: dark course heroes, orange CTAs, compact cards, progress rings, live classes, mentor schedules, and prep dashboards.',
                style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.55)),
            const SizedBox(height: 28),
            Row(children: const [
              _HeroStat(value: '42', label: 'courses'),
              SizedBox(width: 12),
              _HeroStat(value: '14', label: 'tests'),
              SizedBox(width: 12),
              _HeroStat(value: '68%', label: 'progress'),
            ]),
          ]),
        ]),
      );
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({required this.register, required this.onToggle, required this.onEnter});
  final bool register;
  final VoidCallback onToggle;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: _card(radius: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _Logo(light: false),
          const SizedBox(height: 28),
          Text(register ? 'Join Elite Academy' : 'Welcome Back', style: _T.h1, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(register ? 'Build your focused learning account.' : 'Elevate your learning journey with us.', style: _T.muted, textAlign: TextAlign.center),
          const SizedBox(height: 22),
          if (!register) const _RoleTabs(),
          if (!register) const SizedBox(height: 14),
          if (register) const _Field(label: 'Full Name'),
          const _Field(label: 'Email / Mobile Number'),
          if (register) const _Field(label: 'Select Course / Path'),
          const _Field(label: 'Password', obscure: true),
          const SizedBox(height: 8),
          _PrimaryButton(label: register ? 'Register Now' : 'Login', onTap: onEnter),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: onEnter, icon: const Text('G', style: TextStyle(fontWeight: FontWeight.w900)), label: const Text('Continue with Google')),
          const SizedBox(height: 18),
          TextButton(onPressed: onToggle, child: Text(register ? 'Already have an account? Login' : 'New here? Create account')),
        ]),
      );
}

class EliteHome extends StatefulWidget {
  const EliteHome({super.key});

  @override
  State<EliteHome> createState() => _EliteHomeState();
}

class _EliteHomeState extends State<EliteHome> {
  int tab = 0;

  final pages = const [
    StudentDashboard(),
    CoursesPage(),
    LearningPage(),
    GovtPrepPage(),
    MentorPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 900;
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Row(children: [
          if (wide) _SideNav(tab: tab, onTab: (v) => setState(() => tab = v)),
          Expanded(child: pages[tab]),
        ]),
      ),
      bottomNavigationBar: wide ? null : _BottomNav(tab: tab, onTab: (v) => setState(() => tab = v)),
    );
  }
}

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) => _Screen(
        title: 'Student Dashboard',
        subtitle: 'Track classes, live sessions, assignments, and your next lesson.',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          _HeroCourse(),
          SizedBox(height: 16),
          _SectionHeader(title: 'Today Classes', action: 'View all'),
          _SessionTile(title: 'UI/UX Principles', time: '2:00 PM', live: true),
          _SessionTile(title: 'Data Structures with Python', time: '6:00 PM'),
          SizedBox(height: 16),
          _FeatureBanner(title: 'Python Workshop', subtitle: 'Build automation scripts in a guided live workshop.'),
          SizedBox(height: 16),
          _StatsGrid(),
        ]),
      );
}

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) => _Screen(
        title: 'Course Library',
        subtitle: 'Figma-inspired cards for recommended paths and skill tracks.',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _SearchAndFilters(),
          const SizedBox(height: 16),
          _ResponsiveCards(children: const [
            _CourseCard(title: 'Web Development', badge: 'Recommended Path', image: _Img.code, action: 'Start'),
            _CourseCard(title: 'Basic C++ Foundation', badge: 'Beginner', image: _Img.circuit, action: 'View Curriculum'),
            _CourseCard(title: 'Basic Python (Core)', badge: 'Featured', image: _Img.python, action: 'View Curriculum'),
            _CourseCard(title: 'AI/ML Advanced', badge: 'Hot', image: _Img.spark, action: 'View Curriculum'),
          ]),
        ]),
      );
}

class LearningPage extends StatelessWidget {
  const LearningPage({super.key});

  @override
  Widget build(BuildContext context) => _Screen(
        title: 'Web Development Track',
        subtitle: 'Dark hero, orange progress, and lesson cards based on your Figma screen.',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          _ProgramHero(title: 'Web Development Track', progress: .35, cta: 'Resume Learning', icon: Icons.code_rounded),
          SizedBox(height: 18),
          _SectionHeader(title: 'Introduction To Web'),
          _LessonTile(title: 'Responsive Design', progress: .72, action: 'Start'),
          _LessonTile(title: 'Developer Fundamentals', progress: .28),
          _LessonTile(title: 'React.js Mastery', progress: .08),
          SizedBox(height: 18),
          _ProgramHero(title: 'Influencer Marketing', progress: .68, cta: 'Continue', icon: Icons.campaign_rounded, compact: true),
        ]),
      );
}

class GovtPrepPage extends StatelessWidget {
  const GovtPrepPage({super.key});

  @override
  Widget build(BuildContext context) => _Screen(
        title: 'Civil Services Mastery 2024',
        subtitle: 'Govt prep dashboard with subjects, tests, reasoning, and mock marathon.',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          _GovtHero(),
          SizedBox(height: 16),
          _PrepTile(title: 'General Studies', icon: Icons.public_rounded),
          _PrepTile(title: 'Quantitative Aptitude', icon: Icons.calculate_rounded),
          _PrepTile(title: 'Reasoning Ability', icon: Icons.psychology_rounded),
          SizedBox(height: 16),
          _ProgramHero(title: 'Overall Completion', progress: .66, cta: 'Take Mock Test', icon: Icons.workspace_premium_rounded, compact: true),
        ]),
      );
}

class MentorPage extends StatelessWidget {
  const MentorPage({super.key});

  @override
  Widget build(BuildContext context) => _Screen(
        title: 'Teaching Schedule',
        subtitle: 'Mentor dashboard with session cards, timings, and live class CTA.',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          _ScheduleCard(title: "Today's Sessions", primary: true),
          _ScheduleCard(title: 'Upcoming Class', primary: false),
          _ScheduleCard(title: 'Live Class', primary: false),
          SizedBox(height: 16),
          _FeatureBanner(title: 'Student Doubt Room', subtitle: '12 unresolved questions waiting for mentor review.'),
        ]),
      );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => _Screen(
        title: 'Choose Your Path',
        subtitle: 'The student landing path selection from the design, expanded into the app.',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          _PathCard(title: 'IT & TECH', icon: Icons.memory_rounded, active: true, body: 'Web development, AI, data science, and career-ready tech skills.'),
          _PathCard(title: 'Influencer Statistics', icon: Icons.campaign_rounded, body: 'Build content, personal brand, reach, and monetization.'),
          _PathCard(title: 'Business Strategies', icon: Icons.business_center_rounded, body: 'Startup thinking, finance, marketing, and leadership.'),
          _PathCard(title: 'Government Preparation', icon: Icons.account_balance_rounded, body: 'Civil services, exams, aptitude, and mock marathons.'),
        ]),
      );
}

class _Screen extends StatelessWidget {
  const _Screen({required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 900;
    return ListView(
      padding: EdgeInsets.fromLTRB(wide ? 34 : 16, 18, wide ? 34 : 16, 96),
      children: [
        Row(children: [
          const _Logo(),
          const Spacer(),
          _IconButton(icon: Icons.notifications_none_rounded, onTap: () {}),
          const SizedBox(width: 8),
          const CircleAvatar(radius: 17, backgroundColor: _C.navy, child: Icon(Icons.person, color: Colors.white, size: 16)),
        ]),
        const SizedBox(height: 24),
        Text(title, style: wide ? _T.display : _T.h1),
        const SizedBox(height: 8),
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 620), child: Text(subtitle, style: _T.body)),
        const SizedBox(height: 24),
        child,
      ],
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({required this.tab, required this.onTab});
  final int tab;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) => Container(
        width: 250,
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _C.navy, borderRadius: BorderRadius.circular(28)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _Logo(light: true),
          const SizedBox(height: 28),
          for (var i = 0; i < _nav.length; i++) _NavItem(index: i, active: tab == i, onTap: onTab),
          const Spacer(),
          const _DarkUpgradeCard(),
        ]),
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.index, required this.active, required this.onTap});
  final int index;
  final bool active;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final item = _nav[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: active ? _C.orange : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onTap(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            child: Row(children: [Icon(item.$2, color: Colors.white, size: 19), const SizedBox(width: 10), Text(item.$1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))]),
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.tab, required this.onTab});
  final int tab;
  final ValueChanged<int> onTab;
  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: onTab,
        destinations: _nav.map((n) => NavigationDestination(icon: Icon(n.$2), label: n.$1)).toList(),
      );
}

class _HeroCourse extends StatelessWidget {
  const _HeroCourse();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: _C.navy, borderRadius: BorderRadius.circular(24)),
        child: LayoutBuilder(builder: (context, constraints) {
          final narrow = constraints.maxWidth < 560;
          final content = [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                _Badge(text: 'WEB DEVELOPMENT'),
                SizedBox(height: 12),
                Text('React Basics', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('Continue your learning path with live support and practical tasks.', style: TextStyle(color: Colors.white70, height: 1.4)),
                SizedBox(height: 16),
                _SmallButton(label: 'Join Now', light: true),
              ]),
            ),
            const SizedBox(width: 18, height: 18),
            const _ProgressRing(value: .58),
          ];
          return narrow ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: content) : Row(children: content);
        }),
      );
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.title, required this.badge, required this.image, required this.action});
  final String title;
  final String badge;
  final List<Color> image;
  final String action;

  @override
  Widget build(BuildContext context) => Container(
        decoration: _card(radius: 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _ImageBlock(colors: image, height: 150),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [_Badge(text: badge), const Spacer(), const Icon(Icons.bookmark_border_rounded, size: 18)]),
              const SizedBox(height: 10),
              Text(title, style: _T.h2),
              const SizedBox(height: 6),
              const Text('Structured lessons, projects, mentor support, and completion reports.', style: _T.muted),
              const SizedBox(height: 14),
              Align(alignment: Alignment.centerRight, child: _SmallButton(label: action)),
            ]),
          ),
        ]),
      );
}

class _ResponsiveCards extends StatelessWidget {
  const _ResponsiveCards({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final columns = c.maxWidth > 1000 ? 4 : c.maxWidth > 680 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: columns == 1 ? 1.15 : .78),
          itemBuilder: (_, i) => children[i],
        );
      });
}

class _ProgramHero extends StatelessWidget {
  const _ProgramHero({required this.title, required this.progress, required this.cta, required this.icon, this.compact = false});
  final String title;
  final double progress;
  final String cta;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(compact ? 16 : 22),
        decoration: BoxDecoration(color: _C.navy, borderRadius: BorderRadius.circular(22)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_Badge(text: 'Program', dark: true), const SizedBox(height: 10), Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 14), _SmallButton(label: cta, light: true)])),
          _ProgressRing(value: progress, icon: icon),
        ]),
      );
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.title, required this.progress, this.action});
  final String title;
  final double progress;
  final String? action;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: _card(radius: 16),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: _T.h2), const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: progress, minHeight: 6, color: _C.orange, backgroundColor: _C.soft))])),
          if (action != null) ...[const SizedBox(width: 12), _SmallButton(label: action!)],
        ]),
      );
}

class _GovtHero extends StatelessWidget {
  const _GovtHero();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: _card(radius: 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Civil Services Mastery 2024', style: _T.h1),
          SizedBox(height: 8),
          Text('A structured exam preparation system with live classes, tests, analytics, and mock marathon.', style: _T.body),
          SizedBox(height: 16),
          _StatsGrid(),
        ]),
      );
}

class _PrepTile extends StatelessWidget {
  const _PrepTile({required this.title, required this.icon});
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: _card(radius: 16),
        child: Row(children: [CircleAvatar(backgroundColor: _C.peach, child: Icon(icon, color: _C.navy)), const SizedBox(width: 12), Expanded(child: Text(title, style: _T.h2)), const _SmallButton(label: 'Start')]),
      );
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.title, required this.primary});
  final String title;
  final bool primary;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: primary ? BoxDecoration(color: _C.navy, borderRadius: BorderRadius.circular(20)) : _card(radius: 20),
        child: Row(children: [
          CircleAvatar(backgroundColor: primary ? _C.orange : _C.peach, child: Icon(Icons.video_camera_front_rounded, color: primary ? Colors.white : _C.navy)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primary ? Colors.white : _C.ink)), Text('Web Development Live Class • 2:00 PM', style: TextStyle(color: primary ? Colors.white70 : _C.muted))])),
          _SmallButton(label: primary ? 'Start' : 'View', light: primary),
        ]),
      );
}

class _PathCard extends StatelessWidget {
  const _PathCard({required this.title, required this.icon, required this.body, this.active = false});
  final String title;
  final IconData icon;
  final String body;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: active ? _C.navy : Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: active ? [] : _shadow),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: active ? _C.orange : _C.navy),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: active ? Colors.white : _C.ink)), const SizedBox(height: 5), Text(body, style: TextStyle(color: active ? Colors.white70 : _C.muted, height: 1.4))])),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: active ? Colors.white54 : _C.muted),
        ]),
      );
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters();
  @override
  Widget build(BuildContext context) => Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: const [
        SizedBox(width: 320, child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Search courses and skills'))),
        Chip(label: Text('Recommended')),
        Chip(label: Text('New Courses')),
        Chip(label: Text('AI & ML')),
      ]);
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});
  final String title;
  final String? action;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [Expanded(child: Text(title, style: _T.h2)), if (action != null) Text(action!, style: const TextStyle(color: _C.orange, fontWeight: FontWeight.w900))]),
      );
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.title, required this.time, this.live = false});
  final String title;
  final String time;
  final bool live;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: _card(radius: 16),
        child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: _T.h2), Text(time, style: _T.muted)])), _SmallButton(label: live ? 'Join' : 'View')]),
      );
}

class _FeatureBanner extends StatelessWidget {
  const _FeatureBanner({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0C121C), Color(0xFF4A210D)]), borderRadius: BorderRadius.circular(20)),
        child: Row(children: [const CircleAvatar(backgroundColor: _C.orange, child: Icon(Icons.play_arrow_rounded, color: Colors.white)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.white70))]))]),
      );
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final items = const [('42', 'Lessons'), ('14', 'Tests'), ('56', 'Hours')];
        return Row(children: items.map((i) => Expanded(child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(14), decoration: _card(radius: 14), child: Column(children: [Text(i.$1, style: _T.h2), Text(i.$2, style: _T.muted)])))).toList());
      });
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.value, this.icon});
  final double value;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(width: 96, height: 96, child: CustomPaint(painter: _RingPainter(value), child: Center(child: Text('${(value * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)))));
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value);
  final double value;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawArc(rect.deflate(10), 0, 6.28, false, Paint()..color = Colors.white12..style = PaintingStyle.stroke..strokeWidth = 8);
    canvas.drawArc(rect.deflate(10), -1.57, 6.28 * value, false, Paint()..color = _C.orange..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ImageBlock extends StatelessWidget {
  const _ImageBlock({required this.colors, required this.height});
  final List<Color> colors;
  final double height;
  @override
  Widget build(BuildContext context) => Container(height: height, decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: const BorderRadius.vertical(top: Radius.circular(18))), child: CustomPaint(painter: _LinesPainter(), child: const SizedBox.expand()));
}

class _LinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .18)..strokeWidth = 1;
    for (double y = 18; y < size.height; y += 16) {
      canvas.drawLine(Offset(18, y), Offset(size.width - 18, y + (y % 32)), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Field extends StatelessWidget {
  const _Field({required this.label, this.obscure = false});
  final String label;
  final bool obscure;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(obscureText: obscure, decoration: InputDecoration(labelText: label, suffixIcon: obscure ? const Icon(Icons.visibility_off_rounded) : null)));
}

class _RoleTabs extends StatelessWidget {
  const _RoleTabs();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: _C.soft, borderRadius: BorderRadius.circular(12)),
        child: Row(children: const [_RoleTab(label: 'Student', active: true), _RoleTab(label: 'Mentor'), _RoleTab(label: 'Admin')]),
      );
}

class _RoleTab extends StatelessWidget {
  const _RoleTab({required this.label, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(9)), child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, color: active ? _C.ink : _C.muted))));
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: onTap, child: Text(label)));
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.label, this.light = false});
  final String label;
  final bool light;
  @override
  Widget build(BuildContext context) => Material(color: light ? Colors.white : _C.orange, borderRadius: BorderRadius.circular(10), child: InkWell(borderRadius: BorderRadius.circular(10), onTap: () {}, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9), child: Text(label, style: TextStyle(color: light ? _C.navy : Colors.white, fontWeight: FontWeight.w900)))));
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, this.dark = false});
  final String text;
  final bool dark;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: dark ? Colors.white12 : _C.peach, borderRadius: BorderRadius.circular(8)), child: Text(text, style: TextStyle(color: dark ? Colors.white : _C.orange, fontSize: 11, fontWeight: FontWeight.w900)));
}

class _Logo extends StatelessWidget {
  const _Logo({this.light = false});
  final bool light;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.auto_awesome_rounded, color: _C.orange, size: 18), const SizedBox(width: 5), Text('Elite Academy', style: TextStyle(fontWeight: FontWeight.w900, color: light ? Colors.white : _C.ink))]);
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(color: Colors.white, shape: const CircleBorder(), child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, size: 20))));
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(color: Colors.white70))])));
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withValues(alpha: .28), Colors.transparent])));
}

class _DarkUpgradeCard extends StatelessWidget {
  const _DarkUpgradeCard();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(18)), child: const Text('Resume learning with mentor support, live classes, tests, and reports.', style: TextStyle(color: Colors.white70, height: 1.4)));
}

BoxDecoration _card({double radius = 16}) => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius), boxShadow: _shadow);

const _shadow = [BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 8))];

const _nav = [
  ('Home', Icons.home_rounded),
  ('Courses', Icons.menu_book_rounded),
  ('Learning', Icons.play_circle_rounded),
  ('Prep', Icons.account_balance_rounded),
  ('Mentor', Icons.video_camera_front_rounded),
  ('Path', Icons.route_rounded),
];

abstract final class _Img {
  static const code = [Color(0xFF0E2A35), Color(0xFF66A6B8)];
  static const circuit = [Color(0xFF111827), Color(0xFF2563EB)];
  static const python = [Color(0xFF062B36), Color(0xFF14B8A6)];
  static const spark = [Color(0xFF160B2E), Color(0xFFFF6B1A)];
}

abstract final class _C {
  static const orange = Color(0xFFFF6B1A);
  static const peach = Color(0xFFFFE9DD);
  static const navy = Color(0xFF101C2B);
  static const bg = Color(0xFFF5F6F4);
  static const soft = Color(0xFFECEFF1);
  static const ink = Color(0xFF151A22);
  static const muted = Color(0xFF7C828A);
}

abstract final class _T {
  static const display = TextStyle(fontSize: 48, height: .96, fontWeight: FontWeight.w900, color: _C.ink);
  static const h1 = TextStyle(fontSize: 30, height: 1.05, fontWeight: FontWeight.w900, color: _C.ink);
  static const h2 = TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _C.ink);
  static const body = TextStyle(fontSize: 15, height: 1.5, color: _C.muted);
  static const muted = TextStyle(fontSize: 13, height: 1.4, color: _C.muted);
}

abstract final class _Theme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _C.bg,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: _C.orange, primary: _C.orange, secondary: _C.navy, surface: _C.bg),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF2F4F4),
          labelStyle: const TextStyle(color: _C.muted),
          hintStyle: const TextStyle(color: _C.muted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _C.orange, width: 1.4)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: _C.orange, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: const TextStyle(fontWeight: FontWeight.w900))),
        outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: _C.ink, side: const BorderSide(color: _C.soft), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size.fromHeight(48))),
        chipTheme: const ChipThemeData(labelStyle: TextStyle(fontWeight: FontWeight.w800), side: BorderSide(color: _C.soft), backgroundColor: Colors.white),
      );
}
