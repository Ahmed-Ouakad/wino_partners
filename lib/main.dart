import 'package:flutter/material.dart';
import 'package:wino_partners/feature/auth/presentation/screens/login_screen.dart';
import 'package:wino_partners/feature/auth/presentation/screens/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFC61D23),
          secondary: Color(0xFF86AB3E),
          onSurface: Color(0xFF1A1A1A),
          onSurfaceVariant: Color(0xFF8d7977),
          outlineVariant: Color(0xFFe8c3c0),
          surface: Color(0xFFF8F9FA),
          surfaceContainer: Color(0xFFF8F9FA),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFC61D23),
          secondary: Colors.white,
          onSurface: Colors.white,
          onSurfaceVariant: Color(0xFFA38784),
          outlineVariant: Color(0xFFe8c3c0),
          surface: Color(0xFF0D0D0D),
          surfaceContainer: Color(0xFF2A2A2A),
        ),
      ),
      home: const SignupScreen(),
    );
  }
}


