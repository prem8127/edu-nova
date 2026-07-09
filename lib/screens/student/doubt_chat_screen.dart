import '../shared/app_drawer.dart';
import '../../core/constants/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/doubt_chat_provider.dart';

class StudentDoubtChatScreen extends ConsumerWidget {
  const StudentDoubtChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(threadsForCurrentStudentProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Doubt Chat')),
      drawer: const AppDrawer(role: UserRole.student),
      body: threadsAsync.when(
        data: (threads) {
          if (threads.isEmpty) {
            return const Center(
              child: Text('Ask a doubt from any course to start a chat.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: threads.length,
            itemBuilder: (context, i) {
              final t = threads[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text('Teacher for course ${t.courseId}'),
                  // TODO: resolve teacher name + course title once course/
                  // teacher lookups are wired into a combined view model.
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
