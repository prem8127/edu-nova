import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/grade_themes.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/grade_scaffold.dart';

/// Student — Coding IDE. A lightweight in-app code editor with a simulated
/// "run" console. Self-contained local state (no backend execution).
class CodingIdeScreen extends ConsumerStatefulWidget {
  const CodingIdeScreen({super.key});

  @override
  ConsumerState<CodingIdeScreen> createState() => _CodingIdeScreenState();
}

class _CodingIdeScreenState extends ConsumerState<CodingIdeScreen> {
  final _controller = TextEditingController(
    text: 'print("Hello, EduNova!")\n'
        'for i in range(1, 4):\n'
        '    print("Line", i)',
  );
  String _language = 'Python';
  final _output = <String>[];
  bool _running = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _run() {
    setState(() => _running = true);
    // Simulated execution: echo a friendly interpretation of the code.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final lines = _controller.text
          .split('\n')
          .where((l) => l.contains('print('))
          .map((l) {
        final start = l.indexOf('print(') + 6;
        var inner = l.substring(start);
        if (inner.endsWith(')')) inner = inner.substring(0, inner.length - 1);
        return inner.replaceAll('"', '').replaceAll("'", '');
      }).toList();
      setState(() {
        _running = false;
        _output
          ..clear()
          ..add('> Running $_language…')
          ..addAll(lines.isEmpty ? ['(no output)'] : lines)
          ..add('> Process finished (exit code 0)');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;
    final palette = GradePalette.of(user?.grade);

    return GradeScaffold(
      title: 'Coding IDE',
      subtitle: 'Write & run code in the browser',
      icon: Icons.terminal_rounded,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: _language,
                  underline: const SizedBox.shrink(),
                  items: const ['Python', 'JavaScript', 'C++', 'Java']
                      .map((l) =>
                          DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (v) => setState(() => _language = v!),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _running ? null : _run,
                  icon: Icon(
                      _running ? Icons.hourglass_top_rounded : Icons.play_arrow_rounded,
                      size: 18),
                  label: Text(_running ? 'Running…' : 'Run'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF11151C),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFFE6EDF3),
                      fontSize: 13.5,
                      height: 1.5),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: '// write your code here',
                    hintStyle: TextStyle(color: Color(0xFF6E7681)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: palette.onSurfaceMuted),
                Text('Output',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: palette.onSurface)),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0E13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _output.isEmpty
                        ? 'Run your code to see output here.'
                        : _output.join('\n'),
                    style: TextStyle(
                        fontFamily: 'monospace',
                        color: _output.isEmpty
                            ? const Color(0xFF6E7681)
                            : const Color(0xFF7EE787),
                        fontSize: 13,
                        height: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
