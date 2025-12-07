import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:projectuasppb/config/supabase_config.dart';
import 'package:projectuasppb/services/supabase_service.dart';

class AppInitializer {
  AppInitializer._();

  static Future<void> initialize() async {
    const String logTag = '[AppInitializer]';
    debugLog('$logTag Initializing Supabase...');
    try {
      await _initializeSupabase();
      debugLog('$logTag ✅ Supabase initialized successfully');

      debugLog('$logTag Verifying Supabase connection...');
      await _verifyConnection();
    } catch (e) {
      debugLog('$logTag ❌ Failed to initialize Supabase: $e');
    }
  }

  static Future<void> _initializeSupabase() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: true,
      );
    } catch (e) {
      debugLog('[AppInitializer] Error initializing Supabase: $e');
      rethrow;
    }
  }

  static Future<void> _verifyConnection() async {
    try {
      final client = Supabase.instance.client;
      
      final session = client.auth.currentSession;
      
      if (session != null) {
        debugLog('[AppInitializer] ✅ Active session found for user: ${session.user.email}');
        
        try {
          await SupabaseService.logSecurityEvent(
            eventType: 'session_resumed',
            description: 'Session resumed on app start',
          );
        } catch (e) {
          debugLog('[AppInitializer] Could not log security event: $e');
        }
      } else {
        debugLog('[AppInitializer] No active session - user needs to login');
      }

      debugLog('[AppInitializer] ✅ Supabase connection check complete');
      
    } catch (e) {
      debugLog('[AppInitializer] Connection verification warning: $e');
      debugLog('[AppInitializer] App will work with offline fallback');
    }
  }

  static void debugLog(String message) {
    assert(() {
      print(message);
      return true;
    }());
  }
}
