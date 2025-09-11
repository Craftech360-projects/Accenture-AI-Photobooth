import 'package:accenture_photobooth/screens/category_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/welcome_screen.png",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            margin: const EdgeInsets.all(110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Step Into a New You.",
                  style: TextStyle(
                    fontFamily: "GraphikTrial",
                    color: Colors.white,
                    fontSize: 70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "Discover how you look and feel in roles\nthat inspire transformation and possibility.",
                  style: TextStyle(
                    fontFamily: "GraphikTrial",
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 70),
                SizedBox(
                  width: 336,
                  height: 84,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CategoryScreen()),
                    ),
                    child: Text("Start"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
