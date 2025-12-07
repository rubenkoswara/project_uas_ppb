import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl {
    try {
      var url = dotenv.maybeGet('SUPABASE_URL');

      if (url == null || url.isEmpty) {
        url = 'https://yeffvxkfatwehjzwtuou.supabase.co';
      }

      return url;
    } catch (e) {
      return 'https://yeffvxkfatwehjzwtuou.supabase.co';
    }
  }

  static String get supabaseAnonKey {
    try {
      var key = dotenv.maybeGet(
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllZmZ2eGtmYXR3ZWhqend0dW91Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2NjAzNzQsImV4cCI6MjA3OTIzNjM3NH0.ECGxsdXmWER1jgwQAihS6ozB3H02nq0Q07MF20wnhP0',
      );

      if (key == null || key.isEmpty) {
        key =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllZmZ2eGtmYXR3ZWhqend0dW91Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2NjAzNzQsImV4cCI6MjA3OTIzNjM3NH0.ECGxsdXmWER1jgwQAihS6ozB3H02nq0Q07MF20wnhP0';
      }

      return key;
    } catch (e) {
      return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllZmZ2eGtmYXR3ZWhqend0dW91Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2NjAzNzQsImV4cCI6MjA3OTIzNjM3NH0.ECGxsdXmWER1jgwQAihS6ozB3H02nq0Q07MF20wnhP0';
    }
  }
}
