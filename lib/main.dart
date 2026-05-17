import 'package:aerodry_app/screens/profile/add_new_device_screen.dart';
import 'package:aerodry_app/screens/profile/connected_device_screen.dart';
import 'package:aerodry_app/screens/profile/profile_screen.dart';
import 'package:aerodry_app/screens/profile/search_location_screen.dart';

import 'package:flutter/material.dart';

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
      home: const ProfileScreen(),
    );
  }
}
