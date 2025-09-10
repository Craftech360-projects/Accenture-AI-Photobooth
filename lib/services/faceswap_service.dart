import 'dart:convert';
import 'package:accenture_photobooth/config/app_config.dart';
import 'package:http/http.dart' as http;

class FaceSwapService {
  static const int maxPollingAttempts = 60;
  static const Duration pollInterval = Duration(seconds: 3);

  /// Send face swap request to RunPod
  Future<bool> sendFaceSwapRequest({
    required String sourceImageUrl,
    required String targetImageUrl,
    required String uniqueId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.runpodFaceswapUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.runpodApiKey}',
        },
        body: jsonEncode({
          'input': {
            'source_image_url': sourceImageUrl,
            'target_image_url': targetImageUrl,
            'unique_id': uniqueId,
          },
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final jobId = responseData['id'];
        
        if (jobId != null) {
          // Start polling for completion in background
          _pollJobStatus(jobId, uniqueId);
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error sending face swap request: $e');
      return false;
    }
  }

  /// Poll RunPod job status
  Future<void> _pollJobStatus(String jobId, String uniqueId) async {
    for (int attempt = 0; attempt < maxPollingAttempts; attempt++) {
      await Future.delayed(pollInterval);
      
      try {
        final statusUrl = '${AppConfig.runpodFaceswapUrl.replaceAll('/run', '')}/status/$jobId';
        
        final response = await http.get(
          Uri.parse(statusUrl),
          headers: {
            'Authorization': 'Bearer ${AppConfig.runpodApiKey}',
          },
        );

        if (response.statusCode == 200) {
          final statusData = jsonDecode(response.body);
          final status = statusData['status'];
          
          if (status == 'COMPLETED') {
            // Job completed successfully
            // The RunPod handler should have already saved the result to Supabase
            return;
          } else if (status == 'FAILED') {
            print('RunPod job failed for uniqueId: $uniqueId');
            return;
          }
          // If status is 'IN_PROGRESS' or 'IN_QUEUE', continue polling
        }
      } catch (e) {
        print('Error polling job status: $e');
      }
    }
    
    print('RunPod job polling timeout for uniqueId: $uniqueId');
  }

  /// Check if a specific job is complete (alternative polling method)
  static Future<bool> checkJobStatus({
    required String jobId,
    required String apiUrl,
    required String apiKey,
  }) async {
    try {
      final statusUrl = '${apiUrl.replaceAll('/run', '')}/status/$jobId';
      
      final response = await http.get(
        Uri.parse(statusUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final statusData = jsonDecode(response.body);
        final status = statusData['status'];
        
        return status == 'COMPLETED';
      }
      
      return false;
    } catch (e) {
      print('Error checking job status: $e');
      return false;
    }
  }
}