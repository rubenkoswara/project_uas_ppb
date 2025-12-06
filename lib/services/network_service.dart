import 'dart:io';
import 'package:http/http.dart' as http;

/// Custom HTTP client dengan DNS caching dan connection persistence
/// Mengatasi DNS resolution issues yang sering terjadi di beberapa operator
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();

  late HttpClient _httpClient;
  final Map<String, List<String>> _resolvedIPs = {};
  final List<String> _supabaseIPs = [
    '104.18.38.10',
    '104.18.39.10',
    '172.64.149.246',
    '172.64.150.246',
    '104.21.78.246',
    '104.21.79.246',
  ];

  factory NetworkService() {
    return _instance;
  }

  NetworkService._internal() {
    _httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..idleTimeout = const Duration(seconds: 30);
  }

  /// Resolve hostname dengan multiple strategies
  Future<String> resolveHostname(String hostname) async {
    print('[NetworkService] Resolving: $hostname');

    // Strategy 1: Cache lookup
    if (_resolvedIPs.containsKey(hostname)) {
      final ips = _resolvedIPs[hostname]!;
      if (ips.isNotEmpty) {
        print('[NetworkService] ✅ Using cached IP: ${ips.first}');
        return ips.first;
      }
    }

    // Strategy 2: Standard DNS resolution dengan retry
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        print('[NetworkService] DNS Attempt $attempt/3...');
        final addresses = await InternetAddress.lookup(hostname)
            .timeout(Duration(seconds: 5 + (attempt * 2))); // Increasing timeout

        if (addresses.isNotEmpty) {
          final ips = addresses.map((a) => a.address).toList();
          _resolvedIPs[hostname] = ips;
          print('[NetworkService] ✅ Resolved to: ${ips.first}');
          return ips.first;
        }
      } catch (e) {
        print('[NetworkService] ❌ DNS Attempt $attempt failed: $e');
        if (attempt < 3) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }

    // Strategy 3: Gunakan hardcoded IPs untuk Supabase
    if (hostname.contains('supabase.co')) {
      print('[NetworkService] Trying hardcoded Supabase IPs...');
      for (String ip in _supabaseIPs) {
        try {
          print('[NetworkService] Testing IP: $ip');
          final socket = await Socket.connect(ip, 443)
              .timeout(const Duration(seconds: 3));
          socket.destroy();

          _resolvedIPs[hostname] = [ip];
          print('[NetworkService] ✅ Connected via IP: $ip');
          return ip;
        } catch (e) {
          print('[NetworkService] IP $ip failed: $e');
          continue;
        }
      }
    }

    throw SocketException('Cannot resolve: $hostname (all strategies failed)');
  }

  /// Test connectivity ke Supabase dengan multiple methods
  Future<bool> testSupabaseConnectivity() async {
    print('[NetworkService] Testing Supabase connectivity...');

    // Test 1: Domain lookup
    try {
      await resolveHostname('yeffvxkfatwehjzwtuou.supabase.co')
          .timeout(const Duration(seconds: 15));
      print('[NetworkService] ✅ Domain lookup successful');
      return true;
    } catch (e) {
      print('[NetworkService] Domain lookup failed: $e');
    }

    // Test 2: Direct IP connection
    for (String ip in _supabaseIPs) {
      try {
        final socket = await Socket.connect(ip, 443)
            .timeout(const Duration(seconds: 3));
        socket.destroy();
        print('[NetworkService] ✅ IP connection successful: $ip');
        return true;
      } catch (e) {
        print('[NetworkService] IP connection failed for $ip: $e');
      }
    }

    // Test 3: HTTP GET request
    try {
      final request = await _httpClient.getUrl(
        Uri.https('yeffvxkfatwehjzwtuou.supabase.co', '/auth/v1/health'),
      );
      request.followRedirects = false;
      final response = await request.close()
          .timeout(const Duration(seconds: 10));
      print('[NetworkService] ✅ HTTP request successful: ${response.statusCode}');
      return true;
    } catch (e) {
      print('[NetworkService] HTTP request failed: $e');
    }

    return false;
  }

  /// Clear DNS cache
  void clearCache() {
    _resolvedIPs.clear();
    print('[NetworkService] DNS cache cleared');
  }

  /// Get resolver status
  Map<String, List<String>> getResolverStatus() {
    return Map.from(_resolvedIPs);
  }
}
