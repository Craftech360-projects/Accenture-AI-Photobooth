import 'package:accenture_photobooth/models/user_selection_model.dart';
import 'package:accenture_photobooth/services/supabase_service.dart';
import 'package:accenture_photobooth/services/faceswap_service.dart';
import 'package:accenture_photobooth/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _statusMessage = 'Initializing...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Start processing
    _processImage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processImage() async {
    final userModel = Provider.of<UserSelectionModel>(context, listen: false);
    final supabaseService = SupabaseService();

    try {
      userModel.setProcessing(true);

      // Upload user image to Supabase
      setState(() {
        _statusMessage = 'Uploading your image...';
      });

      final userImageUrl = await supabaseService.uploadImageBytes(
        userModel.capturedImage!,
        userModel.uniqueId!,
      );

      if (userImageUrl == null) {
        throw Exception('Failed to upload image');
      }

      // Save initial record to database
      await supabaseService.saveImageRecord(
        uniqueId: userModel.uniqueId!,
        imageUrl: userImageUrl,
        gender: userModel.gender, // Can be null for BG Removal
      );

      if (userModel.isAiTransformation) {
        await _processAiTransformation(userModel, supabaseService, userImageUrl);
      } else {
        await _processBgRemoval(userModel, supabaseService, userImageUrl);
      }

      // Navigate to output screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/output');
      }

    } catch (e) {
      setState(() {
        _hasError = true;
        _statusMessage = 'Error: $e';
      });
    } finally {
      userModel.setProcessing(false);
    }
  }

  Future<void> _processAiTransformation(
    UserSelectionModel userModel,
    SupabaseService supabaseService,
    String userImageUrl,
  ) async {
    // Get random character image
    setState(() {
      _statusMessage = 'Selecting your character...';
    });

    final characterImageUrl = await supabaseService.getCharacterImage(userModel.gender!, userModel.theme!);
    if (characterImageUrl == null) {
      throw Exception('Failed to get character image');
    }

    userModel.setCharacterImageUrl(characterImageUrl);

    // Update character image in database
    await supabaseService.updateCharacterImage(userModel.uniqueId!, characterImageUrl);

    // Send to RunPod for face swap
    setState(() {
      _statusMessage = 'Transforming your image...';
    });

    final faceswapService = FaceSwapService();
    final success = await faceswapService.sendFaceSwapRequest(
      sourceImageUrl: userImageUrl,
      targetImageUrl: characterImageUrl,
      uniqueId: userModel.uniqueId!,
    );

    if (!success) {
      throw Exception('Failed to start face swap processing');
    }

    // Poll for results
    setState(() {
      _statusMessage = 'Processing transformation...\nThis may take a few minutes.';
    });

    final outputUrl = await supabaseService.pollForOutput(userModel.uniqueId!);
    if (outputUrl == null) {
      throw Exception('Processing timeout or failed');
    }

    userModel.setProcessedImageUrl(outputUrl);
  }

  Future<void> _processBgRemoval(
    UserSelectionModel userModel,
    SupabaseService supabaseService,
    String userImageUrl,
  ) async {
    // Get selected background
    setState(() {
      _statusMessage = 'Loading selected background...';
    });

    final backgroundUrl = await supabaseService.getSelectedBackground(userModel.selectedBackground!);
    if (backgroundUrl == null) {
      throw Exception('Failed to get selected background image');
    }

    // Update character image field with background reference
    await supabaseService.updateCharacterImage(userModel.uniqueId!, backgroundUrl);

    // Process with Gemini
    setState(() {
      _statusMessage = 'Replacing background with AI...';
    });

    final geminiService = GeminiService();
    final processedImageUrl = await geminiService.processBackgroundRemoval(
      userImageBytes: userModel.capturedImage!,
      backgroundImageUrl: backgroundUrl,
      uniqueId: userModel.uniqueId!,
    );

    if (processedImageUrl == null) {
      throw Exception('Failed to process background removal');
    }

    // Update output in database
    await supabaseService.updateOutputImage(userModel.uniqueId!, processedImageUrl);
    userModel.setProcessedImageUrl(processedImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/backdrop.png",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_hasError) ...[
                  // Loading animation
                  RotationTransition(
                    turns: _animationController,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  // Error state
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}