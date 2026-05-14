import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 255, 249, 249),
                  Color(0xFFF8FBFF),
                  Color.fromARGB(255, 202, 227, 253),
                  Color.fromARGB(255, 172, 211, 255),
                ],
                stops: [0.0, 0.45, 0.75, 1.0],
              ),
            ),
          ),

          /// WAVE1
          Positioned(
            top: 120,
            child: Image.asset(
              'assets/images/wave2.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          //WAVE2
          Positioned(
            bottom: 20,
            child: Opacity(
              opacity: 0.60,
              child: Image.asset(
                'assets/images/wave3.png',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// SMALL LOGO
          Positioned(
            top: 40,
            left: 22,
            child: Opacity(
              opacity: 0.80,
              child: Image.asset('assets/images/logo.png', width: 95),
            ),
          ),

          /// MACHINE IMAGE
          Positioned(
            top: 170,
            right: -10,
            child: Image.asset('assets/images/machine.png', width: 220),
          ),

          /// CONTENT
          Positioned(
            bottom: 90,
            left: 30,
            right: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome To",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                ),

                Transform.translate(
                  offset: const Offset(-12, -10),
                  child: Image.asset('assets/images/aerodry.png', width: 230),
                ),

                Transform.translate(
                  offset: const Offset(-2, -15),
                  child: const Text(
                    "Smart drying. Smarter living",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.60),

                      side: BorderSide(
                        color: const Color.fromARGB(
                          255,
                          87,
                          155,
                          251,
                        ).withOpacity(0.90),
                        width: 1.5,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        color: Color(0xFF5C94D6),
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
