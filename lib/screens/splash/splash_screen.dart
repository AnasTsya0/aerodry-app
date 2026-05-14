import 'dart:async';
import 'package:flutter/material.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// MAIN BACKGROUND
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFCFCFC),
                  Color(0xFFF8FBFF),
                  Color.fromARGB(255, 162, 207, 255),
                  Color.fromARGB(255, 120, 183, 255),
                ],
                stops: [0.0, 0.45, 0.75, 1.0],
              ),
            ),
          ),
          Container(color: Colors.white.withOpacity(0.15)),

          /// WAVE 1
          Positioned(
            bottom: 160,
            child: Opacity(
              opacity: 0.55,
              child: Image.asset(
                'assets/images/wave1.png',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// CONTENT
          SafeArea(
            child: Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 200),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// LOGO
                      Image.asset(
                        'assets/images/logo.png',
                        width: 268,
                        fit: BoxFit.contain,
                      ),

                      /// AERODRY PNG
                      Transform.translate(
                        offset: const Offset(0, -6),
                        child: Image.asset(
                          'assets/images/aerodry.png',
                          width: 210,
                          fit: BoxFit.contain,
                        ),
                      ),

                      /// TAGLINE
                      Transform.translate(
                        offset: const Offset(0, -10),
                        child: const Text(
                          "Smart drying. Smarter living",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF7A8793),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
