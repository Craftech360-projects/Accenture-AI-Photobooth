import 'dart:convert';
import 'dart:typed_data';
import 'package:accenture_photobooth/config/app_config.dart';
import 'package:accenture_photobooth/services/supabase_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GeminiService {
  static const String model = 'gemini-2.5-flash-image-preview'; // Nano Banana model
  static GenerativeModel? _model;

  static GenerativeModel get _geminiModel {
    _model ??= GenerativeModel(
      model: model,
      apiKey: AppConfig.geminiApiKey,
    );
    return _model!;
  }

  /// Process background replacement using Gemini's image editing capabilities
  Future<String?> processBackgroundRemoval({
    required Uint8List userImageBytes,
    required String backgroundImageUrl,
    required String uniqueId,
  }) async {
    try {
      debugPrint('🔥 Starting Gemini background replacement');
      
      // Download background image for reference
      final backgroundResponse = await http.get(Uri.parse(backgroundImageUrl));
      if (backgroundResponse.statusCode != 200) {
        throw Exception('Failed to download background image');
      }
      
      final backgroundImageBytes = backgroundResponse.bodyBytes;

      // Use web-compatible HTTP API for better reliability
      if (kIsWeb) {
        return await _processBackgroundRemovalWeb(
          userImageBytes, 
          backgroundImageBytes, 
          uniqueId
        );
      }

      // Create a very specific prompt for background replacement
      const prompt = '''
Using the first image (user photo), replace the background with the style and setting from the second image (background reference). 

Instructions:
- Keep the person exactly as they are - same pose, clothing, lighting on the person
- Replace only the background behind the person
- Match the lighting and atmosphere from the reference background
- Ensure natural edges and seamless integration
- Maintain the original image quality and aspect ratio
- The person should look naturally placed in the new environment

Generate the edited image with the person and new background combined.
''';

      // Create content with both images
      final userImagePart = DataPart('image/jpeg', userImageBytes);
      final backgroundImagePart = DataPart('image/png', backgroundImageBytes);
      final textPart = TextPart(prompt);

      debugPrint('🚀 Sending request to Gemini image editing API');

      final response = await _geminiModel.generateContent([
        Content.multi([textPart, userImagePart, backgroundImagePart])
      ]);

      debugPrint('📨 Received response from Gemini API');

      if (response.candidates.isNotEmpty) {
        final candidate = response.candidates.first;
        
        if (candidate.content.parts.isNotEmpty) {
          for (final part in candidate.content.parts) {
            if (part is DataPart && part.mimeType.startsWith('image/')) {
              debugPrint('✅ Successfully generated background replacement');
              debugPrint('Generated image size: ${part.bytes.length} bytes');
              
              // Upload the processed image to Supabase
              final supabaseService = SupabaseService();
              final processedImageUrl = await supabaseService.uploadImageBytes(
                part.bytes,
                uniqueId,
                prefix: 'processed_bg_',
                extension: '.png',
              );
              
              return processedImageUrl;
            }
          }
        }
      }

      debugPrint('❌ No image found in Gemini response');
      
      if (response.text != null && response.text!.isNotEmpty) {
        debugPrint('Gemini response text: ${response.text}');
      }
      
      return null;
    } on GenerativeAIException catch (e) {
      debugPrint('❌ Gemini API error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Error processing background replacement: $e');
      return null;
    }
  }

  /// Web-compatible implementation using HTTP API directly
  Future<String?> _processBackgroundRemovalWeb(
    Uint8List userImageBytes,
    Uint8List backgroundImageBytes,
    String uniqueId,
  ) async {
    try {
      debugPrint('🌐 Using web-compatible HTTP API for Gemini');
      
      const prompt = '''
Using the first image (user photo), replace the background with the style and setting from the second image (background reference). 

Instructions:
- Keep the person exactly as they are - same pose, clothing, lighting on the person
- Replace only the background behind the person  
- Match the lighting and atmosphere from the reference background
- Ensure natural edges and seamless integration
- Maintain the original image quality and aspect ratio
- The person should look naturally placed in the new environment

Generate the edited image with the person and new background combined.
''';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Encode(userImageBytes),
                }
              },
              {
                'inline_data': {
                  'mime_type': 'image/png', 
                  'data': base64Encode(backgroundImageBytes),
                }
              }
            ]
          }
        ],
        'generationConfig': {
          'candidateCount': 1,
          'maxOutputTokens': 4096,
          'temperature': 0.4,
        }
      };

      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${AppConfig.geminiApiKey}',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('📨 Web API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        debugPrint('🔍 Full response structure received');
        
        if (responseData['candidates'] != null &&
            responseData['candidates'].isNotEmpty) {
          final candidate = responseData['candidates'][0];
          
          if (candidate['content'] != null && candidate['content']['parts'] != null) {
            final parts = candidate['content']['parts'];
            debugPrint('🔍 Found ${parts.length} parts in response');
            
            for (int i = 0; i < parts.length; i++) {
              final part = parts[i];
              
              if (part['inlineData'] != null) {
                final imageData = part['inlineData']['data'];
                final imageBytes = base64Decode(imageData);
                debugPrint('✅ Successfully generated background replacement via web API');
                debugPrint('Generated image size: ${imageBytes.length} bytes');
                
                // Upload the processed image to Supabase
                final supabaseService = SupabaseService();
                final processedImageUrl = await supabaseService.uploadImageBytes(
                  imageBytes,
                  uniqueId,
                  prefix: 'processed_bg_',
                  extension: '.png',
                );
                
                return processedImageUrl;
              }
              
              if (part['text'] != null) {
                debugPrint('🔍 Part $i contains text: ${part['text']}');
              }
            }
          } else {
            debugPrint('❌ No content or parts found in candidate');
          }
        } else {
          debugPrint('❌ No candidates found in response');
        }
      } else {
        debugPrint('❌ Web API error: ${response.statusCode} - ${response.body}');
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error in web-compatible Gemini API: $e');
      return null;
    }
  }

  /// Test Gemini connection
  static Future<Map<String, dynamic>> testGeminiConnection() async {
    try {
      const testPrompt = 'Generate a simple test image of a blue circle';
      
      final response = await _geminiModel.generateContent([
        Content.text(testPrompt)
      ]);

      if (response.candidates.isNotEmpty) {
        debugPrint('✅ Gemini API connection successful');
        return {
          'status': 'success',
          'message': 'Gemini API connection successful',
        };
      }

      return {
        'status': 'error',
        'message': 'No response from Gemini API',
      };
    } on GenerativeAIException catch (e) {
      debugPrint('❌ Gemini API connection failed: ${e.message}');
      return {
        'status': 'error',
        'message': 'Gemini API error: ${e.message}',
      };
    } catch (e) {
      debugPrint('❌ Error testing Gemini connection: $e');
      return {
        'status': 'error',
        'message': 'Connection error: $e',
      };
    }
  }
}