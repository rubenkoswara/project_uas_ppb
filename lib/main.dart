import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yeffvxkfatwehjzwtuou.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllZmZ2eGtmYXR3ZWhqend0dW91Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2NjAzNzQsImV4cCI6MjA3OTIzNjM3NH0.ECGxsdXmWER1jgwQAihS6ozB3H02nq0Q07MF20wnhP0',
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
