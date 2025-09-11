import 'package:accenture_photobooth/models/user_selection_model.dart';
import 'package:accenture_photobooth/screens/capture_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? selectedGender;
  String? selectedTheme;
  
  final List<Map<String, String>> themes = [
    {'id': 'scientist', 'name': 'Scientist'},
    {'id': 'psychiatrist', 'name': 'Psychologist'},
    {'id': 'influencer', 'name': 'Influencer'},
    {'id': 'entrepreneur', 'name': 'Entrepreneur'},
    {'id': 'future_consultant', 'name': 'Future Consultant'},
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Select Your Gender", 
                    style: TextStyle(fontSize: 70),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGender = 'male';
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: selectedGender == 'male'
                                ? Border.all(color: Colors.blue, width: 4)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset("assets/images/male.png"),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGender = 'female';
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: selectedGender == 'female'
                                ? Border.all(color: Colors.pink, width: 4)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset("assets/images/female.png"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Theme selection section
                  if (selectedGender != null) ...[
                    const Text(
                      "Choose Your Preferred Theme", 
                      style: TextStyle(fontSize: 50),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: themes.map((theme) {
                        final isSelected = selectedTheme == theme['id'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTheme = theme['id'];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Colors.blue.withValues(alpha: 0.3)
                                  : Colors.white.withValues(alpha: 0.2),
                              border: Border.all(
                                width: isSelected ? 3 : 2,
                                color: isSelected ? Colors.blue : Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              theme['name']!,
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                  
                  SizedBox(
                    width: 336,
                    height: 84,
                    child: ElevatedButton(
                      onPressed: selectedGender != null && (selectedGender == 'male' || selectedGender == 'female') && selectedTheme != null
                          ? () {
                              // Store selections in state management
                              userModel.setGender(selectedGender!);
                              userModel.setTheme(selectedTheme!);
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}