import 'package:accenture_photobooth/core/app_theme.dart';
import 'package:accenture_photobooth/models/user_selection_model.dart';
import 'package:accenture_photobooth/screens/welcome_screen.dart';
import 'package:accenture_photobooth/screens/processing_screen.dart';
import 'package:accenture_photobooth/screens/output_screen.dart';
import 'package:accenture_photobooth/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserSelectionModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        title: 'AI Photobooth',
        home: const WelcomeScreen(),
        routes: {
          '/processing': (context) => const ProcessingScreen(),
          '/output': (context) => const OutputScreen(),
        },
      ),
    );
  }
}