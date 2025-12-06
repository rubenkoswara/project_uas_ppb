import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/supabase_config.dart';
import 'pages/auth_page.dart';

Future<void> initializeSupabase() async {
  try {
    // Load environment variables from .env file (optional)
    await dotenv.load().catchError((_) {
      // .env file doesn't exist, which is okay - we have fallback
      return;
    });

    // Initialize Supabase with error handling
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } catch (e) {
    // Log error for debugging
    print('Supabase initialization error: $e');
    rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase before running app
  await initializeSupabase();
  
  runApp(const ProviderScope(child: MyRenescaApp()));
}

class MyRenescaApp extends StatelessWidget {
  const MyRenescaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyRenesca',
      debugShowCheckedModeBanner: false,
      builder: (context, widget) {
        // Show error UI if there's an uncaught exception
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 60),
                  const SizedBox(height: 20),
                  const Text(
                    'Oops! Something went wrong',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorDetails.exceptionAsString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        };
        return widget ?? const SizedBox();
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00838F),
          primary: const Color(0xFF00838F),
          secondary: const Color(0xFF00BCD4),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF00838F),
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthPage(),
    );
  }
}
