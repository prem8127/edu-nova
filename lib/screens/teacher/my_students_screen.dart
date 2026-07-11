import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/grade_themes.dart';
import '../../shared/widgets/grade_scaffold.dart';

/// Teacher — My Students. The actual student roster across every batch the
/// teacher teaches, with search + per-batch filtering and a quick profile
/// sheet (attendance, grade average, last activity) on tap.
///
/// This is what the drawer's "My Students" item is supposed to open — it
/// previously pointed at [AssignedCoursesScreen] ("My Courses"), which
/// showed courses, not students. That mismatch is fixed by wiring the
/// drawer to this screen instead.
class MyStudentsScreen extends ConsumerStatefulWidget {
  const MyStudentsScreen({super.key});

  @override
  ConsumerState<MyStudentsScreen> createState() => _MyStudentsScreenState();
}

class _MyStudentsScreenState extends ConsumerState<MyStudentsScreen> {
  final _search = TextEditingController();
  String _batchFilter = 'All batches';

  static final _roster = <_Student>[
    _Student('Meher Reddy', 'Class 8 — Morning', 'Mathematics', 92, 88, 'Quiz submitted · 2h ago'),
    _Student('Arjun Naidu', 'Class 8 — Morning', 'Mathematics', 78, 74, 'Attendance marked · today'),
    _Student('Sanjana Rao', 'Class 8 — Morning', 'Mathematics', 96, 91, 'Assignment submitted · 1d ago'),
    _Student('Kavya Prasad', 'Class 10 — Evening', 'Science', 88, 82, 'Live class attended · today'),
    _Student('Rohit Varma', 'Class 10 — Evening', 'Science', 65, 58, 'Missed last quiz'),
    _Student('Ishita Menon', 'Class 10 — Evening', 'Science', 90, 95, 'Project approved · 3d ago'),
    _Student('Vikram Chowdary', 'Intermediate 1 — Weekend', 'Physics', 84, 79, 'Doubt raised · 5h ago'),
    _Student('Ananya Pillai', 'Intermediate 1 — Weekend', 'Physics', 97, 93, 'Certificate earned · 1w ago'),
  ];

  List<String> get _batches =>
      ['All batches', ..._roster.map((s) => s.batch).toSet()];

  List<_Student> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return _roster.where((s) {
      final matchesBatch = _batchFilter == 'All batches' || s.batch == _batchFilter;
      final matchesQuery = q.isEmpty || s.name.toLowerCase().contains(q);
      return matchesBatch && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = GradePalette.of(null);
    final students = _filtered;

    return GradeScaffold(
      title: 'My Students',
      subtitle: '${_roster.length} students across ${_batches.length - 1} batches',
      icon: Icons.groups_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search students',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: palette.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: _batches.map((b) {
                final selected = b == _batchFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(b),
                    selected: selected,
                    selectedColor: palette.primary,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : palette.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                    onSelected: (_) => setState(() => _batchFilter = b),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: students.isEmpty
                ? const Center(child: Text('No students match your search.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _StudentTile(
                      student: students[i],
                      palette: palette,
                      onTap: () => _openProfile(context, students[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _openProfile(BuildContext context, _Student s) {
    final palette = GradePalette.of(null);
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: palette.primary,
                  child: Text(s.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: palette.onSurface)),
                      Text('${s.batch} · ${s.subject}', style: TextStyle(color: palette.onSurfaceMuted, fontSize: 12.5)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: GradeStatCard(label: 'Attendance', value: '${s.attendance}%', icon: Icons.event_available_rounded, palette: palette)),
                const SizedBox(width: 12),
                Expanded(child: GradeStatCard(label: 'Grade avg', value: '${s.gradeAvg}%', icon: Icons.grade_rounded, palette: palette)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Recent activity', style: TextStyle(fontWeight: FontWeight.w800, color: palette.onSurface)),
            const SizedBox(height: 6),
            Text(s.recentActivity, style: TextStyle(color: palette.onSurfaceMuted)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Message sent to ${s.name} (demo)')),
                  );
                },
                icon: const Icon(Icons.message_rounded, size: 18),
                label: const Text('Message parent/student'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student, required this.palette, required this.onTap});
  final _Student student;
  final GradePalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final attendanceColor = student.attendance >= 85
        ? const Color(0xFF22C55E)
        : student.attendance >= 70
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: palette.isDark ? Colors.white.withValues(alpha: .06) : Colors.black.withValues(alpha: .05),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: palette.primary.withValues(alpha: .16),
              child: Text(student.name[0], style: TextStyle(color: palette.primary, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: TextStyle(fontWeight: FontWeight.w800, color: palette.onSurface)),
                  const SizedBox(height: 2),
                  Text('${student.batch} · ${student.subject}',
                      style: TextStyle(color: palette.onSurfaceMuted, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${student.attendance}%',
                    style: TextStyle(fontWeight: FontWeight.w900, color: attendanceColor, fontSize: 14)),
                Text('attendance', style: TextStyle(color: palette.onSurfaceMuted, fontSize: 10.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Student {
  const _Student(this.name, this.batch, this.subject, this.attendance, this.gradeAvg, this.recentActivity);
  final String name;
  final String batch;
  final String subject;
  final int attendance;
  final int gradeAvg;
  final String recentActivity;
}
