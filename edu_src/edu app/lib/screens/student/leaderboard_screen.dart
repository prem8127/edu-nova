import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/grade_themes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/platform_providers.dart';
import '../../shared/widgets/grade_scaffold.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final palette = GradePalette.of(user?.grade);
    final grade = user?.grade;

    return GradeScaffold(
      title: 'Leaderboard',
      subtitle: grade == null ? null : '${grade.label} rankings',
      icon: Icons.leaderboard_rounded,
      child: grade == null
          ? Center(
              child: Text('Sign in as a student to see rankings.',
                  style: TextStyle(color: palette.onSurfaceMuted)))
          : ref.watch(leaderboardProvider(grade)).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                        child: Text('No rankings yet.',
                            style: TextStyle(color: palette.onSurfaceMuted)));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final e = entries[i];
                      final isMe = e.studentId == user?.id;
                      final medal = i < 3;
                      final medalColor = [
                        const Color(0xFFFFD54F),
                        const Color(0xFFB0BEC5),
                        const Color(0xFFBCAAA4),
                      ];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isMe ? null : palette.surface,
                          gradient: isMe ? palette.heroGradient : null,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isMe
                                ? Colors.transparent
                                : (palette.isDark
                                    ? Colors.white.withValues(alpha: .06)
                                    : Colors.black.withValues(alpha: .05)),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 34,
                              child: medal
                                  ? Icon(Icons.emoji_events_rounded,
                                      color: medalColor[i], size: 26)
                                  : Text('#${e.rank}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: isMe
                                              ? Colors.white
                                              : palette.onSurfaceMuted)),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isMe
                                  ? Colors.white.withValues(alpha: .25)
                                  : palette.primary.withValues(alpha: .15),
                              child: Text(
                                e.studentName.isNotEmpty
                                    ? e.studentName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: isMe ? Colors.white : palette.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isMe ? '${e.studentName} (You)' : e.studentName,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: isMe ? Colors.white : palette.onSurface),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${e.points} pts',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color:
                                            isMe ? Colors.white : palette.primary)),
                                Text('${e.badges} badges',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: isMe
                                            ? Colors.white.withValues(alpha: .8)
                                            : palette.onSurfaceMuted)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
