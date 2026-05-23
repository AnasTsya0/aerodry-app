import 'package:flutter/material.dart';
import 'package:aerodry_app/screens/dashboard_screen.dart';
import 'package:aerodry_app/screens/Manual/manual_screen.dart';
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
      home: const DashboardScreen(),
    );
  }
}
