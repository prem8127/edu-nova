import 'package:flutter/material.dart';
import '../shared/app_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/platform_providers.dart';
import '../../providers/repository_providers.dart';
import '../../shared/widgets/ui.dart';

/// Super Admin bulk import. Paste CSV rows of `name, grade` (one per line)
/// to create many student accounts at once. Grade accepts "6".."10",
/// "inter1"/"inter2" or the full label.
class ImportUsersScreen extends ConsumerStatefulWidget {
  const ImportUsersScreen({super.key});

  @override
  ConsumerState<ImportUsersScreen> createState() => _ImportUsersScreenState();
}

class _ImportUsersScreenState extends ConsumerState<ImportUsersScreen> {
  final _controller = TextEditingController();
  String? _result;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Grade? _parseGrade(String raw) {
    final v = raw.trim().toLowerCase().replaceAll(' ', '');
    switch (v) {
      case '6':
      case 'class6':
        return Grade.class6;
      case '7':
      case 'class7':
        return Grade.class7;
      case '8':
      case 'class8':
        return Grade.class8;
      case '9':
      case 'class9':
        return Grade.class9;
      case '10':
      case 'class10':
        return Grade.class10;
      case 'inter1':
      case 'intermediate1':
      case 'intermediate1styear':
        return Grade.intermediate1;
      case 'inter2':
      case 'intermediate2':
      case 'intermediate2ndyear':
        return Grade.intermediate2;
    }
    return null;
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    final repo = ref.read(userRepositoryProvider);
    final lines = _controller.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    int created = 0;
    int skipped = 0;
    for (final line in lines) {
      final parts = line.split(',');
      if (parts.length < 2) {
        skipped++;
        continue;
      }
      final name = parts[0].trim();
      final grade = _parseGrade(parts[1]);
      if (name.isEmpty || grade == null) {
        skipped++;
        continue;
      }
      await repo.upsertUser(AppUser(
        id: 'imp_${DateTime.now().microsecondsSinceEpoch}_$created',
        name: name,
        role: UserRole.student,
        grade: grade,
      ));
      created++;
    }

    await ref
        .read(auditControllerProvider)
        .log('Imported students', '$created accounts');
    ref.invalidate(allStudentsProvider);

    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = 'Imported $created student(s). Skipped $skipped invalid row(s).';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(role: UserRole.admin),
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            children: [
              const PageHeader(
                title: 'Import students',
                subtitle: 'Bulk-create accounts from CSV',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paste one student per line as:  name, grade',
                      style: TextStyle(
                          color: AppBrand.ink, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Example:  Asha Rao, 8    ·    Ravi K, inter1',
                      style: TextStyle(color: AppBrand.inkSoft, fontSize: 12.5),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _controller,
                      minLines: 6,
                      maxLines: 14,
                      style: const TextStyle(color: AppBrand.ink),
                      decoration: const InputDecoration(
                        hintText: 'Asha Rao, 8\nRavi K, inter1\n...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      label: 'Import students',
                      loading: _busy,
                      onPressed: _busy ? null : _import,
                    ),
                    if (_result != null) ...[
                      const SizedBox(height: 16),
                      GlassCard(
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppBrand.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(_result!,
                                  style:
                                      const TextStyle(color: AppBrand.ink)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
