import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl {
    try {
      // Try to get from environment variables first
      var url = dotenv.maybeGet('SUPABASE_URL');
      
      // Fallback to hardcoded value if env var not found
      if (url == null || url.isEmpty) {
        url = 'https://yeffvxkfatwehjzwtuou.supabase.co';
      }
      
      return url;
    } catch (e) {
      // If dotenv not initialized, use hardcoded value
      return 'https://yeffvxkfatwehjzwtuou.supabase.co';
    }
  }

  static String get supabaseAnonKey {
    try {
      // Try to get from environment variables first
      var key = dotenv.maybeGet('SUPABASE_ANON_KEY');
      
      // Fallback to hardcoded value if env var not found
      if (key == null || key.isEmpty) {
        key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllZmZ2eGtmYXR3ZWhqend0dW91Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2NjAzNzQsImV4cCI6MjA3OTIzNjM3NH0.ECGxsdXmWER1jgwQAihS6ozB3H02nq0Q07MF20wnhP0';
      }
      
      return key;
    } catch (e) {
      // If dotenv not initialized, use hardcoded value
      return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllZmZ2eGtmYXR3ZWhqend0dW91Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2NjAzNzQsImV4cCI6MjA3OTIzNjM3NH0.ECGxsdXmWER1jgwQAihS6ozB3H02nq0Q07MF20wnhP0';
    }
  }
}
    
    return key;
  }
}
