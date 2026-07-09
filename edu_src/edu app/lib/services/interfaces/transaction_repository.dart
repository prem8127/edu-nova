import '../../models/transaction_model.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getAllTransactions();
  Future<List<TransactionModel>> getTransactionsForTeacher(String teacherId);
  Future<List<TransactionModel>> getTransactionsForStudent(String studentId);
  Future<void> recordTransaction(TransactionModel transaction);
}
