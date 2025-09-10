import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get runpodFaceswapUrl => dotenv.env['RUNPOD_FACESWAP_URL'] ?? '';
  static String get runpodApiKey => dotenv.env['RUNPOD_API_KEY'] ?? '';
}