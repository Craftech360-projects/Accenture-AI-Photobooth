import 'package:accenture_photobooth/models/user_selection_model.dart';
import 'package:accenture_photobooth/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

class OutputScreen extends StatefulWidget {
  const OutputScreen({super.key});

  @override
  State<OutputScreen> createState() => _OutputScreenState();
}

class _OutputScreenState extends State<OutputScreen> {
  int _autoNavigateCountdown = 120; // 2 minutes
  bool _isCountdownActive = true;

  @override
  void initState() {
    super.initState();
    _startAutoNavigate();
  }

  void _startAutoNavigate() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isCountdownActive || !mounted) return false;
      
      setState(() {
        _autoNavigateCountdown--;
      });
      
      if (_autoNavigateCountdown <= 0) {
        _navigateHome();
        return false;
      }
      
      return true;
    });
  }

  void _navigateHome() {
    final userModel = Provider.of<UserSelectionModel>(context, listen: false);
    userModel.reset();
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  void _printImage() async {
    final userModel = Provider.of<UserSelectionModel>(context, listen: false);
    
    if (!userModel.hasProcessedImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image available to print')),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Preparing image for printing...'),
              ],
            ),
          );
        },
      );

      // Download the image
      final response = await http.get(Uri.parse(userModel.processedImageUrl!));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }

      // Create PDF document
      final pdf = pw.Document();
      final imageBytes = response.bodyBytes;
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                image,
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show print dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Accenture_Photobooth_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to print image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSelectionModel>(
      builder: (context, userModel, child) {
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

              // Countdown timer
              if (_isCountdownActive)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Auto home in ${_autoNavigateCountdown}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

              Center(
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 110, vertical: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Main content area
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your Preview Is Ready",
                            style: TextStyle(fontSize: 70),
                          ),
                          
                          // Display processed image
                          Container(
                            decoration: const BoxDecoration(color: Colors.white),
                            width: 1034,
                            height: 582,
                            child: userModel.hasProcessedImage
                                ? Image.network(
                                    userModel.processedImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error, size: 50, color: Colors.red),
                                            Text('Failed to load image'),
                                          ],
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 16),
                                        Text('Loading your image...'),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 80),
                      
                      // Side panel
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your",
                            style: TextStyle(
                              fontSize: 70,
                              color: Colors.transparent,
                            ),
                          ),
                          Row(
                            children: [
                              // QR Code
                              Container(
                                width: 257,
                                height: 257,
                                color: Colors.white,
                                child: userModel.hasProcessedImage
                                    ? QrImageView(
                                        data: userModel.processedImageUrl!,
                                        version: QrVersions.auto,
                                        size: 257,
                                        backgroundColor: Colors.white,
                                      )
                                    : const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                              ),
                              const SizedBox(width: 40),
                              const Text(
                                "Scan the\nQR Code\nto download\nimage",
                                style: TextStyle(fontSize: 40),
                              ),
                            ],
                          ),
                          const SizedBox(height: 177),
                          
                          // Print button
                          SizedBox(
                            width: 257,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: userModel.hasProcessedImage
                                  ? _printImage
                                  : null,
                              child: const Text("Print"),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Home button
                          SizedBox(
                            width: 257,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isCountdownActive = false;
                                });
                                _navigateHome();
                              },
                              child: const Text("Home"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}