import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const _secureStorage = FlutterSecureStorage();
  static const _sessionKey = 'supabase_session';

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static Future<void> saveSessionSecurely() async {
    try {
      final session = client.auth.currentSession;
      if (session != null) {
        await _secureStorage.write(
          key: _sessionKey,
          value: session.refreshToken ?? '',
        );
      }
    } catch (e) {}
  }

  static Future<void> clearSessionSecurely() async {
    try {
      await _secureStorage.delete(key: _sessionKey);
    } catch (e) {}
  }

  static bool isAuthenticated() {
    return client.auth.currentUser != null;
  }

  static String sanitizeInput(String input) {
    String result = input;
    result = result.replaceAll("'", '');
    result = result.replaceAll('"', '');
    result = result.replaceAll(';', '');
    result = result.replaceAll('\\', '');
    return result.trim();
  }

  static Future<void> logSecurityEvent({
    required String eventType,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await client.from('security_logs').insert({
        'user_id': currentUser?.id,
        'event_type': eventType,
        'description': description,
        'metadata': metadata,
        'ip_address': '',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {}
  }
}
