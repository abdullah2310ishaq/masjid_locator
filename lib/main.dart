// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MasjidLocatorApp());
}

class MasjidLocatorApp extends StatelessWidget {
  const MasjidLocatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1B5E20),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}