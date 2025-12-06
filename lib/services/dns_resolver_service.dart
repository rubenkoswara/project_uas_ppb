import 'dart:io';

/// DNS Resolver Service
/// Handles DNS resolution with automatic fallback to multiple DNS providers
class DNSResolverService {
  static const String _primaryHost = 'yeffvxkfatwehjzwtuou.supabase.co';

  // Cache resolved IPs to avoid repeated lookups
  static Map<String, String> _dnsCache = {};

  /// Resolve hostname with fallback mechanisms
  /// Returns resolved IP or throws exception if all methods fail
  static Future<String> resolveHost(String host) async {
    // Check cache first
    if (_dnsCache.containsKey(host)) {
      print('[DNSResolver] Using cached IP for $host: ${_dnsCache[host]}');
      return _dnsCache[host]!;
    }

    print('[DNSResolver] Attempting to resolve: $host');

    // Try Method 1: Standard DNS resolution
    try {
      print('[DNSResolver] Method 1: Standard DNS lookup...');
      final addresses = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 5));
      if (addresses.isNotEmpty) {
        final ip = addresses.first.address;
        _dnsCache[host] = ip;
        print('[DNSResolver] ✅ Method 1 Success: Resolved to $ip');
        return ip;
      }
    } catch (e) {
      print('[DNSResolver] ❌ Method 1 Failed: $e');
    }

    // Try Method 2: Alternative - try with custom timeout
    try {
      print('[DNSResolver] Method 2: DNS lookup with extended timeout (10s)...');
      final addresses = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 10));
      if (addresses.isNotEmpty) {
        final ip = addresses.first.address;
        _dnsCache[host] = ip;
        print('[DNSResolver] ✅ Method 2 Success: Resolved to $ip');
        return ip;
      }
    } catch (e) {
      print('[DNSResolver] ❌ Method 2 Failed: $e');
    }

    // Try Method 3: Hardcoded IP as last resort (if available)
    // Note: Supabase uses CDN so IP might change, but helpful for testing
    try {
      print('[DNSResolver] Method 3: Using cached/known IP...');
      if (host.contains('supabase.co')) {
        // Supabase CDN IPs (as of Dec 2024)
        // Note: These are Cloudflare IPs used by Supabase
        List<String> knownIPs = [
          '104.18.38.10',
          '104.18.39.10',
          '172.64.149.246',
          '172.64.150.246',
        ];

        for (String ip in knownIPs) {
          try {
            print('[DNSResolver] Trying IP: $ip...');
            final socket = await Socket.connect(ip, 443)
                .timeout(const Duration(seconds: 3));
            socket.destroy();
            _dnsCache[host] = ip;
            print('[DNSResolver] ✅ Method 3 Success: Using IP $ip');
            return ip;
          } catch (e) {
            print('[DNSResolver] IP $ip failed: $e');
            continue;
          }
        }
      }
    } catch (e) {
      print('[DNSResolver] ❌ Method 3 Failed: $e');
    }

    // All methods failed
    print('[DNSResolver] ❌ All DNS resolution methods failed');
    throw SocketException('Failed to resolve host: $host');
  }

  /// Clear DNS cache (useful for testing or network changes)
  static void clearCache() {
    _dnsCache.clear();
    print('[DNSResolver] DNS cache cleared');
  }

  /// Get cache status
  static Map<String, String> getCacheStatus() {
    return Map.from(_dnsCache);
  }

  /// Verify Supabase connectivity with multiple methods
  static Future<bool> verifySuabaseConnectivity() async {
    print('[DNSResolver] Verifying Supabase connectivity...');

    // Method 1: Try to resolve
    try {
      await resolveHost(_primaryHost);
      print('[DNSResolver] ✅ Supabase host resolved successfully');
      return true;
    } catch (e) {
      print('[DNSResolver] Host resolution failed: $e');
    }

    // Method 2: Try HTTP GET request
    try {
      print('[DNSResolver] Attempting HTTP connectivity test...');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse(
        'https://$_primaryHost/auth/v1/health',
      ));
      final response = await request.close();
      client.close();

      if (response.statusCode < 500) {
        print('[DNSResolver] ✅ HTTP request successful');
        return true;
      }
    } catch (e) {
      print('[DNSResolver] HTTP test failed: $e');
    }

    print('[DNSResolver] ❌ Connectivity verification failed');
    return false;
  }
}
