import 'package:accenture_photobooth/models/user_selection_model.dart';
import 'package:accenture_photobooth/screens/capture_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BackgroundSelectionScreen extends StatefulWidget {
  const BackgroundSelectionScreen({super.key});

  @override
  State<BackgroundSelectionScreen> createState() =>
      _BackgroundSelectionScreenState();
}

class _BackgroundSelectionScreenState extends State<BackgroundSelectionScreen> {
  String? selectedBackground;

  final List<Map<String, String>> backgrounds = [
    {
      'id': 'background_01.png',
      'name': 'Tech Office',
      'asset': 'assets/images/background_01.png',
    },
    {
      'id': 'background_02.png',
      'name': 'Modern Workspace',
      'asset': 'assets/images/background_02.png',
    },
    {
      'id': 'background_03.png',
      'name': 'Professional Studio',
      'asset': 'assets/images/background_03.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserSelectionModel>(context);

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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Choose Your Preferred Background",
                    style: TextStyle(fontSize: 70),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: backgrounds.map((background) {
                      final isSelected = selectedBackground == background['id'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedBackground = background['id'];
                            });
                          },
                          child: Container(
                            width: 500,
                            height: 280,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: isSelected ? 4 : 2,
                                color: isSelected ? Colors.blue : Colors.white,
                              ),
                              // borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    background['asset']!,
                                    fit: BoxFit.cover,
                                  ),
                                  if (isSelected)
                                    Container(
                                      color: Colors.blue.withValues(alpha: 0.3),
                                      child: const Center(
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 54),
                  Center(
                    child: SizedBox(
                      width: 336,
                      height: 84,
                      child: ElevatedButton(
                        onPressed: selectedBackground != null
                            ? () {
                                // Store background selection in state management
                                userModel.setSelectedBackground(
                                  selectedBackground!,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CaptureScreen(),
                                  ),
                                );
                              }
                            : null,
                        child: const Text("Next"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
