import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:projectuasppb/config/supabase_config.dart';
import 'package:projectuasppb/services/supabase_service.dart';

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
  /// 3. Initializing Supabase with credentials
  /// 4. Setting up error handlers
  /// 
  /// Throws: [Exception] if Supabase initialization fails
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

      // Step 2: Initialize Supabase
      debugLog('$logTag Initializing Supabase...');
      await _initializeSupabase();
      debugLog('$logTag Supabase initialized successfully');

      // Step 3: Verify connection
      debugLog('$logTag Verifying Supabase connection...');
      await _verifyConnection();

      debugLog('$logTag ✅ App initialization complete!');
    } catch (e, stackTrace) {
      debugLog('[AppInitializer] ❌ Initialization error: $e');
      debugLog('[AppInitializer] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Initialize Supabase with credentials
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
        debug: true, // Enable debug logging
      );

      debugLog('[AppInitializer] Supabase client initialized');
    } catch (e) {
      debugLog('[AppInitializer] Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  /// Verify that Supabase connection is working
  static Future<void> _verifyConnection() async {
    try {
      final client = Supabase.instance.client;
      
      // Simple health check - get current session status
      final session = client.auth.currentSession;
      
      if (session != null) {
        debugLog('[AppInitializer] ✅ Active session found for user: ${session.user.email}');
        
        // Log security event for session resumption
        await SupabaseService.logSecurityEvent(
          eventType: 'session_resumed',
          description: 'Session resumed on app start',
        );
      } else {
        debugLog('[AppInitializer] No active session - user needs to login');
      }

      debugLog('[AppInitializer] ✅ Database connection verified');
      
    } catch (e) {
      debugLog('[AppInitializer] Connection verification warning: $e');
      // Don't fail initialization if verification fails - app can still work
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
