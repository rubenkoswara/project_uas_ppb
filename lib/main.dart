import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/supabase_config.dart';
import 'pages/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: MyRenescaApp()));
}

class MyRenescaApp extends StatelessWidget {
  const MyRenescaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyRenesca',
      debugShowCheckedModeBanner: false,
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
