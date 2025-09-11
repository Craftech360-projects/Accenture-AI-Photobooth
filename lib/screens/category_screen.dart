import 'package:accenture_photobooth/models/user_selection_model.dart';
import 'package:accenture_photobooth/screens/background_selection_screen.dart';
import 'package:accenture_photobooth/screens/gender_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? selectedCategory;

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
                  const Text("Select Category", style: TextStyle(fontSize: 70)),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = 'ai_transformation';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(left: 42, top: 42),
                          width: 386,
                          height: 315,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(
                              width: selectedCategory == 'ai_transformation'
                                  ? 4
                                  : 3,
                              color: selectedCategory == 'ai_transformation'
                                  ? Colors.blue
                                  : Colors.white,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/images/ai_transformation.png",
                                width: 92,
                                height: 92,
                              ),
                              const SizedBox(height: 48),
                              const Text(
                                "Individual Mode",
                                style: TextStyle(fontSize: 35),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = 'bg_removal';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(left: 42, top: 42),
                          width: 386,
                          height: 315,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(
                              width: selectedCategory == 'bg_removal' ? 4 : 3,
                              color: selectedCategory == 'bg_removal'
                                  ? Colors.green
                                  : Colors.white,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/images/bg_removal.png",
                                width: 92,
                                height: 92,
                              ),
                              const SizedBox(height: 48),
                              const Text(
                                "Group Mode",
                                style: TextStyle(fontSize: 35),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 54),
                  SizedBox(
                    width: 336,
                    height: 84,
                    child: ElevatedButton(
                      onPressed: selectedCategory != null
                          ? () {
                              // Store selection in state management
                              userModel.setCategory(selectedCategory!);

                              // Navigate based on category
                              if (selectedCategory == 'bg_removal') {
                                // For BG Removal: go to background selection
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BackgroundSelectionScreen(),
                                  ),
                                );
                              } else {
                                // For AI Transformation: go to gender selection
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GenderScreen(),
                                  ),
                                );
                              }
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
