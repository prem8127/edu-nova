import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../shared/widgets/ui.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => DotGridBackground(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 30), children: [
    Row(children: [Text('Your profile', style: Theme.of(context).textTheme.headlineMedium), const Spacer(), RoundIconButton(icon: Icons.settings_outlined, onTap: () => context.push('/settings'))]), const SizedBox(height: 24),
    Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Stack(clipBehavior: Clip.none, children: [const CircleAvatar(radius: 48, backgroundColor: AppColors.orangeSoft, child: Text('AK', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.navy))), Positioned(right: -3, bottom: -3, child: Container(width: 31, height: 31, decoration: BoxDecoration(color: AppColors.orange, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)), child: const Icon(Icons.edit_rounded, color: Colors.white, size: 15)))]), const SizedBox(height: 13),
      Text('Alex Kumar', style: Theme.of(context).textTheme.headlineMedium), const Text('Aspiring Product Designer', style: TextStyle(color: AppColors.muted)), const SizedBox(height: 14),
      const Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [StatusPill('12 day streak', icon: Icons.local_fire_department_rounded), StatusPill('Level 8', color: Color(0xFFDDE7FF), icon: Icons.bolt_rounded)]), const SizedBox(height: 18),
      SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => context.push('/profile/edit'), style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)), child: const Text('Edit profile'))),
    ]))), const SizedBox(height: 18),
    const Row(children: [Expanded(child: _ProfileStat('28h', 'Learned')), SizedBox(width: 10), Expanded(child: _ProfileStat('6', 'Certificates')), SizedBox(width: 10), Expanded(child: _ProfileStat('1,840', 'XP earned'))]), const SizedBox(height: 26),
    const SectionHeader(title: 'Skills & interests'), const SizedBox(height: 10), const Wrap(spacing: 8, runSpacing: 8, children: [Chip(label: Text('UI Design')), Chip(label: Text('UX Research')), Chip(label: Text('Technology')), Chip(label: Text('Product Thinking')), Chip(label: Text('+ Add skill'))]), const SizedBox(height: 26),
    const SectionHeader(title: 'Achievements'), const SizedBox(height: 10), SizedBox(height: 105, child: ListView(scrollDirection: Axis.horizontal, children: const [
      _Badge(Icons.local_fire_department_rounded, 'On fire', AppColors.orangeSoft), SizedBox(width: 10), _Badge(Icons.school_rounded, 'Fast learner', Color(0xFFDDE7FF)), SizedBox(width: 10), _Badge(Icons.emoji_events_rounded, 'Top 10%', Color(0xFFFFE9AF)), SizedBox(width: 10), _Badge(Icons.groups_rounded, 'Helper', Color(0xFFE7F5DF)),
    ])), const SizedBox(height: 26),
    const SectionHeader(title: 'Recent certificates'), const SizedBox(height: 10), Card(child: ListTile(contentPadding: const EdgeInsets.all(15), leading: const CircleAvatar(radius: 25, backgroundColor: AppColors.orangeSoft, child: Icon(Icons.workspace_premium_rounded, color: AppColors.orange)), title: const Text('Design Thinking Essentials', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: const Text('Issued June 2026'), trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share_rounded)))),
  ])));
}
class _ProfileStat extends StatelessWidget { const _ProfileStat(this.value, this.label); final String value; final String label; @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4), child: Column(children: [Text(value, style: const TextStyle(fontSize: 19, color: AppColors.heading, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 10, color: AppColors.muted))]))); }
class _Badge extends StatelessWidget { const _Badge(this.icon, this.label, this.color); final IconData icon; final String label; final Color color; @override Widget build(BuildContext context) => Container(width: 92, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(backgroundColor: color, child: Icon(icon, color: AppColors.navy)), const SizedBox(height: 7), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.navy))])); }

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.only(bottom: 28), children: [
    PageHeader(title: 'Edit profile', trailing: TextButton(onPressed: () => context.pop(), child: const Text('Save', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w900)))),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [
      const CircleAvatar(radius: 48, backgroundColor: AppColors.orangeSoft, child: Text('AK', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.navy))), TextButton(onPressed: () {}, child: const Text('Change photo', style: TextStyle(color: AppColors.orange))), const SizedBox(height: 16),
      const TextField(controller: null, decoration: InputDecoration(labelText: 'Full name', hintText: 'Alex Kumar')), const SizedBox(height: 14), const TextField(decoration: InputDecoration(labelText: 'Headline', hintText: 'Aspiring Product Designer')), const SizedBox(height: 14), const TextField(maxLines: 4, decoration: InputDecoration(labelText: 'About', hintText: 'Tell people about your goals...', alignLabelWithHint: true)), const SizedBox(height: 14), const TextField(decoration: InputDecoration(labelText: 'Location', hintText: 'Hyderabad, India', prefixIcon: Icon(Icons.location_on_outlined))), const SizedBox(height: 14), const TextField(decoration: InputDecoration(labelText: 'Portfolio URL', hintText: 'https://', prefixIcon: Icon(Icons.link_rounded))), const SizedBox(height: 24),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => context.pop(), child: const Text('Save changes'))),
    ])),
  ]))));
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  bool reminders = true, mentorTips = true, marketing = false, dark = false;
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.only(bottom: 28), children: [
    const PageHeader(title: 'Settings', subtitle: 'Make EduNova work your way.'),
    _group(context, 'Preferences', [
      SwitchListTile(value: dark, onChanged: (v) => setState(() => dark = v), secondary: const Icon(Icons.dark_mode_outlined), title: const Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Coming soon across all screens')),
      ListTile(leading: const Icon(Icons.language_rounded), title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('English'), trailing: const Icon(Icons.chevron_right_rounded)),
    ]),
    _group(context, 'Notifications', [
      SwitchListTile(value: reminders, onChanged: (v) => setState(() => reminders = v), secondary: const Icon(Icons.notifications_active_outlined), title: const Text('Learning reminders', style: TextStyle(fontWeight: FontWeight.w800))),
      SwitchListTile(value: mentorTips, onChanged: (v) => setState(() => mentorTips = v), secondary: const Icon(Icons.auto_awesome_outlined), title: const Text('AI mentor tips', style: TextStyle(fontWeight: FontWeight.w800))),
      SwitchListTile(value: marketing, onChanged: (v) => setState(() => marketing = v), secondary: const Icon(Icons.campaign_outlined), title: const Text('Offers & updates', style: TextStyle(fontWeight: FontWeight.w800))),
    ]),
    _group(context, 'Account', [
      const ListTile(leading: Icon(Icons.shield_outlined), title: Text('Privacy & security', style: TextStyle(fontWeight: FontWeight.w800)), trailing: Icon(Icons.chevron_right_rounded)),
      const ListTile(leading: Icon(Icons.help_outline_rounded), title: Text('Help & support', style: TextStyle(fontWeight: FontWeight.w800)), trailing: Icon(Icons.chevron_right_rounded)),
      ListTile(onTap: () => context.go('/admin'), leading: const Icon(Icons.admin_panel_settings_rounded), title: const Text('Switch to admin panel', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('For staff & institution admins'), trailing: const Icon(Icons.chevron_right_rounded)),
      ListTile(onTap: () => context.go('/login'), leading: const Icon(Icons.logout_rounded, color: Colors.redAccent), title: const Text('Sign out', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.redAccent))),
    ]),
    const Center(child: Text('EduNova 1.0.0 · Made for ambitious minds', style: TextStyle(color: AppColors.muted, fontSize: 11))),
  ]))));
  Widget _group(BuildContext context, String title, List<Widget> children) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 9), Card(child: Column(children: List.generate(children.length, (i) => Column(children: [children[i], if (i < children.length - 1) const Divider(height: 1, indent: 56)]))))]));
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}
class _NotificationScreenState extends State<NotificationScreen> {
  bool unreadOnly = false;
  @override
  Widget build(BuildContext context) {
    final items = unreadOnly ? MockData.notifications.where((n) => n.isNew).toList() : MockData.notifications;
    return Scaffold(body: SafeArea(child: ResponsiveContent(child: Column(children: [
      PageHeader(title: 'Notifications', subtitle: 'Stay close to what matters.', trailing: TextButton(onPressed: () {}, child: const Text('Read all', style: TextStyle(color: AppColors.orange)))),
      Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 14), child: Row(children: [ChoiceChip(label: const Text('All'), selected: !unreadOnly, selectedColor: AppColors.navy, labelStyle: TextStyle(color: !unreadOnly ? Colors.white : AppColors.heading), onSelected: (_) => setState(() => unreadOnly = false)), const SizedBox(width: 8), ChoiceChip(label: const Text('Unread'), selected: unreadOnly, selectedColor: AppColors.navy, labelStyle: TextStyle(color: unreadOnly ? Colors.white : AppColors.heading), onSelected: (_) => setState(() => unreadOnly = true))])),
      Expanded(child: items.isEmpty ? const EmptyState(icon: Icons.notifications_off_outlined, title: 'All caught up', body: 'New updates will appear here.') : ListView.separated(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) { final n = items[i]; return Card(child: ListTile(contentPadding: const EdgeInsets.all(14), leading: Stack(clipBehavior: Clip.none, children: [CircleAvatar(radius: 25, backgroundColor: n.color, child: Icon(n.icon, color: AppColors.navy)), if (n.isNew) const Positioned(right: -1, top: -1, child: CircleAvatar(radius: 5, backgroundColor: AppColors.orange))]), title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text(n.body)), trailing: Text(n.time, style: const TextStyle(fontSize: 9, color: AppColors.muted)))); })),
    ]))));
  }
}
