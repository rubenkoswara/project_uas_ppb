import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const _secureStorage = FlutterSecureStorage();
  static const _sessionKey = 'supabase_session';

  // Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  // Get current authenticated user
  static User? get currentUser => client.auth.currentUser;

  /// Save session securely (called after login)
  static Future<void> saveSessionSecurely() async {
    try {
      final session = client.auth.currentSession;
      if (session != null) {
        await _secureStorage.write(
          key: _sessionKey,
          value: session.refreshToken ?? '',
        );
      }
    } catch (e) {
      // Session save error handled silently
    }
  }

  /// Clear session (called on logout)
  static Future<void> clearSessionSecurely() async {
    try {
      await _secureStorage.delete(key: _sessionKey);
    } catch (e) {
      // Session clear error handled silently
    }
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return client.auth.currentUser != null;
  }

  /// Validate query parameters to prevent SQL injection
  static String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    String result = input;
    result = result.replaceAll("'", '');
    result = result.replaceAll('"', '');
    result = result.replaceAll(';', '');
    result = result.replaceAll('\\', '');
    return result.trim();
  }



  /// Log security events (for monitoring suspicious activity)
  static Future<void> logSecurityEvent({
    required String eventType,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Insert security log ke database
      await client.from('security_logs').insert({
        'user_id': currentUser?.id,
        'event_type': eventType,
        'description': description,
        'metadata': metadata,
        'ip_address': '',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Log error handled silently
    }
  }
}

