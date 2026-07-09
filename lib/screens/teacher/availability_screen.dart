import 'package:flutter/material.dart';
import '../shared/app_drawer.dart';
import '../../core/constants/app_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/platform_providers.dart';
import '../../shared/widgets/ui.dart';

/// A weekly availability picker. The teacher taps day + time-slot chips; the
/// selection is stored as "weekdayIndex|slot" strings the scheduler can read.
class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _slots = [
    '08:00-09:00',
    '09:00-10:00',
    '10:00-11:00',
    '16:00-17:00',
    '17:00-18:00',
    '18:00-19:00',
    '19:00-20:00',
  ];

  final Set<String> _selected = {};
  bool _loaded = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;
    final teacherId = user?.id ?? '';
    final saved = ref.watch(availabilityProvider(teacherId));

    // Seed the local selection once from storage.
    saved.whenData((slots) {
      if (!_loaded) {
        _loaded = true;
        _selected.addAll(slots);
      }
    });

    return Scaffold(
      drawer: const AppDrawer(role: UserRole.teacher),
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'My availability',
                subtitle: 'Tell admins when you can take live classes',
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: _days.length,
                  itemBuilder: (_, d) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_days[d],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppBrand.ink,
                                  fontSize: 15)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final slot in _slots)
                                _SlotChip(
                                  label: slot,
                                  selected: _selected.contains('$d|$slot'),
                                  onTap: () => setState(() {
                                    final key = '$d|$slot';
                                    _selected.contains(key)
                                        ? _selected.remove(key)
                                        : _selected.add(key);
                                  }),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: GradientButton(
                  label: 'Save availability (${_selected.length} slots)',
                  loading: _saving,
                  onPressed: () async {
                    setState(() => _saving = true);
                    await ref
                        .read(availabilityControllerProvider)
                        .save(teacherId, _selected.toList()..sort());
                    setState(() => _saving = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Availability saved')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppBrand.purple : AppBrand.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppBrand.purple : AppBrand.line),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : AppBrand.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5)),
        ),
      ),
    );
  }
}
