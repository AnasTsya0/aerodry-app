import 'package:aerodry_app/screens/weather/weather_screen.dart';
import 'package:aerodry_app/screens/Notification/notification_screen.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const AeroDryApp());
}

class AeroDryApp extends StatelessWidget {
  const AeroDryApp({super.key});

 /*@override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AeroDry',
      home: const WeatherScreen(),
    );
  }*/
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AeroDry',
      home: const NotificationScreen(),
    );
  }
}
