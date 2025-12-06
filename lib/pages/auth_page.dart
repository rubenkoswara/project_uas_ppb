import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/database_providers.dart';
import '../services/supabase_service.dart';
import 'auth_router.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  void toggle() => setState(() => isLogin = !isLogin);

  void auth() async {
    setState(() => loading = true);
    try {
      if (isLogin) {
        final res = await supabase.auth.signInWithPassword(
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
        final res = await supabase.auth.signUp(
          email: emailController.text,
          password: passwordController.text,
        );
        if (res.user != null) {
          // Update user metadata for role
          try {
            await supabase.auth.updateUser(
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pendaftaran berhasil! Silakan masuk kembali.'),
              ),
            );
            setState(() => isLogin = true);
          }
        }
      }
    } catch (e) {
      // Log failed authentication attempt
      await SupabaseService.logSecurityEvent(
        eventType: 'auth_failure',
        description: 'Authentication failed: $e',
        metadata: {'email': emailController.text},
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    setState(() => loading = false);
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
