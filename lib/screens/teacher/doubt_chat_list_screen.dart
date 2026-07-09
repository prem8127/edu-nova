import 'package:flutter/material.dart';
import '../shared/app_drawer.dart';
import '../../core/constants/app_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/doubt_chat_provider.dart';

class TeacherDoubtChatListScreen extends ConsumerWidget {
  const TeacherDoubtChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(threadsForCurrentTeacherProvider);
    return Scaffold(
      drawer: const AppDrawer(role: UserRole.teacher),
      appBar: AppBar(title: const Text('Doubt Chats')),
      body: threadsAsync.when(
        data: (threads) {
          if (threads.isEmpty) {
            return const Center(child: Text('No doubts raised yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: threads.length,
            itemBuilder: (context, i) {
              final t = threads[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text('Student for course ${t.courseId}'),
                  // TODO: resolve student name + course title via a
                  // combined view model once that lookup layer exists.
                  onTap: () => context.push('/doubt-thread/${t.id}'),
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
