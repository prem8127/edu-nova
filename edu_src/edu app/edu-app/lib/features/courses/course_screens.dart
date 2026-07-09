import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/app_models.dart';
import '../../shared/widgets/ui.dart';

class CourseListingScreen extends StatefulWidget {
  const CourseListingScreen({super.key});
  @override
  State<CourseListingScreen> createState() => _CourseListingScreenState();
}
class _CourseListingScreenState extends State<CourseListingScreen> {
  int selected = 0;
  final categories = const ['All', 'Design', 'Technology', 'Business', 'Finance'];
  @override
  Widget build(BuildContext context) {
    final courses = selected == 0 ? MockData.courses : MockData.courses.where((c) => c.category == categories[selected]).toList();
    return DotGridBackground(child: ResponsiveContent(child: CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text('Learn without\nlimits.', style: Theme.of(context).textTheme.displayMedium)), RoundIconButton(icon: Icons.bookmark_border_rounded, onTap: () {})]),
        const SizedBox(height: 20), SearchBox(onFilter: () => showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => const _FilterSheet())), const SizedBox(height: 16),
        SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: categories.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => ChoiceChip(label: Text(categories[i]), selected: selected == i, selectedColor: AppColors.navy, labelStyle: TextStyle(color: selected == i ? Colors.white : AppColors.heading, fontWeight: FontWeight.w800), onSelected: (_) => setState(() => selected = i)))),
        const SizedBox(height: 24), SectionHeader(title: '${courses.length} courses', action: 'Popular ↓'), const SizedBox(height: 12),
      ]))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 28), sliver: SliverList.separated(itemCount: courses.length, itemBuilder: (_, i) => CourseCard(course: courses[i], horizontal: true, onTap: () => context.push('/courses/details', extra: courses[i])), separatorBuilder: (_, __) => const SizedBox(height: 14))),
    ])));
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();
  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(22, 8, 22, 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Shape your results', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 20),
    const Text('Level', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 8), const Wrap(spacing: 8, children: [Chip(label: Text('Beginner')), Chip(label: Text('Intermediate')), Chip(label: Text('Advanced'))]),
    const SizedBox(height: 16), const Text('Duration', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 8), const Wrap(spacing: 8, children: [Chip(label: Text('< 4 weeks')), Chip(label: Text('4–8 weeks')), Chip(label: Text('8+ weeks'))]),
    const SizedBox(height: 22), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Show 24 courses'))),
  ])));
}

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final course = extra is Course ? extra : MockData.courses.first;
    final firstUnlockedChapter = course.chapters.isEmpty ? null : course.chapters.indexWhere((c) => c.lessons.any((l) => !l.locked));
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ElevatedButton(
            onPressed: course.chapters.isEmpty
                ? null
                : () {
                    final ci = firstUnlockedChapter != null && firstUnlockedChapter >= 0 ? firstUnlockedChapter : 0;
                    final li = course.chapters[ci].lessons.indexWhere((l) => !l.completed);
                    context.push('/courses/video', extra: {'course': course, 'chapterIndex': ci, 'lessonIndex': li < 0 ? 0 : li});
                  },
            child: Text(course.progress > 0 ? 'Continue learning  →' : 'Enroll for free  →'),
          ),
        ),
      ),
      body: SafeArea(child: DotGridBackground(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.fromLTRB(20, 14, 20, 24), children: [
        Row(children: [RoundIconButton(icon: Icons.arrow_back_rounded, onTap: () => context.pop()), const Spacer(), RoundIconButton(icon: Icons.bookmark_border_rounded, onTap: () {}), const SizedBox(width: 8), RoundIconButton(icon: Icons.ios_share_rounded, onTap: () {})]), const SizedBox(height: 18),
        Container(height: 250, decoration: BoxDecoration(color: course.color, borderRadius: BorderRadius.circular(34)), child: Stack(children: [
          Positioned(right: -18, top: -28, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.navy.withValues(alpha: .08), width: 26)))),
          Center(child: Icon(course.icon, size: 82, color: AppColors.navy)), const Positioned(left: 18, top: 18, child: StatusPill('BESTSELLER', color: Colors.white)),
        ])), const SizedBox(height: 22), Text(course.title, style: Theme.of(context).textTheme.headlineLarge), const SizedBox(height: 10),
        Text(course.description, style: const TextStyle(color: AppColors.muted, height: 1.5)), const SizedBox(height: 16),
        Row(children: [const Icon(Icons.star_rounded, color: AppColors.orange), Text(' ${course.rating}  ', style: const TextStyle(fontWeight: FontWeight.w900)), Text('(${course.learners} learners)', style: const TextStyle(color: AppColors.muted)), const Spacer(), const StatusPill('Certificate')]), const SizedBox(height: 24),
        _InstructorCard(name: course.teacherName, role: course.teacherRole, initials: course.teacherInitials),
        const SizedBox(height: 25),
        Row(children: [Expanded(child: SectionHeader(title: 'Course content · ${course.totalLessons} lessons')), TextButton(onPressed: () => context.push('/courses/progress'), child: const Text('View progress', style: TextStyle(color: AppColors.orange)))]),
        const SizedBox(height: 8),
        if (course.chapters.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('The teacher hasn’t published a syllabus for this course yet.', style: TextStyle(color: AppColors.muted)))
        else
          ...course.chapters.asMap().entries.map((entry) {
            final chapterIndex = entry.key;
            final chapter = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 9),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                initiallyExpanded: chapterIndex == 0,
                leading: CircleAvatar(backgroundColor: chapterIndex == 0 ? AppColors.orange : AppColors.chipBg, child: Text('${chapterIndex + 1}', style: TextStyle(color: chapterIndex == 0 ? Colors.white : AppColors.navy, fontWeight: FontWeight.w900))),
                title: Text(chapter.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${chapter.lessons.length} recorded lessons'),
                children: chapter.lessons.asMap().entries.map((lessonEntry) {
                  final lessonIndex = lessonEntry.key;
                  final lesson = lessonEntry.value;
                  return ListTile(
                    leading: Icon(lesson.completed ? Icons.check_circle_rounded : (lesson.locked ? Icons.lock_outline_rounded : Icons.play_circle_fill_rounded), color: lesson.completed ? AppColors.green : (lesson.locked ? AppColors.muted : AppColors.orange)),
                    title: Text(lesson.title),
                    subtitle: Text(lesson.duration),
                    onTap: lesson.locked ? null : () => context.push('/courses/video', extra: {'course': course, 'chapterIndex': chapterIndex, 'lessonIndex': lessonIndex}),
                  );
                }).toList(),
              ),
            );
          }),
      ])))),
    );
  }
}

class _InstructorCard extends StatelessWidget {
  const _InstructorCard({required this.name, required this.role, required this.initials});
  final String name;
  final String role;
  final String initials;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [CircleAvatar(radius: 27, backgroundColor: AppColors.orangeSoft, child: Text(initials, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.navy))), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: Theme.of(context).textTheme.titleMedium), Text(role, style: const TextStyle(color: AppColors.muted, fontSize: 12))])), const Icon(Icons.verified_rounded, color: AppColors.blue)])));
}

class VideoLearningScreen extends StatefulWidget {
  const VideoLearningScreen({super.key});
  @override
  State<VideoLearningScreen> createState() => _VideoLearningScreenState();
}
class _VideoLearningScreenState extends State<VideoLearningScreen> {
  bool playing = false;
  late Course course;
  late int chapterIndex;
  late int lessonIndex;
  bool _initialized = false;

  // Flattened (chapterIndex, lessonIndex, lesson) list across the whole course.
  List<(int, int, Lesson)> get _flatLessons => [
        for (final c in course.chapters.asMap().entries)
          for (final l in c.value.lessons.asMap().entries) (c.key, l.key, l.value),
      ];

  void _playAt(int ci, int li) => setState(() {
        chapterIndex = ci;
        lessonIndex = li;
        playing = false;
      });

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map) {
        course = extra['course'] as Course? ?? MockData.courses.first;
        chapterIndex = (extra['chapterIndex'] as int?) ?? 0;
        lessonIndex = (extra['lessonIndex'] as int?) ?? 0;
      } else {
        course = MockData.courses.first;
        chapterIndex = 0;
        lessonIndex = 0;
      }
      _initialized = true;
    }
    final flat = _flatLessons;
    final currentFlatIndex = flat.indexWhere((e) => e.$1 == chapterIndex && e.$2 == lessonIndex);
    final chapter = course.chapters.isNotEmpty ? course.chapters[chapterIndex] : null;
    final lesson = chapter != null && chapter.lessons.isNotEmpty ? chapter.lessons[lessonIndex] : null;
    final upNext = currentFlatIndex >= 0 ? flat.skip(currentFlatIndex + 1).take(3).toList() : <(int, int, Lesson)>[];

    return Scaffold(backgroundColor: AppColors.navy, body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        RoundIconButton(icon: Icons.arrow_back_rounded, dark: true, onTap: () => context.pop()),
        const SizedBox(width: 12),
        Expanded(child: Text(course.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
        Text('${currentFlatIndex + 1} / ${flat.length}', style: const TextStyle(color: Colors.white70)),
      ])),
      AspectRatio(aspectRatio: 16 / 10, child: Container(color: const Color(0xFF1D2B4F), child: Stack(alignment: Alignment.center, children: [
        Icon(course.icon, color: Colors.white.withValues(alpha: .12), size: 130),
        GestureDetector(onTap: () => setState(() => playing = !playing), child: Container(width: 68, height: 68, decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle), child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 36))),
        Positioned(left: 18, right: 18, bottom: 14, child: Column(children: [
          const LinearProgressIndicator(value: .32, color: AppColors.orange, backgroundColor: Colors.white24),
          const SizedBox(height: 8),
          Row(children: [const Text('04:12', style: TextStyle(color: Colors.white, fontSize: 12)), const Spacer(), Text(lesson?.duration ?? '--:--', style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(width: 10), const Icon(Icons.fullscreen_rounded, color: Colors.white)]),
        ])),
      ]))),
      Expanded(child: Container(decoration: const BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.vertical(top: Radius.circular(30))), child: ListView(padding: const EdgeInsets.all(20), children: [
        StatusPill('CHAPTER ${chapterIndex + 1} · LESSON ${lessonIndex + 1}'),
        const SizedBox(height: 12),
        Text(lesson?.title ?? 'Lesson', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(lesson?.description ?? '', style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 6),
        Row(children: [const Icon(Icons.person_rounded, size: 16, color: AppColors.muted), const SizedBox(width: 4), Text('Taught by ${course.teacherName}', style: const TextStyle(color: AppColors.muted, fontSize: 12))]),
        const SizedBox(height: 22),
        Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.description_outlined), label: const Text('Resources'))), const SizedBox(width: 10), Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.check_rounded), label: const Text('Complete')))]),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Up next'),
        const SizedBox(height: 8),
        if (upNext.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('You’ve reached the end of this course’s recorded lessons.', style: TextStyle(color: AppColors.muted)))
        else
          ...upNext.asMap().entries.map((e) {
            final (ci, li, nextLesson) = e.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: e.key == 0 ? AppColors.orangeSoft : AppColors.chipBg, child: Icon(nextLesson.locked ? Icons.lock_outline_rounded : Icons.play_arrow_rounded, color: AppColors.navy)),
                title: Text(nextLesson.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(nextLesson.duration),
                onTap: nextLesson.locked ? null : () => _playAt(ci, li),
              ),
            );
          }),
      ]))),
    ])));
  }
}

class LearningProgressScreen extends StatelessWidget {
  const LearningProgressScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: ResponsiveContent(child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
    const PageHeader(title: 'Learning progress', subtitle: 'A clear view of how far you’ve come.'),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [
      Card(child: Padding(padding: const EdgeInsets.all(22), child: Row(children: [const ProgressRing(value: .68, size: 104, lineWidth: 10), const SizedBox(width: 20), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('You’re doing great.', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 6), const Text('12 of 18 lessons complete', style: TextStyle(color: AppColors.muted)), const SizedBox(height: 12), const StatusPill('12 DAY STREAK', icon: Icons.local_fire_department_rounded)]))]))),
      const SizedBox(height: 20), const Row(children: [Expanded(child: _Stat(value: '4h 45m', label: 'Time learned')), SizedBox(width: 10), Expanded(child: _Stat(value: '86%', label: 'Quiz average')), SizedBox(width: 10), Expanded(child: _Stat(value: '3', label: 'Projects'))]),
      const SizedBox(height: 24), const SectionHeader(title: 'Module progress'), const SizedBox(height: 10), ...['Design foundations', 'Research that reveals', 'Ideas into interfaces', 'Test, learn, iterate'].asMap().entries.map((e) { final v = [1.0, .8, .42, 0.0][e.key]; return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [ProgressRing(value: v, size: 52, lineWidth: 6), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.value, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(v == 1 ? 'Completed' : v == 0 ? 'Locked' : '${(v * 5).round()} of 5 lessons', style: const TextStyle(color: AppColors.muted, fontSize: 12))])), Icon(v == 1 ? Icons.check_circle_rounded : Icons.chevron_right_rounded, color: v == 1 ? AppColors.green : AppColors.muted)]))); }),
    ])),
  ]))));
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value; final String label;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.heading, fontSize: 18)), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 10))])));
}
