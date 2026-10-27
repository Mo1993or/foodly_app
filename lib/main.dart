import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodly/Onboarding/splash_screen.dart';

void main() {
  runApp(const FoodlyApp());
}

class FoodlyApp extends StatelessWidget {
  const FoodlyApp({super.key});

  static const orange = Color(0xFFF56624);
  static const green = Color(0xFF173D32);
  static const background = Color(0xFFFAF8F3);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          primary: orange,
          secondary: green,
          surface: background,
        ),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}
