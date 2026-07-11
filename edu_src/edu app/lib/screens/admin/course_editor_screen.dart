import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';

/// Create/edit form for a single course. Pass an existing [course] to
/// edit it in place, or leave it null to create a new one.
class CourseEditorScreen extends ConsumerStatefulWidget {
  const CourseEditorScreen({super.key, this.course});

  final CourseModel? course;

  @override
  ConsumerState<CourseEditorScreen> createState() => _CourseEditorScreenState();
}

class _CourseEditorScreenState extends ConsumerState<CourseEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  Subject? _subject;
  Grade? _grade;
  String? _teacherId;
  bool _saving = false;

  bool get _isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();
    final course = widget.course;
    _titleController = TextEditingController(text: course?.title ?? '');
    _descriptionController = TextEditingController(text: course?.description ?? '');
    _priceController = TextEditingController(
      text: course != null ? course.price.toStringAsFixed(0) : '0',
    );
    _subject = course?.subject;
    _grade = course?.grade;
    _teacherId = course?.teacherId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teachersAsync = ref.watch(allTeachersProvider);
    final actions = ref.read(courseAuthoringActionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Course' : 'New Course')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Subject>(
              decoration: const InputDecoration(labelText: 'Subject'),
              value: _subject,
              items: [
                for (final s in Subject.values)
                  DropdownMenuItem(value: s, child: Text(s.label)),
              ],
              onChanged: (v) => setState(() {
                _subject = v;
                // Selected teacher might not teach the new subject.
                if (v != null && _teacherIdIsInvalidForSubject(teachersAsync.value, v)) {
                  _teacherId = null;
                }
              }),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Grade>(
              decoration: const InputDecoration(labelText: 'Grade'),
              value: _grade,
              items: [
                for (final g in Grade.values)
                  DropdownMenuItem(value: g, child: Text(g.label)),
              ],
              onChanged: (v) => setState(() => _grade = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            teachersAsync.when(
              data: (teachers) {
                final eligible = _subject == null
                    ? teachers
                    : teachers.where((t) => t.assignedSubjects.contains(_subject)).toList();
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Teacher',
                    helperText: eligible.isEmpty
                        ? 'No teacher is assigned to this subject yet — add one from Manage Teachers.'
                        : null,
                  ),
                  value: _teacherId,
                  items: [
                    for (final t in eligible) DropdownMenuItem(value: t.id, child: Text(t.name)),
                  ],
                  onChanged: (v) => setState(() => _teacherId = v),
                  validator: (v) => v == null ? 'Required' : null,
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading teachers: $e'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price (₹)',
                helperText: '0 = free/intro course, otherwise must be purchased',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                final parsed = double.tryParse(v ?? '');
                if (parsed == null || parsed < 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : () => _save(actions),
              child: _saving
                  ? const SizedBox(
                      height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isEditing ? 'Save changes' : 'Create course'),
            ),
          ],
        ),
      ),
    );
  }

  bool _teacherIdIsInvalidForSubject(List<AppUser>? teachers, Subject subject) {
    if (teachers == null || _teacherId == null) return false;
    final current = teachers.where((t) => t.id == _teacherId);
    if (current.isEmpty) return true;
    return !current.first.assignedSubjects.contains(subject);
  }

  Future<void> _save(dynamic actions) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final price = double.parse(_priceController.text);
    try {
      if (_isEditing) {
        final updated = CourseModel(
          id: widget.course!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          subject: _subject!,
          grade: _grade!,
          teacherId: _teacherId!,
          price: price,
          gameId: widget.course!.gameId,
          quizIds: widget.course!.quizIds,
        );
        await actions.updateCourse(updated);
      } else {
        await actions.createCourse(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          subject: _subject!,
          grade: _grade!,
          teacherId: _teacherId!,
          price: price,
        );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
