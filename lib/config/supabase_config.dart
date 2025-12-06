import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl {
    // Try to get from environment variables first
    var url = dotenv.env['SUPABASE_URL'];
    
    // Fallback to hardcoded value if env var not found
    // This is for development/testing when .env file is not available
    if (url == null || url.isEmpty) {
      url = 'https://yeffvxkfatwehjzwtuou.supabase.co';
    }
    
    return url;
  }

  static String get supabaseAnonKey {
    // Try to get from environment variables first
    var key = dotenv.env['SUPABASE_ANON_KEY'];
    
    // Fallback to hardcoded value if env var not found
    // This is for development/testing when .env file is not available
    if (key == null || key.isEmpty) {
      key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllZmZ2eGtmYXR3ZWhqend0dW91Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2NjAzNzQsImV4cCI6MjA3OTIzNjM3NH0.ECGxsdXmWER1jgwQAihS6ozB3H02nq0Q07MF20wnhP0';
    }
    
    return key;
  }
}
