import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/ui.dart';

class MentorDashboardScreen extends StatelessWidget {
  const MentorDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => DotGridBackground(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 28), children: [
    Row(children: [const BrandMark(compact: true), const Spacer(), RoundIconButton(icon: Icons.history_rounded, onTap: () {})]), const SizedBox(height: 28),
    const StatusPill('YOUR AI CAREER MENTOR', icon: Icons.auto_awesome_rounded), const SizedBox(height: 14), Text('Big questions.\nClear next steps.', style: Theme.of(context).textTheme.displayMedium), const SizedBox(height: 10), const Text('Nova understands your goals, learning history, and the careers you’re exploring.', style: TextStyle(color: AppColors.muted, height: 1.5)), const SizedBox(height: 22),
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(32)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 54, height: 54, decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white)), const SizedBox(width: 13), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Nova', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 19)), Text('Online · Ready when you are', style: TextStyle(color: Colors.white60, fontSize: 12))])), const StatusPill('AI', color: Colors.white12, foreground: Colors.white)]),
      const SizedBox(height: 20), const Text('“Tell me what’s on your mind—choosing a course, planning a career, or just feeling stuck.”', style: TextStyle(color: Colors.white, fontSize: 18, height: 1.4, fontWeight: FontWeight.w600)), const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy, padding: const EdgeInsets.all(16)), onPressed: () => context.push('/mentor/chat'), icon: const Icon(Icons.chat_bubble_rounded), label: const Text('Start a conversation', style: TextStyle(fontWeight: FontWeight.w900)))),
    ])), const SizedBox(height: 26),
    const SectionHeader(title: 'Try asking Nova'), const SizedBox(height: 12),
    ...[
      ('Which career fits my strengths?', Icons.psychology_alt_rounded, const Color(0xFFFFD7C2)),
      ('Build me a 30-day study plan', Icons.calendar_month_rounded, const Color(0xFFDDE7FF)),
      ('Review my learning progress', Icons.insights_rounded, const Color(0xFFE7F5DF)),
    ].map((item) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(onTap: () => context.push('/mentor/chat'), leading: Container(width: 45, height: 45, decoration: BoxDecoration(color: item.$3, borderRadius: BorderRadius.circular(14)), child: Icon(item.$2, color: AppColors.navy)), title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w800)), trailing: const Icon(Icons.arrow_outward_rounded)))),
    const SizedBox(height: 18), SectionHeader(title: 'Made for you', action: 'View all', onTap: () => context.push('/mentor/recommendations')), const SizedBox(height: 12),
    Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [const ProgressRing(value: .78, size: 67, label: '78%'), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const StatusPill('CAREER MATCH', color: Color(0xFFE7F5DF), foreground: AppColors.green), const SizedBox(height: 8), Text('Product Designer', style: Theme.of(context).textTheme.titleLarge), const Text('Strong match with your creative and analytical strengths.', style: TextStyle(color: AppColors.muted, fontSize: 12))])), const Icon(Icons.chevron_right_rounded)]))),
  ])));
}

class MentorChatScreen extends StatefulWidget {
  const MentorChatScreen({super.key});
  @override
  State<MentorChatScreen> createState() => _MentorChatScreenState();
}
class _MentorChatScreenState extends State<MentorChatScreen> {
  final controller = TextEditingController();
  final messages = <(bool, String)>[
    (false, 'Hi Alex! I’m Nova. I’ve looked at your learning progress and interests. What would you like to figure out today?'),
    (true, 'I enjoy design and technology, but I’m not sure which career combines both.'),
    (false, 'That combination opens some exciting paths. Product Design looks especially promising for you—it blends user psychology, visual craft, and technology. Would you like me to build a starter roadmap?'),
  ];
  void send() { if (controller.text.trim().isEmpty) return; setState(() { messages.add((true, controller.text.trim())); messages.add((false, 'Great question. Based on your goals, I’d start with one focused skill this week and turn it into a small portfolio project. I can map that out for you.')); controller.clear(); }); }
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 12), child: Row(children: [RoundIconButton(icon: Icons.arrow_back_rounded, onTap: () => context.pop()), const SizedBox(width: 12), const CircleAvatar(backgroundColor: AppColors.orange, child: Icon(Icons.auto_awesome_rounded, color: Colors.white)), const SizedBox(width: 10), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Nova', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.heading)), Text('Your AI mentor · Online', style: TextStyle(color: AppColors.green, fontSize: 11))])), IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz_rounded))])),
    Expanded(child: DotGridBackground(child: ListView.builder(padding: const EdgeInsets.all(18), itemCount: messages.length, itemBuilder: (_, i) { final m = messages[i]; return Align(alignment: m.$1 ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(15), constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78), decoration: BoxDecoration(color: m.$1 ? AppColors.navy : Colors.white, borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: Radius.circular(m.$1 ? 20 : 5), bottomRight: Radius.circular(m.$1 ? 5 : 20)), boxShadow: m.$1 ? null : [BoxShadow(color: AppColors.navy.withValues(alpha: .06), blurRadius: 12)]), child: Text(m.$2, style: TextStyle(color: m.$1 ? Colors.white : AppColors.ink, height: 1.45)))); }))),
    Container(padding: const EdgeInsets.fromLTRB(14, 10, 14, 12), color: AppColors.white, child: SafeArea(top: false, child: Row(children: [IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline_rounded)), Expanded(child: TextField(controller: controller, onSubmitted: (_) => send(), decoration: const InputDecoration(hintText: 'Ask Nova anything...', isDense: true))), const SizedBox(width: 8), IconButton.filled(style: IconButton.styleFrom(backgroundColor: AppColors.orange), onPressed: send, icon: const Icon(Icons.arrow_upward_rounded))]))),
  ])));
}

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
    const PageHeader(title: 'Made for you', subtitle: 'AI recommendations based on your goals and progress.'),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(30)), child: const Row(children: [CircleAvatar(radius: 28, backgroundColor: AppColors.orange, child: Icon(Icons.auto_awesome_rounded, color: Colors.white)), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your weekly insight', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)), SizedBox(height: 5), Text('You learn 24% faster with project-based courses.', style: TextStyle(color: Colors.white70, height: 1.35))]))])),
      const SizedBox(height: 24), const SectionHeader(title: 'Career matches'), const SizedBox(height: 10),
      ...[('Product Designer', '92%', AppColors.orangeSoft), ('UX Researcher', '86%', Color(0xFFDDE7FF)), ('Creative Technologist', '81%', Color(0xFFE7F5DF))].map((x) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(contentPadding: const EdgeInsets.all(14), leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: x.$3, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.arrow_outward_rounded, color: AppColors.navy)), title: Text(x.$1, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: const Text('Skills, growth, and values alignment'), trailing: StatusPill(x.$2)))),
      const SizedBox(height: 18), const SectionHeader(title: 'Next best actions'), const SizedBox(height: 10),
      ...[('Finish your design foundations course', '20 min left', Icons.play_circle_rounded), ('Create your first portfolio project', 'Guided project', Icons.folder_special_rounded), ('Explore the Product Design roadmap', '6 milestones', Icons.route_rounded)].map((x) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(onTap: () => x.$3 == Icons.route_rounded ? context.push('/roadmap') : null, leading: CircleAvatar(backgroundColor: AppColors.chipBg, child: Icon(x.$3, color: AppColors.orange)), title: Text(x.$1, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(x.$2), trailing: const Icon(Icons.chevron_right_rounded)))),
    ])),
  ]))));
}
