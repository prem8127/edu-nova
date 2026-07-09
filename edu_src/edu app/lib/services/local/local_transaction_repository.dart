import '../../models/transaction_model.dart';
import '../interfaces/transaction_repository.dart';
import 'local_storage_service.dart';

class LocalTransactionRepository implements TransactionRepository {
  final _storage = LocalStorageService.instance;

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    final list = await _storage.readList(StorageKeys.transactions);
    return list.map(TransactionModel.fromJson).toList();
  }

  @override
  Future<List<TransactionModel>> getTransactionsForTeacher(String teacherId) async {
    final all = await getAllTransactions();
    return all.where((t) => t.teacherId == teacherId).toList();
  }

  @override
  Future<List<TransactionModel>> getTransactionsForStudent(String studentId) async {
    final all = await getAllTransactions();
    return all.where((t) => t.studentId == studentId).toList();
  }

  @override
  Future<void> recordTransaction(TransactionModel transaction) async {
    final all = await getAllTransactions();
    all.add(transaction);
    await _storage.writeList(
      StorageKeys.transactions,
      all.map((t) => t.toJson()).toList(),
    );
  }
}
