import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/class_schedule_model.dart';
import '../../providers/calendar_provider.dart';
import '../shared/app_nav_drawer.dart';

class StudentCalendarScreen extends ConsumerStatefulWidget {
  const StudentCalendarScreen({super.key});

  @override
  ConsumerState<StudentCalendarScreen> createState() => _StudentCalendarScreenState();
}

class _StudentCalendarScreenState extends ConsumerState<StudentCalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(studentCalendarProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      drawer: const AppNavDrawer(),
      body: classesAsync.when(
        data: (classes) {
          final byDay = <DateTime, List<ScheduledClass>>{};
          for (final c in classes) {
            final key = DateTime(c.dateTime.year, c.dateTime.month, c.dateTime.day);
            byDay.putIfAbsent(key, () => []).add(c);
          }
          final selectedClasses = byDay[_selectedDay] ?? [];

          return Column(
            children: [
              _MonthHeader(
                month: _visibleMonth,
                onPrev: () => _changeMonth(-1),
                onNext: () => _changeMonth(1),
              ),
              _MonthGrid(
                month: _visibleMonth,
                selectedDay: _selectedDay,
                eventDays: byDay.keys.toSet(),
                onSelect: (d) => setState(() => _selectedDay = d),
              ),
              const Divider(height: 1),
              Expanded(
                child: selectedClasses.isEmpty
                    ? Center(
                        child: Text(
                          'No classes on ${DateFormat('MMM d').format(_selectedDay)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: selectedClasses.length,
                        itemBuilder: (context, i) {
                          final c = selectedClasses[i];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.circle, size: 12, color: Colors.blue),
                              title: Text(c.title),
                              subtitle: Text(
                                  '${DateFormat('h:mm a').format(c.dateTime)} · ${c.durationMinutes} min'),
                              trailing: c.zoomLink == null || c.hasEnded
                                  ? null
                                  : TextButton(
                                      onPressed: () => launchUrl(Uri.parse(c.zoomLink!)),
                                      child: const Text('Join'),
                                    ),
                            ),
                          );
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
  const _MonthHeader({required this.month, required this.onPrev, required this.onNext});
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrev),
          Text(
            DateFormat('MMMM yyyy').format(month),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectedDay,
    required this.eventDays,
    required this.onSelect,
  });
  final DateTime month;
  final DateTime selectedDay;
  final Set<DateTime> eventDays;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    // Sunday-first grid, matching Google Calendar's default.
    final leadingBlanks = firstOfMonth.weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final totalCells = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    return Column(
      children: [
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: TextStyle(
                              color: Colors.grey[600], fontWeight: FontWeight.w600)),
                    ),
                  ))
              .toList(),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final dayNum = index - leadingBlanks + 1;
            if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox.shrink();
            final date = DateTime(month.year, month.month, dayNum);
            final isSelected = date == selectedDay;
            final isToday = date == todayKey;
            final hasEvent = eventDays.contains(date);

            return GestureDetector(
              onTap: () => onSelect(date),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (isToday ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : null),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                      if (hasEvent)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.white : Colors.blue,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
