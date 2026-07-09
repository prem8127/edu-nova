import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../shared/widgets/ui.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Career roadmaps', 'See the skills between you and your goal.', Icons.route_rounded, Color(0xFFFFD7C2), '/roadmap'),
      ('Industry mentors', 'Learn from people already doing the work.', Icons.groups_rounded, Color(0xFFE7F5DF), '/influencers'),
      ('Internships', 'Turn your learning into real experience.', Icons.work_outline_rounded, Color(0xFFDDE7FF), '/internships'),
      ('Government exams', 'Focused preparation, without the noise.', Icons.account_balance_rounded, Color(0xFFFFE9AF), '/exams'),
    ];
    return DotGridBackground(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 30), children: [
      Row(children: [Expanded(child: Text('Explore what’s\npossible.', style: Theme.of(context).textTheme.displayMedium)), RoundIconButton(icon: Icons.bookmark_border_rounded, onTap: () {})]), const SizedBox(height: 20), const SearchBox(hint: 'Search careers and opportunities'), const SizedBox(height: 26),
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(30)), child: const Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [StatusPill('TRENDING NOW', color: Colors.white24, foreground: Colors.white), SizedBox(height: 14), Text('The 10 fastest-growing careers in India', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900, height: 1.1)), SizedBox(height: 10), Text('Explore the 2026 outlook  →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))])), Icon(Icons.trending_up_rounded, color: Colors.white, size: 64)])),
      const SizedBox(height: 28), const SectionHeader(title: 'Choose your next move'), const SizedBox(height: 12),
      ...items.map((item) => Card(margin: const EdgeInsets.only(bottom: 13), child: InkWell(borderRadius: BorderRadius.circular(26), onTap: () => context.push(item.$5), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Container(width: 62, height: 62, decoration: BoxDecoration(color: item.$4, borderRadius: BorderRadius.circular(20)), child: Icon(item.$3, color: AppColors.navy, size: 29)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.$1, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 4), Text(item.$2, style: const TextStyle(color: AppColors.muted, fontSize: 12))])), const Icon(Icons.arrow_outward_rounded)]))))),
    ])));
  }
}

class CareerRoadmapScreen extends StatelessWidget {
  const CareerRoadmapScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: DotGridBackground(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.only(bottom: 28), children: [
    PageHeader(title: 'Career roadmap', subtitle: 'A practical route to your goal.', trailing: RoundIconButton(icon: Icons.ios_share_rounded, onTap: () {})),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(30)), child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [StatusPill('YOUR GOAL', color: Colors.white12, foreground: Colors.white), SizedBox(height: 13), Text('Become a\nProduct Designer', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, height: 1.05)), SizedBox(height: 9), Text('Estimated path · 6–8 months', style: TextStyle(color: Colors.white60))])), const ProgressRing(value: .24, size: 82, color: AppColors.orange)])),
      const SizedBox(height: 24), const SectionHeader(title: 'Your 6 milestones'), const SizedBox(height: 14),
      ...['Design fundamentals', 'UX research', 'UI craft & systems', 'Prototype & test', 'Portfolio project', 'Job-ready launch'].asMap().entries.map((e) => _Milestone(index: e.key, title: e.value, active: e.key <= 1, last: e.key == 5, onTap: () => context.push('/learning-path'))),
    ])),
  ])))));
}

class _Milestone extends StatelessWidget {
  const _Milestone({required this.index, required this.title, required this.active, required this.last, required this.onTap});
  final int index; final String title; final bool active; final bool last; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    SizedBox(width: 45, child: Column(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: index == 0 ? AppColors.green : active ? AppColors.orange : Colors.white, shape: BoxShape.circle, border: Border.all(color: active ? Colors.transparent : AppColors.line, width: 2)), child: Center(child: index == 0 ? const Icon(Icons.check_rounded, color: Colors.white, size: 19) : Text('${index + 1}', style: TextStyle(color: active ? Colors.white : AppColors.ink, fontWeight: FontWeight.w900)))), if (!last) Expanded(child: Container(width: 2, color: active ? AppColors.orange : AppColors.line))])),
    const SizedBox(width: 10), Expanded(child: Card(margin: const EdgeInsets.only(bottom: 13), child: ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(index == 0 ? 'Completed · 4 skills' : active ? 'In progress · ${5 + index} skills' : 'Locked · Complete previous milestone'), trailing: Icon(active ? Icons.chevron_right_rounded : Icons.lock_outline_rounded, color: active ? AppColors.heading : AppColors.muted)))),
  ]));
}

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.only(bottom: 28), children: [
    const PageHeader(title: 'Design fundamentals', subtitle: 'Milestone 1 of 6 · 3 weeks'),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const ProgressRing(value: .75, size: 68), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('3 of 4 skills mastered', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 4), const Text('One final step before milestone 2.', style: TextStyle(color: AppColors.muted))]))]), const SizedBox(height: 16), ClipRRect(borderRadius: BorderRadius.circular(9), child: const LinearProgressIndicator(value: .75, minHeight: 8, color: AppColors.orange, backgroundColor: AppColors.line))]))),
      const SizedBox(height: 22), const SectionHeader(title: 'Skills in this milestone'), const SizedBox(height: 10),
      ...[('Visual hierarchy', true, '2 lessons · 1 project'), ('Color & typography', true, '3 lessons · 1 quiz'), ('Layout & spacing', true, '2 lessons · 1 project'), ('Design critique', false, '2 lessons · 25 min')].map((x) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(contentPadding: const EdgeInsets.all(14), leading: CircleAvatar(backgroundColor: x.$2 ? const Color(0xFFE7F5DF) : AppColors.orangeSoft, child: Icon(x.$2 ? Icons.check_rounded : Icons.play_arrow_rounded, color: x.$2 ? AppColors.green : AppColors.orange)), title: Text(x.$1, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(x.$3), trailing: const Icon(Icons.chevron_right_rounded)))),
      const SizedBox(height: 14), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => context.push('/courses/details'), child: const Text('Continue learning  →'))),
    ])),
  ]))));
}

class InfluencerListingScreen extends StatelessWidget {
  const InfluencerListingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.only(bottom: 28), children: [
    const PageHeader(title: 'Learn from the doers', subtitle: 'Follow industry voices who teach with clarity.'),
    const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: SearchBox(hint: 'Search mentors and expertise')), const SizedBox(height: 16),
    SizedBox(height: 42, child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), scrollDirection: Axis.horizontal, children: const [Chip(label: Text('For you'), backgroundColor: AppColors.navy, labelStyle: TextStyle(color: Colors.white)), SizedBox(width: 8), Chip(label: Text('Design')), SizedBox(width: 8), Chip(label: Text('Technology')), SizedBox(width: 8), Chip(label: Text('Business'))])),
    const SizedBox(height: 22), Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: MockData.mentors.map((m) => Card(margin: const EdgeInsets.only(bottom: 13), child: InkWell(borderRadius: BorderRadius.circular(26), onTap: () => context.push('/influencers/profile'), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [CircleAvatar(radius: 32, backgroundColor: m.color, child: Text(m.initials, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900, fontSize: 18))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Flexible(child: Text(m.name, style: Theme.of(context).textTheme.titleMedium)), const SizedBox(width: 5), const Icon(Icons.verified_rounded, color: AppColors.blue, size: 17)]), Text(m.role, style: const TextStyle(color: AppColors.muted, fontSize: 12)), const SizedBox(height: 8), StatusPill(m.expertise, color: m.color)])), Column(children: [const Icon(Icons.star_rounded, color: AppColors.orange, size: 18), Text('${m.rating}', style: const TextStyle(fontWeight: FontWeight.w900))])]))))).toList())),
  ]))));
}

class InfluencerProfileScreen extends StatelessWidget {
  const InfluencerProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.fromLTRB(20, 14, 20, 30), children: [
    Row(children: [RoundIconButton(icon: Icons.arrow_back_rounded, onTap: () => context.pop()), const Spacer(), RoundIconButton(icon: Icons.ios_share_rounded, onTap: () {})]), const SizedBox(height: 20),
    const Center(child: CircleAvatar(radius: 58, backgroundColor: AppColors.orangeSoft, child: Text('MS', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.navy)))), const SizedBox(height: 14),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Maya Sharma', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(width: 6), const Icon(Icons.verified_rounded, color: AppColors.blue)]), const Center(child: Text('Senior Product Designer · Figma', style: TextStyle(color: AppColors.muted))), const SizedBox(height: 15),
    const Row(mainAxisAlignment: MainAxisAlignment.center, children: [StatusPill('4.9 ★'), SizedBox(width: 8), StatusPill('28k followers', color: Color(0xFFDDE7FF)), SizedBox(width: 8), StatusPill('12 courses', color: Color(0xFFE7F5DF))]), const SizedBox(height: 19),
    Row(children: [Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Follow'))), const SizedBox(width: 10), Expanded(child: OutlinedButton(onPressed: () => context.push('/mentor/chat'), style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56)), child: const Text('Ask a question')))]), const SizedBox(height: 24),
    const SectionHeader(title: 'About'), const Text('Maya helps early-career designers build strong foundations, thoughtful portfolios, and the confidence to do work that matters.', style: TextStyle(color: AppColors.muted, height: 1.55)), const SizedBox(height: 24), const SectionHeader(title: 'Popular lessons'), const SizedBox(height: 10),
    ...['Portfolio stories recruiters remember', 'How to think in design systems', 'A practical guide to design critique'].asMap().entries.map((e) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(contentPadding: const EdgeInsets.all(12), leading: Container(width: 62, height: 62, decoration: BoxDecoration(color: [AppColors.orangeSoft, const Color(0xFFDDE7FF), const Color(0xFFE7F5DF)][e.key], borderRadius: BorderRadius.circular(17)), child: const Icon(Icons.play_arrow_rounded, color: AppColors.navy)), title: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${8 + e.key * 4} min · ${2 + e.key}k views')))),
  ]))));
}

class InternshipListingScreen extends StatelessWidget {
  const InternshipListingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.only(bottom: 28), children: [
    const PageHeader(title: 'Experience starts here', subtitle: 'Internships matched to your skills and goals.'), const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: SearchBox(hint: 'Role, skill or company')), const SizedBox(height: 16),
    SizedBox(height: 42, child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), scrollDirection: Axis.horizontal, children: const [Chip(label: Text('Best matches'), backgroundColor: AppColors.navy, labelStyle: TextStyle(color: Colors.white)), SizedBox(width: 8), Chip(label: Text('Remote')), SizedBox(width: 8), Chip(label: Text('Paid')), SizedBox(width: 8), Chip(label: Text('Part time'))])),
    const SizedBox(height: 22), Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: MockData.internships.map((o) => Card(margin: const EdgeInsets.only(bottom: 13), child: InkWell(borderRadius: BorderRadius.circular(26), onTap: () => context.push('/internships/details'), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: o.color, borderRadius: BorderRadius.circular(17)), child: Icon(o.icon, color: AppColors.navy)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(o.title, style: Theme.of(context).textTheme.titleMedium), Text(o.organization, style: const TextStyle(color: AppColors.muted))])), const Icon(Icons.bookmark_border_rounded)]), const SizedBox(height: 14), Text(o.meta, style: const TextStyle(fontSize: 12)), const SizedBox(height: 12), Row(children: [StatusPill('${88 - MockData.internships.indexOf(o) * 6}% MATCH', color: const Color(0xFFE7F5DF), foreground: AppColors.green), const Spacer(), const Text('2d left', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800))])]))))).toList())),
  ]))));
}

class InternshipDetailsScreen extends StatelessWidget {
  const InternshipDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 12), child: ElevatedButton(onPressed: () => context.push('/internships/apply'), child: const Text('Apply now  →')))), body: SafeArea(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.fromLTRB(20, 14, 20, 30), children: [
    Row(children: [RoundIconButton(icon: Icons.arrow_back_rounded, onTap: () => context.pop()), const Spacer(), RoundIconButton(icon: Icons.bookmark_border_rounded, onTap: () {})]), const SizedBox(height: 22),
    const CircleAvatar(radius: 34, backgroundColor: AppColors.orangeSoft, child: Icon(Icons.design_services_rounded, color: AppColors.navy, size: 33)), const SizedBox(height: 16), Text('Product Design Intern', style: Theme.of(context).textTheme.headlineLarge), const SizedBox(height: 6), const Text('Nova Labs · Remote', style: TextStyle(color: AppColors.muted, fontSize: 16)), const SizedBox(height: 16),
    const Wrap(spacing: 8, runSpacing: 8, children: [StatusPill('₹15k / month'), StatusPill('3 months', color: Color(0xFFDDE7FF)), StatusPill('Starts Aug 2026', color: Color(0xFFE7F5DF))]), const SizedBox(height: 24),
    const SectionHeader(title: 'About the role'), const Text('Work with a small product team to research, prototype, and ship thoughtful experiences used by thousands of learners.', style: TextStyle(color: AppColors.muted, height: 1.55)), const SizedBox(height: 22),
    const SectionHeader(title: 'What you’ll do'), ...['Turn user insights into clear product flows', 'Create wireframes and interactive prototypes', 'Collaborate with product and engineering', 'Present work and learn through critique'].map((x) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20), const SizedBox(width: 10), Expanded(child: Text(x))]))), const SizedBox(height: 22),
    const SectionHeader(title: 'Your match'), Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [const ProgressRing(value: .88, size: 70), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Strong match', style: Theme.of(context).textTheme.titleMedium), const Text('You have 5 of 6 required skills.', style: TextStyle(color: AppColors.muted)), const SizedBox(height: 7), const Text('View skill breakdown  →', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800))]))]))),
  ]))));
}

class ApplicationScreen extends StatefulWidget {
  const ApplicationScreen({super.key});
  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}
class _ApplicationScreenState extends State<ApplicationScreen> {
  int step = 0;
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.only(bottom: 28), children: [
    PageHeader(title: step == 2 ? 'Application ready!' : 'Apply to Nova Labs', subtitle: 'Product Design Intern'),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [
      if (step < 2) ...[Row(children: List.generate(3, (i) => Expanded(child: Container(height: 6, margin: EdgeInsets.only(right: i < 2 ? 7 : 0), decoration: BoxDecoration(color: i <= step ? AppColors.orange : AppColors.line, borderRadius: BorderRadius.circular(8)))))), const SizedBox(height: 28)],
      if (step == 0) ...[const TextField(decoration: InputDecoration(labelText: 'Full name')), const SizedBox(height: 14), const TextField(decoration: InputDecoration(labelText: 'Email address')), const SizedBox(height: 14), const TextField(decoration: InputDecoration(labelText: 'Phone number')), const SizedBox(height: 14), Card(child: ListTile(contentPadding: const EdgeInsets.all(16), leading: const CircleAvatar(backgroundColor: AppColors.orangeSoft, child: Icon(Icons.upload_file_rounded, color: AppColors.orange)), title: const Text('Upload your resume', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('PDF · max 5 MB'), trailing: const Icon(Icons.add_rounded)))],
      if (step == 1) ...[const TextField(maxLines: 5, decoration: InputDecoration(labelText: 'Why are you excited about this role?', alignLabelWithHint: true)), const SizedBox(height: 14), const TextField(decoration: InputDecoration(labelText: 'Portfolio link', prefixIcon: Icon(Icons.link_rounded))), const SizedBox(height: 14), Card(child: CheckboxListTile(value: true, onChanged: (_) {}, title: const Text('Share my EduNova skills profile', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Helps Nova Labs see your verified learning progress')))],
      if (step == 2) ...[const SizedBox(height: 30), Container(width: 108, height: 108, decoration: const BoxDecoration(color: Color(0xFFE7F5DF), shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: AppColors.green, size: 55)), const SizedBox(height: 22), Text('You’re all set.', style: Theme.of(context).textTheme.headlineLarge), const SizedBox(height: 8), const Text('Your application is polished and ready to submit.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)), const SizedBox(height: 28), Card(child: const ListTile(contentPadding: EdgeInsets.all(16), leading: CircleAvatar(backgroundColor: AppColors.orangeSoft, child: Icon(Icons.design_services_rounded)), title: Text('Product Design Intern', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('Nova Labs · Remote')))],
      const SizedBox(height: 26), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { if (step < 2) setState(() => step++); else context.go('/home'); }, child: Text(step == 0 ? 'Continue' : step == 1 ? 'Review application' : 'Back to home'))),
    ])),
  ]))));
}

class ExamDashboardScreen extends StatelessWidget {
  const ExamDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: DotGridBackground(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.only(bottom: 30), children: [
    const PageHeader(title: 'Exam preparation', subtitle: 'Focused plans for ambitious goals.'),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(30)), child: const Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [StatusPill('YOUR ACTIVE EXAM', color: Colors.white12, foreground: Colors.white), SizedBox(height: 14), Text('UPSC Civil Services', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)), SizedBox(height: 6), Text('Prelims · 281 days to go', style: TextStyle(color: Colors.white60)), SizedBox(height: 16), LinearProgressIndicator(value: .37, color: AppColors.orange, backgroundColor: Colors.white12, minHeight: 7)])), SizedBox(width: 18), ProgressRing(value: .37, size: 72, color: AppColors.orange)])),
      const SizedBox(height: 22), const Row(children: [Expanded(child: _ExamStat('62%', 'Readiness')), SizedBox(width: 10), Expanded(child: _ExamStat('18', 'Mock tests')), SizedBox(width: 10), Expanded(child: _ExamStat('14d', 'Streak'))]), const SizedBox(height: 24),
      SectionHeader(title: 'Continue preparation', action: 'Details', onTap: () => context.push('/exams/details')), const SizedBox(height: 10),
      Card(child: ListTile(onTap: () => context.push('/exams/details'), contentPadding: const EdgeInsets.all(15), leading: const CircleAvatar(radius: 25, backgroundColor: AppColors.orangeSoft, child: Icon(Icons.public_rounded, color: AppColors.orange)), title: const Text('Indian Polity', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: const Text('Fundamental Rights · 18 min'), trailing: const Icon(Icons.play_circle_fill_rounded, color: AppColors.orange, size: 33))),
      const SizedBox(height: 24), const SectionHeader(title: 'Popular exams'), const SizedBox(height: 10),
      ...[('SSC CGL', '12 modules · 124 mock tests', Icons.business_center_rounded, Color(0xFFDDE7FF)), ('IBPS PO', '10 modules · 96 mock tests', Icons.account_balance_rounded, Color(0xFFE7F5DF)), ('GATE CSE', '18 modules · 82 mock tests', Icons.computer_rounded, Color(0xFFFFE9AF))].map((x) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(contentPadding: const EdgeInsets.all(14), leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: x.$4, borderRadius: BorderRadius.circular(16)), child: Icon(x.$3, color: AppColors.navy)), title: Text(x.$1, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(x.$2), trailing: const Icon(Icons.chevron_right_rounded)))),
    ])),
  ])))));
}
class _ExamStat extends StatelessWidget { const _ExamStat(this.value, this.label); final String value; final String label; @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5), child: Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: AppColors.heading)), Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10))]))); }

class ExamDetailsScreen extends StatelessWidget {
  const ExamDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.only(bottom: 30), children: [
    const PageHeader(title: 'UPSC Civil Services', subtitle: 'Prelims · 24 May 2027'),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [const Row(children: [ProgressRing(value: .62, size: 82), SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('62% exam ready', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.heading)), SizedBox(height: 5), Text('Your consistency is paying off.', style: TextStyle(color: AppColors.muted))]))]), const SizedBox(height: 18), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: null, child: Text('Take a mock test')))]))), const SizedBox(height: 24),
      const SectionHeader(title: 'Syllabus progress'), const SizedBox(height: 10),
      ...[('Indian Polity', .78, Icons.account_balance_rounded), ('History & Culture', .61, Icons.museum_rounded), ('Geography', .42, Icons.public_rounded), ('Economy', .28, Icons.trending_up_rounded), ('Environment', .16, Icons.eco_rounded)].map((x) => Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [CircleAvatar(backgroundColor: AppColors.chipBg, child: Icon(x.$3, color: AppColors.navy)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(x.$1, style: const TextStyle(fontWeight: FontWeight.w800))), Text('${(x.$2 * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w900))]), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: x.$2, minHeight: 6, color: AppColors.orange, backgroundColor: AppColors.line))])), const SizedBox(width: 8), const Icon(Icons.chevron_right_rounded)])))),
      const SizedBox(height: 16), const SectionHeader(title: 'Exam pattern'), const SizedBox(height: 10), Card(child: const Column(children: [ListTile(title: Text('General Studies Paper I', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('100 questions · 200 marks · 2 hours')), Divider(height: 1), ListTile(title: Text('CSAT Paper II', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('80 questions · 200 marks · 2 hours'))])),
    ])),
  ]))));
}
