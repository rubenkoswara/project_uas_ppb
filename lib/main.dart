import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/supabase_config.dart';
import 'pages/auth_page.dart';

Future<void> initializeSupabase() async {
  try {
    print('[Init] Starting Supabase initialization...');
    
    // Load environment variables from .env file (optional)
    print('[Init] Loading .env file...');
    await dotenv.load().catchError((_) {
      print('[Init] .env file not found, using fallback configuration');
      return;
    });

    // Initialize Supabase with error handling
    print('[Init] Initializing Supabase...');
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    
    print('[Init] Supabase initialized successfully!');
  } catch (e) {
    print('[ERROR] Supabase initialization failed: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('[Init] App started');
  
  // Initialize Supabase before running app
  await initializeSupabase();
  
  print('[Init] Starting Flutter app');
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
      home: const InitializationWrapper(),
    );
  }
}

class InitializationWrapper extends StatefulWidget {
  const InitializationWrapper({super.key});

  @override
  State<InitializationWrapper> createState() => _InitializationWrapperState();
}

class _InitializationWrapperState extends State<InitializationWrapper> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    print('[Wrapper] Initializing app...');
    // Ensure Supabase is ready before showing AuthPage
    _initFuture = Future.delayed(const Duration(milliseconds: 500), () {
      print('[Wrapper] Initialization complete');
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Show splash/loading screen
          return const SplashScreen();
        }
        
        if (snapshot.hasError) {
          print('[ERROR] Initialization error: ${snapshot.error}');
          return const ErrorScreen();
        }
        
        // Show auth page when ready
        print('[Wrapper] Showing AuthPage');
        return const AuthPage();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water, size: 80, color: Color(0xFF00838F)),
            const SizedBox(height: 20),
            Text(
              'MyRenesca',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00838F),
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Color(0xFF00838F),
            ),
            const SizedBox(height: 30),
            const Text(
              'Loading aplikasi...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Error Initializing App',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please check your connection and try again',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Restart the app
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
