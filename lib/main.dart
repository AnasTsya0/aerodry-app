import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aerodry_app/firebase_options.dart';
import 'package:aerodry_app/screens/dashboard_screen.dart';
import 'package:aerodry_app/services/firebase_service.dart';
import 'package:aerodry_app/constants/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load user profile name/email from SharedPreferences
  await UserProfileState.loadFromPrefs();

  // Start real-time listeners for the active device
  FirebaseService.instance.init('bag5CPfEIBXhnVPhiHnk68hg9CS2');

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
