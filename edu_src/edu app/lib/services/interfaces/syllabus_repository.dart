import '../../models/syllabus_model.dart';

abstract class SyllabusRepository {
  /// Full Class 6–10 entrepreneur roadmap, in class order.
  Future<List<SyllabusClassPlan>> getSyllabus();

  /// Essential Books block shown under every class: level -> book titles.
  Future<Map<String, List<String>>> getEssentialBooks();
}
