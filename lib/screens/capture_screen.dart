import 'dart:typed_data';
import 'package:accenture_photobooth/models/user_selection_model.dart';
import 'package:accenture_photobooth/services/supabase_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _isCapturing = false;
  int _countdown = 0;
  bool _isCountingDown = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      CameraDescription selectedCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isCapturing || _isCountingDown) {
      return;
    }

    // Start countdown
    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });

    // Countdown timer
    for (int i = 3; i > 0; i--) {
      if (!mounted) return;
      setState(() {
        _countdown = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;

    setState(() {
      _isCountingDown = false;
      _isCapturing = true;
    });

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      if (!mounted) return;
      
      final userModel = Provider.of<UserSelectionModel>(context, listen: false);
      
      // Crop image based on selected category
      int widthRatio, heightRatio;
      if (userModel.isBgRemoval) {
        // BG Removal: 16:9 landscape (1920x1080)
        widthRatio = 16;
        heightRatio = 9;
      } else {
        // AI Transformation: 9:16 portrait
        widthRatio = 9;
        heightRatio = 16;
      }
      
      // Generate unique ID if not already set
      if (userModel.uniqueId == null) {
        final supabaseService = SupabaseService();
        userModel.setUniqueId(supabaseService.generateUniqueId());
      }
      
      // Store raw image first for immediate navigation
      userModel.setCapturedImage(imageBytes);
      
      // Navigate to processing screen immediately
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/processing');
      }
      
      // Process cropping asynchronously after navigation
      Future.microtask(() async {
        final croppedBytes = await _cropToAspectRatio(imageBytes, widthRatio, heightRatio);
        // Update with cropped image
        userModel.setCapturedImage(croppedBytes);
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to capture image: $e';
      });
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<Uint8List> _cropToAspectRatio(Uint8List imageBytes, int widthRatio, int heightRatio) async {
    final img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return imageBytes;

    final int originalWidth = originalImage.width;
    final int originalHeight = originalImage.height;
    
    // Calculate target dimensions maintaining aspect ratio
    final double targetAspectRatio = widthRatio / heightRatio;
    final double currentAspectRatio = originalWidth / originalHeight;
    
    int cropWidth, cropHeight;
    int offsetX = 0, offsetY = 0;
    
    if (currentAspectRatio > targetAspectRatio) {
      // Image is wider than target - crop width
      cropHeight = originalHeight;
      cropWidth = (originalHeight * targetAspectRatio).round();
      offsetX = (originalWidth - cropWidth) ~/ 2;
    } else {
      // Image is taller than target - crop height
      cropWidth = originalWidth;
      cropHeight = (originalWidth / targetAspectRatio).round();
      offsetY = (originalHeight - cropHeight) ~/ 2;
    }
    
    final img.Image croppedImage = img.copyCrop(
      originalImage,
      x: offsetX,
      y: offsetY,
      width: cropWidth,
      height: cropHeight,
    );
    
    return Uint8List.fromList(img.encodeJpg(croppedImage, quality: 90));
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length <= 1) return;

    setState(() {
      _isInitialized = false;
    });

    final currentDirection = _cameraController!.description.lensDirection;
    
    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection != currentDirection,
      orElse: () => _cameras!.first,
    );

    await _cameraController?.dispose();

    _cameraController = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      
      if (!mounted) return;
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to switch camera: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/backdrop.png",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          
          Center(child: _buildCameraView()),
          
          // Countdown overlay
          if (_isCountingDown)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  child: Center(
                    child: Text(
                      '$_countdown',
                      style: const TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          

          // Capture button positioned below camera feed
          if (!_isCapturing)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: (MediaQuery.of(context).size.width - 336) / 2.125,
              child: SizedBox(
                width: 336,
                height: 84,
                child: ElevatedButton(
                  onPressed: (_isInitialized && !_isCountingDown) ? _captureImage : null,
                  child: _isCountingDown 
                      ? Text("$_countdown")
                      : const Text("Capture"),
                ),
              ),
            ),

          // Camera switch button
          if (_cameras != null && _cameras!.length > 1 && _isInitialized && !_isCapturing && !_isCountingDown)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 20,
              child: IconButton(
                onPressed: _switchCamera,
                icon: const Icon(
                  Icons.cameraswitch,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            
          // Back button
          if (!_isCountingDown)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (_errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (!_isInitialized || _cameraController == null) {
      return const CircularProgressIndicator(
        color: Colors.white,
      );
    }

    return Consumer<UserSelectionModel>(
      builder: (context, userModel, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;

            // Dynamic aspect ratio based on category
            double targetAspectRatio;
            if (userModel.isBgRemoval) {
              targetAspectRatio = 16 / 9; // Landscape for BG Removal (1920x1080)
            } else {
              targetAspectRatio = 9 / 16; // Portrait for AI Transformation
            }

            const double scaleFactor = 0.7;

            double cameraWidth;
            double cameraHeight;

            if (userModel.isBgRemoval) {
              // For landscape (BG Removal): prioritize width
              if (screenWidth / screenHeight > targetAspectRatio) {
                cameraHeight = screenHeight * scaleFactor;
                cameraWidth = cameraHeight * targetAspectRatio;
              } else {
                cameraWidth = screenWidth * scaleFactor;
                cameraHeight = cameraWidth / targetAspectRatio;
              }
            } else {
              // For portrait (AI Transformation): prioritize height
              if (screenHeight / screenWidth > 16 / 9) {
                cameraWidth = screenWidth * scaleFactor;
                cameraHeight = cameraWidth * (16 / 9);
              } else {
                cameraHeight = screenHeight * scaleFactor;
                cameraWidth = cameraHeight * targetAspectRatio;
              }
            }
            
            return Container(
              width: cameraWidth,
              height: cameraHeight,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: ClipRRect(
                child: AspectRatio(
                  aspectRatio: targetAspectRatio,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            );
          },
        );
      },
    );
  }
}