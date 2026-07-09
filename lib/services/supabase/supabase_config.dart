import 'package:supabase_flutter/supabase_flutter.dart';

/// Project credentials. The anon/publishable key is safe to ship in the
/// client — it can only do what your Row Level Security policies allow
/// (see supabase/schema.sql). Never put the service_role key here.
class SupabaseConfig {
  static const String url = 'https://ymvyyendeblxkixlgnfz.supabase.co';
  static const String anonKey = 'sb_publishable_tL5NwCPUDZluXwv7C8YwUg__YbPg74l';

  static Future<void> init() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}

/// Shorthand used everywhere instead of `Supabase.instance.client`.
SupabaseClient get supabase => Supabase.instance.client;
