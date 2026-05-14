import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const AeroDryApp());
}

class AeroDryApp extends StatelessWidget {
  const AeroDryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AeroDry',
      home: const SplashScreen(),
    );
  }
}
