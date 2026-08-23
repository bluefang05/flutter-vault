import 'package:flutter/material.dart';

import 'app_repository.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_page.dart';

class PymeRdApp extends StatelessWidget {
  final AppRepository repository;

  const PymeRdApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF7356A8);
    return MaterialApp(
      title: 'PYME RD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F6FB),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      home: FutureBuilder<bool>(
        future: repository.isOnboardingComplete(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.data == true) return HomeShell(repository: repository);
          return OnboardingPage(repository: repository);
        },
      ),
    );
  }
}
