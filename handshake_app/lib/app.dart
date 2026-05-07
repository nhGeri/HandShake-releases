import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class HandShakeApp extends StatelessWidget {
  const HandShakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HandShake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}