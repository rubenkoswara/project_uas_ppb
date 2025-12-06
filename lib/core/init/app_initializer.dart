import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:projectuasppb/config/supabase_config.dart';
import 'package:projectuasppb/services/supabase_service.dart';
import 'package:projectuasppb/services/dns_resolver_service.dart';

/// Central app initialization handler
/// 
/// This class handles all app-level initialization tasks:
/// - Loading environment variables
/// - Initializing Supabase client
/// - Setting up services
/// - Logging configuration
class AppInitializer {
  /// Private constructor - this is a utility class
  AppInitializer._();

  /// Initialize the application
  /// 
  /// This method must be called before [runApp] in main()
  /// It handles:
  /// 1. Binding Flutter engine
  /// 2. Loading .env file for configuration
  /// 3. Initializing Supabase client (non-blocking)
  /// 4. Setting up error handlers
  /// 
  /// Note: This does NOT fail if network is unavailable
  static Future<void> initialize() async {
    try {
      const String logTag = '[AppInitializer]';
      debugLog('$logTag Starting app initialization...');

      // Step 1: Load environment variables from .env file
      debugLog('$logTag Loading environment variables...');
      try {
        await dotenv.load();
        debugLog('$logTag Environment variables loaded successfully');
      } catch (e) {
        debugLog('$logTag Warning: Could not load .env file: $e');
        debugLog('$logTag Using fallback configuration');
      }

      // Step 2: Initialize Supabase (non-blocking)
      debugLog('$logTag Initializing Supabase...');
      try {
        // Pre-flight DNS check before attempting Supabase init
        debugLog('$logTag Performing DNS pre-check...');
        try {
          await DNSResolverService.verifySuabaseConnectivity()
              .timeout(const Duration(seconds: 15));
          debugLog('$logTag ✅ DNS pre-check successful');
        } catch (e) {
          debugLog('$logTag ⚠️ DNS pre-check warning: $e (will continue)');
        }

        await _initializeSupabase();
        debugLog('$logTag ✅ Supabase initialized successfully');

        // Step 3: Verify connection (only if init succeeded)
        debugLog('$logTag Verifying Supabase connection...');
        await _verifyConnection();
      } catch (e) {
        debugLog('[AppInitializer] ⚠️ Supabase init warning: $e');
        // Don't crash app - allow offline mode
        debugLog('[AppInitializer] App will work in offline mode');
      }

      debugLog('$logTag ✅ App initialization complete!');
    } catch (e, stackTrace) {
      debugLog('[AppInitializer] ❌ Unexpected error: $e');
      debugLog('[AppInitializer] Stack trace: $stackTrace');
      // Don't rethrow - allow app to continue
    }
  }

  /// Initialize Supabase with credentials
  /// Throws exception on failure (caller handles gracefully)
  static Future<void> _initializeSupabase() async {
    try {
      final supabaseUrl = SupabaseConfig.supabaseUrl;
      final anonKey = SupabaseConfig.supabaseAnonKey;

      if (supabaseUrl.isEmpty || anonKey.isEmpty) {
        throw Exception('Supabase credentials are missing or invalid');
      }

      debugLog('[AppInitializer] Initializing with URL: ${supabaseUrl.split('.').first}...');

      // Initialize with timeout to prevent hanging
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
      
      // Detailed error logging for debugging
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

  /// Verify that Supabase connection is working
  /// Non-blocking - doesn't fail if connection check fails
  static Future<void> _verifyConnection() async {
    try {
      final client = Supabase.instance.client;
      
      // Simple health check - get current session status
      final session = client.auth.currentSession;
      
      if (session != null) {
        debugLog('[AppInitializer] ✅ Active session found for user: ${session.user.email}');
        
        // Log security event for session resumption
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

  /// Utility method for debug logging
  /// Only logs in debug mode to avoid "avoid_print" warnings
  static void debugLog(String message) {
    assert(() {
      // ignore: avoid_print
      print(message);
      return true;
    }());
  }
}
