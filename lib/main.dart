import 'package:flutter/material.dart';

import 'screens/gps_screen.dart';

void main() {
  runApp(const StudyTrackApp());
}

class StudyTrackApp extends StatelessWidget {
  const StudyTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyTrack',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF670310),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
      ),
      home: const GpsScreen(),
    );
  }
}