import 'package:accenture_photobooth/models/user_selection_model.dart';
import 'package:accenture_photobooth/screens/category_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? selectedGender;

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
                  const SizedBox(height: 54),
                  SizedBox(
                    width: 336,
                    height: 84,
                    child: ElevatedButton(
                      onPressed: selectedGender != null
                          ? () {
                              // Store selection in state management
                              userModel.setGender(selectedGender!);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CategoryScreen(),
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