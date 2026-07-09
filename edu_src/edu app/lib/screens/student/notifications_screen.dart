import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/grade_themes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/platform_providers.dart';
import '../../shared/widgets/grade_scaffold.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = GradePalette.of(ref.watch(authControllerProvider).value?.grade);
    final notifications = ref.watch(notificationsProvider);

    return GradeScaffold(
      title: 'Notifications',
      subtitle: 'Class reminders, results & replies',
      icon: Icons.notifications_rounded,
      actions: [
        TextButton(
          onPressed: () => ref.read(notificationControllerProvider).markAllRead(),
          child: const Text('Mark all',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ),
      ],
      child: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return _empty(palette);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final n = items[i];
              return Material(
                color: palette.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => ref.read(notificationControllerProvider).markRead(n.id),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: n.read
                            ? Colors.transparent
                            : palette.primary.withValues(alpha: .4),
                        width: 1.4,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: palette.primary.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(n.type.icon, color: palette.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: palette.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                n.body,
                                style: TextStyle(
                                  color: palette.onSurfaceMuted,
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _ago(n.createdAt),
                                style: TextStyle(
                                  color: palette.onSurfaceMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!n.read)
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: palette.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _empty(GradePalette palette) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_rounded,
                size: 64, color: palette.onSurfaceMuted),
            const SizedBox(height: 12),
            Text('No notifications yet',
                style: TextStyle(
                    color: palette.onSurface, fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      );

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
