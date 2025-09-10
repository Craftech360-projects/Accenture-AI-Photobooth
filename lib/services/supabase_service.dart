import 'dart:typed_data';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  static const String imagesBucket = 'accenture_images';
  static const String themesBucket = 'accenture_themes';
  static const String backgroundsBucket = 'accenture_backgrounds';
  static const String imagesTable = 'accenture_images';
  
  // Available themes for AI transformation
  static const List<String> themes = [
    'scientist',
    'psychiatrist',
    'influencer',
    'entrepreneur',
    'future_consultant',
  ];

  /// Upload user captured image to Supabase storage
  Future<String?> uploadImageBytes(
    Uint8List imageBytes,
    String uniqueId, {
    String bucket = imagesBucket,
    String prefix = 'user_',
    String extension = '.jpg',
  }) async {
    try {
      final fileName = '$prefix${uniqueId}_${DateTime.now().millisecondsSinceEpoch}$extension';
      
      final response = await _client.storage
          .from(bucket)
          .uploadBinary(fileName, imageBytes);

      if (response.isNotEmpty) {
        final url = _client.storage.from(bucket).getPublicUrl(fileName);
        return url;
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Get a random character theme image based on gender
  Future<String?> getRandomCharacterImage(String gender) async {
    try {
      // Select random theme
      final randomTheme = themes[Random().nextInt(themes.length)];
      
      // Select random image number (1-5)
      final randomImageNum = Random().nextInt(5) + 1;
      final imageNum = randomImageNum.toString().padLeft(2, '0');
      
      // Construct the path based on the bucket structure
      final fileName = '${gender}_$imageNum.png';
      final imagePath = '$gender/$randomTheme/$fileName';
      
      // Get public URL
      final url = _client.storage.from(themesBucket).getPublicUrl(imagePath);
      
      return url;
    } catch (e) {
      print('Error getting random character image: $e');
      return null;
    }
  }

  /// Get a random background image for BG removal
  Future<String?> getRandomBackground() async {
    try {
      // Select random background (1-3)
      final randomBgNum = Random().nextInt(3) + 1;
      final bgNum = randomBgNum.toString().padLeft(2, '0');
      final fileName = 'background_$bgNum.png';
      
      // Get public URL
      final url = _client.storage.from(backgroundsBucket).getPublicUrl(fileName);
      
      return url;
    } catch (e) {
      print('Error getting random background: $e');
      return null;
    }
  }

  /// Save image record to database
  Future<bool> saveImageRecord({
    required String uniqueId,
    required String imageUrl,
    required String gender,
    String? characterImage,
    String? userName,
    String? userEmail,
  }) async {
    try {
      await _client.from(imagesTable).insert({
        'unique_id': uniqueId,
        'image_url': imageUrl,
        'gender': gender,
        'characterimage': characterImage,
        'name': userName,
        'email': userEmail,
      });
      
      return true;
    } catch (e) {
      print('Error saving image record: $e');
      return false;
    }
  }

  /// Update the output image URL after processing
  Future<bool> updateOutputImage(String uniqueId, String outputUrl) async {
    try {
      await _client
          .from(imagesTable)
          .update({'output': outputUrl})
          .eq('unique_id', uniqueId);
      
      return true;
    } catch (e) {
      print('Error updating output image: $e');
      return false;
    }
  }

  /// Poll for processed output image
  Future<String?> pollForOutput(String uniqueId, {int maxAttempts = 60}) async {
    for (int i = 0; i < maxAttempts; i++) {
      try {
        final response = await _client
            .from(imagesTable)
            .select('output')
            .eq('unique_id', uniqueId)
            .single();

        final outputUrl = response['output'] as String?;
        if (outputUrl != null && outputUrl.isNotEmpty) {
          return outputUrl;
        }

        // Wait 3 seconds before next attempt
        await Future.delayed(const Duration(seconds: 3));
      } catch (e) {
        print('Error polling for output: $e');
        await Future.delayed(const Duration(seconds: 3));
      }
    }
    
    return null; // Timeout
  }

  /// Generate unique ID for user session
  String generateUniqueId() {
    return const Uuid().v4();
  }

  /// Get the latest output image for a unique ID
  Future<String?> getLatestOutputImage(String uniqueId) async {
    try {
      final response = await _client
          .from(imagesTable)
          .select('output')
          .eq('unique_id', uniqueId)
          .single();

      return response['output'] as String?;
    } catch (e) {
      print('Error getting latest output image: $e');
      return null;
    }
  }

  /// Update character image reference (used for BG removal to store selected background)
  Future<bool> updateCharacterImage(String uniqueId, String characterImageUrl) async {
    try {
      await _client
          .from(imagesTable)
          .update({'characterimage': characterImageUrl})
          .eq('unique_id', uniqueId);
      
      return true;
    } catch (e) {
      print('Error updating character image: $e');
      return false;
    }
  }
}