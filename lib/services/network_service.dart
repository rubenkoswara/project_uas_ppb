import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:projectuasppb/config/supabase_config.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();

  factory NetworkService() {
    return _instance;
  }

  NetworkService._internal();

  Future<void> testSupabaseConnectivity() async {
    print('[NetworkService] Testing Supabase connectivity...');

    try {
      final healthEndpoint = Uri.parse('${SupabaseConfig.supabaseUrl}/auth/v1/health');
      final response = await http.get(healthEndpoint).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        print('[NetworkService] ✅ Supabase health check successful.');
      } else {
        throw HttpException('Health check failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('[NetworkService] ❌ Supabase connectivity test failed: $e');
      rethrow;
    }
  }
}
