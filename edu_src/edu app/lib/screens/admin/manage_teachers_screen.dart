import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../providers/admin_provider.dart';

class ManageTeachersScreen extends ConsumerWidget {
  const ManageTeachersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(allTeachersProvider);
    final actions = ref.read(adminActionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Teachers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTeacherDialog(context, actions),
        child: const Icon(Icons.add),
      ),
      body: teachersAsync.when(
        data: (teachers) => teachers.isEmpty
            ? const Center(child: Text('No teachers yet. Tap + to add one.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: teachers.length,
                itemBuilder: (context, i) {
                  final t = teachers[i];
                  return Card(
                    child: ListTile(
                      title: Text(t.name),
                      subtitle: Text(
                          t.assignedSubjects.map((s) => s.label).join(', ')),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => actions.removeTeacher(t.id),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showAddTeacherDialog(BuildContext context, dynamic actions) {
    final nameController = TextEditingController();
    final selected = <Subject>{};
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Teacher'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: Subject.values.map((s) {
                  final isSelected = selected.contains(s);
                  return FilterChip(
                    label: Text(s.label),
                    selected: isSelected,
                    onSelected: (v) => setState(
                        () => v ? selected.add(s) : selected.remove(s)),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                await actions.addTeacher(
                    nameController.text.trim(), selected.toList());
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
