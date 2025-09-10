import 'package:accenture_photobooth/core/app_theme.dart';
import 'package:accenture_photobooth/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      title: 'AI Photobooth',
      home: const WelcomeScreen(),
    );
  }
}
