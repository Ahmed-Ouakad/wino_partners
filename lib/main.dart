import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wino_partners/core/services/secure_caching_service.dart';
import 'package:wino_partners/feature/auth/presentation/bloc/login_bloc.dart';
import 'package:wino_partners/feature/auth/presentation/bloc/register_bloc.dart';
import 'package:wino_partners/feature/auth/presentation/screens/login_screen.dart';
import 'package:wino_partners/feature/home/presentation/screens/main_screen.dart';

import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  // Check if an active session exists before rendering the initial route
  final secureCachingService = di.sl<SecureCachingService>();
  final accessToken = await secureCachingService.getAccessToken();
  final bool isAuthenticated = accessToken != null && accessToken.isNotEmpty;

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({
    super.key,
    this.isAuthenticated = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RegisterBloc>(
          create: (_) => di.sl<RegisterBloc>(),
        ),
        BlocProvider<LoginBloc>(
          create: (_) => di.sl<LoginBloc>(),
        ),
      ],
      child: MaterialApp(
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
        home: isAuthenticated ? const MainScreen() : const LoginScreen(),
      ),
    );
  }
}
