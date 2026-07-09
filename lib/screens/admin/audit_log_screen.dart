import 'package:flutter/material.dart';
import '../shared/app_drawer.dart';
import '../../core/constants/app_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/platform_providers.dart';
import '../../shared/widgets/ui.dart';

/// Super Admin audit trail: an append-only log of significant actions
/// (teacher/course changes, reviews, imports) with actor and timestamp.
class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(auditLogProvider);

    return Scaffold(
      drawer: const AppDrawer(role: UserRole.admin),
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Audit log',
                subtitle: 'Every significant action, newest first',
              ),
              Expanded(
                child: log.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (entries) {
                    if (entries.isEmpty) {
                      return const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No activity yet',
                        body: 'Admin and teacher actions will show up here.',
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final e = entries[i];
                        return GlassCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.bolt_rounded,
                                  color: AppBrand.amber, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(e.action,
                                        style: const TextStyle(
                                            color: AppBrand.ink,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14)),
                                    const SizedBox(height: 3),
                                    Text('${e.target} · by ${e.actorName}',
                                        style: const TextStyle(
                                            color: AppBrand.inkSoft,
                                            fontSize: 12.5)),
                                  ],
                                ),
                              ),
                              Text(_ago(e.createdAt),
                                  style: const TextStyle(
                                      color: AppBrand.inkSoft, fontSize: 11)),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}
