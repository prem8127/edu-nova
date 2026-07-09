import 'package:flutter/material.dart';
import '../shared/app_drawer.dart';
import '../../core/constants/app_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_provider.dart';
import '../../providers/calendar_provider.dart';

class StartClassScreen extends ConsumerWidget {
  const StartClassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return const SizedBox.shrink();
    final classesAsync = ref.watch(teacherScheduleProvider(user.id));

    return Scaffold(
      drawer: const AppDrawer(role: UserRole.teacher),
      appBar: AppBar(title: const Text('Start a Class')),
      body: classesAsync.when(
        data: (classes) {
          if (classes.isEmpty) {
            return const Center(
              child: Text('No classes scheduled yet.\n(Scheduling UI: TODO)',
                  textAlign: TextAlign.center),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, i) {
              final c = classes[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(DateFormat('EEE, MMM d · h:mm a').format(c.dateTime)),
                      const SizedBox(height: 8),
                      _ZoomLinkField(classId: c.id, initialLink: c.zoomLink),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ZoomLinkField extends ConsumerStatefulWidget {
  final String classId;
  final String? initialLink;
  const _ZoomLinkField({required this.classId, required this.initialLink});

  @override
  ConsumerState<_ZoomLinkField> createState() => _ZoomLinkFieldState();
}

class _ZoomLinkFieldState extends ConsumerState<_ZoomLinkField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialLink ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actions = ref.read(scheduleActionsProvider);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Paste Zoom link',
              isDense: true,
            ),
            onSubmitted: (link) => actions.setZoomLink(widget.classId, link),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _controller.text.trim().isEmpty
              ? null
              : () async {
                  await actions.setZoomLink(widget.classId, _controller.text.trim());
                  await launchUrl(Uri.parse(_controller.text.trim()));
                },
          child: const Text('Start class'),
        ),
      ],
    );
  }
}
