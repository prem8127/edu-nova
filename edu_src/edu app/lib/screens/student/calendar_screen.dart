import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../models/class_schedule_model.dart';
import '../../providers/calendar_provider.dart';
import '../shared/app_bottom_nav.dart';

/// Google-Calendar-style month grid + agenda list for the day the student
/// has selected. Replaces the old flat "every upcoming class" list — the
/// grid gives an at-a-glance view of which days have live sessions (via
/// coloured dots), and tapping a day filters the agenda below it, the same
/// interaction pattern as the Google Calendar app.
class StudentCalendarScreen extends ConsumerStatefulWidget {
  const StudentCalendarScreen({super.key});

  @override
  ConsumerState<StudentCalendarScreen> createState() => _StudentCalendarScreenState();
}

class _StudentCalendarScreenState extends ConsumerState<StudentCalendarScreen> {
  late DateTime _visibleMonth; // first day of the month currently shown
  late DateTime _selectedDay;

  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _visibleMonth = DateTime(now.year, now.month, 1);
      _selectedDay = DateTime(now.year, now.month, now.day);
    });
  }

  /// Deterministic colour per course so the same subject always renders
  /// with the same dot/left-bar colour, mirroring how Google Calendar keeps
  /// a consistent colour per calendar.
  Color _colorFor(String key) {
    final colors = AppBrand.subjectColors;
    final hash = key.codeUnits.fold<int>(0, (acc, c) => acc + c);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(studentCalendarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          TextButton(
            onPressed: _goToToday,
            child: const Text('Today'),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: classesAsync.when(
        data: (classes) {
          final byDay = <DateTime, List<ScheduledClass>>{};
          for (final c in classes) {
            final key = DateTime(c.dateTime.year, c.dateTime.month, c.dateTime.day);
            byDay.putIfAbsent(key, () => []).add(c);
          }

          final selectedEvents = List<ScheduledClass>.from(
            byDay[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] ?? [],
          )..sort((a, b) => a.dateTime.compareTo(b.dateTime));

          return Column(
            children: [
              _MonthHeader(
                visibleMonth: _visibleMonth,
                onPrev: () => _changeMonth(-1),
                onNext: () => _changeMonth(1),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _weekdayLabels
                    .map((d) => SizedBox(
                          width: 36,
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppBrand.inkSoft,
                              fontSize: 12,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 4),
              _MonthGrid(
                visibleMonth: _visibleMonth,
                selectedDay: _selectedDay,
                eventsByDay: byDay,
                colorFor: _colorFor,
                onSelectDay: (day) => setState(() => _selectedDay = day),
              ),
              const Divider(height: 1, color: AppBrand.line),
              Expanded(
                child: selectedEvents.isEmpty
                    ? Center(
                        child: Text(
                          'No classes on ${DateFormat('EEEE, MMM d').format(_selectedDay)}',
                          style: const TextStyle(color: AppBrand.inkSoft),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, i) {
                          final c = selectedEvents[i];
                          final color = _colorFor(c.courseId);
                          return _AgendaTile(event: c, color: color);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime visibleMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.visibleMonth,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              DateFormat('MMMM y').format(visibleMonth),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selectedDay;
  final Map<DateTime, List<ScheduledClass>> eventsByDay;
  final Color Function(String) colorFor;
  final ValueChanged<DateTime> onSelectDay;

  const _MonthGrid({
    required this.visibleMonth,
    required this.selectedDay,
    required this.eventsByDay,
    required this.colorFor,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    // Sunday-first grid, matching the Google Calendar default week start.
    final leadingBlanks = firstOfMonth.weekday % 7;
    final totalCells = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final dayNum = index - leadingBlanks + 1;
        if (dayNum < 1 || dayNum > daysInMonth) {
          return const SizedBox.shrink();
        }
        final day = DateTime(visibleMonth.year, visibleMonth.month, dayNum);
        final events = eventsByDay[day] ?? const <ScheduledClass>[];
        final isToday = day == todayKey;
        final isSelected = day.year == selectedDay.year &&
            day.month == selectedDay.month &&
            day.day == selectedDay.day;

        return GestureDetector(
          onTap: () => onSelectDay(day),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppBrand.purple
                        : (isToday ? AppBrand.purpleSoft : Colors.transparent),
                  ),
                  child: Text(
                    '$dayNum',
                    style: TextStyle(
                      fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isToday ? AppBrand.purple : AppBrand.ink),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                SizedBox(
                  height: 6,
                  child: events.isEmpty
                      ? null
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: events
                              .take(3)
                              .map((e) => Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colorFor(e.courseId),
                                    ),
                                  ))
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AgendaTile extends StatelessWidget {
  final ScheduledClass event;
  final Color color;

  const _AgendaTile({required this.event, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppBrand.card,
        borderRadius: BorderRadius.circular(AppBrand.radiusCard),
        border: Border.all(color: AppBrand.line),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppBrand.radiusCard)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${DateFormat('h:mm a').format(event.dateTime)} – '
                            '${DateFormat('h:mm a').format(event.endTime)}',
                            style: const TextStyle(color: AppBrand.inkSoft, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    if (event.zoomLink != null && !event.hasEnded)
                      TextButton(
                        onPressed: () => launchUrl(Uri.parse(event.zoomLink!)),
                        child: const Text('Join'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
