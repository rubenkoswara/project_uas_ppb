import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/dns_resolver_service.dart';
import 'auth_router.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  void toggle() => setState(() => isLogin = !isLogin);

  void auth() async {
    // Validasi input sebelum request
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password tidak boleh kosong'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
      _retryCount = 0;
    });

    // Attempt with retry logic
    await _attemptAuth();
  }

  /// Attempt authentication with automatic retry on network error
  Future<void> _attemptAuth() async {
    try {
      // Pre-flight DNS check to ensure connectivity
      try {
        print('[Auth] Performing DNS check before login...');
        await DNSResolverService.verifySuabaseConnectivity()
            .timeout(const Duration(seconds: 10));
        print('[Auth] ✅ DNS check successful, proceeding with login');
      } catch (e) {
        print('[Auth] ⚠️ DNS pre-check failed, but attempting login anyway: $e');
      }

      if (isLogin) {
        final res = await SupabaseService.client.auth.signInWithPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        if (res.user != null) {
          // Save session securely
          await SupabaseService.saveSessionSecurely();
          
          // Log successful login
          await SupabaseService.logSecurityEvent(
            eventType: 'login_success',
            description: 'User successfully logged in',
          );
          
          final userRole = res.user?.appMetadata['role'] ?? 'customer';
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => getAuthDestination(userRole)),
            );
          }
        }
      } else {
        final res = await SupabaseService.client.auth.signUp(
          email: emailController.text,
          password: passwordController.text,
        );
        if (res.user != null) {
          // Update user metadata for role
          try {
            await SupabaseService.client.auth.updateUser(
              UserAttributes(data: {'role': 'customer'}),
            );
          } catch (e) {
            // Role update error - proceed anyway
            print('Role update error: $e');
          }

          // Log successful registration
          await SupabaseService.logSecurityEvent(
            eventType: 'registration_success',
            description: 'New user successfully registered',
          );

          if (mounted) {
            setState(() => loading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pendaftaran berhasil! Silakan masuk kembali.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            setState(() => isLogin = true);
          }
        }
      }
    } catch (e) {
      setState(() => loading = false);

      // Check if error is network-related
      bool isNetworkError = e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network') ||
          e.toString().contains('connection') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException');

      // Try automatic retry for network errors
      if (isNetworkError && _retryCount < _maxRetries) {
        if (mounted) {
          // Show retry attempt message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Network error, retrying... (${_retryCount + 1}/$_maxRetries)'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Wait with exponential backoff: 1s, 2s, 4s
        await Future.delayed(Duration(seconds: 1 << _retryCount));

        setState(() => _retryCount++);
        
        // Retry the authentication
        await _attemptAuth();
        return;
      }

      // Log failed authentication attempt
      try {
        await SupabaseService.logSecurityEvent(
          eventType: 'auth_failure',
          description: 'Authentication failed: $e',
        );
      } catch (logError) {
        // Silent fail on logging
      }
      
      if (mounted) {
        // Provide user-friendly error messages
        String errorMessage = 'Authentication error occurred';
        
        if (isNetworkError) {
          if (_retryCount >= _maxRetries) {
            errorMessage = 'Network error: Failed after ${_maxRetries} attempts. Check your internet connection and try again.';
          } else {
            errorMessage = 'Network error: Please check your internet connection';
          }
        } else if (e.toString().contains('Invalid login credentials')) {
          errorMessage = 'Invalid email or password';
        } else if (e.toString().contains('User already exists')) {
          errorMessage = 'Email already registered';
        } else {
          errorMessage = e.toString();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.water, size: 80, color: Color(0xFF00838F)),
              const SizedBox(height: 10),
              Text(
                'MyRenesca',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00838F),
                ),
              ),
              const SizedBox(height: 5),
              const Text('Aquarium Equipment & Accessories'),
              const SizedBox(height: 40),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        isLogin ? 'Selamat Datang' : 'Buat Akun',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        autofocus: true,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: loading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00838F),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: auth,
                                child: Text(isLogin ? 'Masuk' : 'Daftar'),
                              ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: toggle,
                        child: Text(
                          isLogin
                              ? 'Belum punya akun? Daftar'
                              : 'Sudah punya akun? Masuk',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
