import 'local_storage_service.dart';

/// Minimal email/password store backing the sign-up + login screens.
///
/// This is a local stand-in for a real identity provider — it lives next
/// to [LocalUserRepository] and follows the same pattern (thin wrapper
/// around [LocalStorageService]) so swapping in Firebase/Supabase Auth
/// later only means rewriting this one file.
class CredentialService {
  CredentialService._();
  static final CredentialService instance = CredentialService._();

  final _storage = LocalStorageService.instance;

  Future<Map<String, dynamic>> _readAll() async {
    return await _storage.readObject(StorageKeys.credentials) ?? {};
  }

  String _key(String email) => email.trim().toLowerCase();

  Future<bool> emailExists(String email) async {
    final all = await _readAll();
    return all.containsKey(_key(email));
  }

  /// Stores the password against the email. Demo-only: a production
  /// backend must hash + salt this instead of storing it as-is.
  Future<void> register(String email, String password) async {
    final all = await _readAll();
    all[_key(email)] = password;
    await _storage.writeObject(StorageKeys.credentials, all);
  }

  Future<bool> verify(String email, String password) async {
    final all = await _readAll();
    return all[_key(email)] == password;
  }
}
