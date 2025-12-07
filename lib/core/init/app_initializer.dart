import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:projectuasppb/config/supabase_config.dart';
import 'package:projectuasppb/services/supabase_service.dart';
import 'package:projectuasppb/services/dns_resolver_service.dart';
import 'package:projectuasppb/services/network_service.dart';

class AppInitializer {
  AppInitializer._();

  static Future<void> initialize() async {
    try {
      const String logTag = '[AppInitializer]';
      debugLog('$logTag Starting app initialization...');

      debugLog('$logTag Loading environment variables...');
      try {
        await dotenv.load();
        debugLog('$logTag Environment variables loaded successfully');
      } catch (e) {
        debugLog('$logTag Warning: Could not load .env file: $e');
        debugLog('$logTag Using fallback configuration');
      }

      debugLog('$logTag Initializing Supabase...');
      try {
        debugLog('$logTag Performing network connectivity test...');
        try {
          final networkService = NetworkService();
          await networkService.testSupabaseConnectivity()
              .timeout(const Duration(seconds: 20));
          debugLog('$logTag ✅ Network connectivity test successful');
        } catch (e) {
          debugLog('$logTag ⚠️ Network test warning: $e (will continue)');
        }

        await _initializeSupabase();
        debugLog('$logTag ✅ Supabase initialized successfully');

        debugLog('$logTag Verifying Supabase connection...');
        await _verifyConnection();
      } catch (e) {
        debugLog('[AppInitializer] ⚠️ Supabase init warning: $e');
        debugLog('[AppInitializer] App will work in offline mode');
      }

      debugLog('$logTag ✅ App initialization complete!');
    } catch (e, stackTrace) {
      debugLog('[AppInitializer] ❌ Unexpected error: $e');
      debugLog('[AppInitializer] Stack trace: $stackTrace');
    }
  }

  static Future<void> _initializeSupabase() async {
    try {
      final supabaseUrl = SupabaseConfig.supabaseUrl;
      final anonKey = SupabaseConfig.supabaseAnonKey;

      if (supabaseUrl.isEmpty || anonKey.isEmpty) {
        throw Exception('Supabase credentials are missing or invalid');
      }

      debugLog('[AppInitializer] Initializing with URL: ${supabaseUrl.split('.').first}...');

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: anonKey,
        debug: true,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException(
          'Supabase initialization timeout after 10 seconds',
        ),
      );

      debugLog('[AppInitializer] ✅ Supabase client initialized successfully');
    } catch (e) {
      String errorMsg = e.toString();
      
      if (errorMsg.contains('Failed host lookup')) {
        debugLog('[AppInitializer] ⚠️ DNS Resolution failed - cannot reach supabase.co domain');
        debugLog('[AppInitializer] Possible causes:');
        debugLog('[AppInitializer]   1. ISP/Operator blocking DNS to this domain');
        debugLog('[AppInitializer]   2. DNS server returning wrong IP');
        debugLog('[AppInitializer]   3. Network connectivity issue');
      } else if (errorMsg.contains('Connection refused')) {
        debugLog('[AppInitializer] ⚠️ Connection refused - server may be unreachable');
      } else if (errorMsg.contains('TimeoutException')) {
        debugLog('[AppInitializer] ⚠️ Timeout - network too slow or server unresponsive');
      }
      
      debugLog('[AppInitializer] Failed to initialize Supabase: $e');
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
