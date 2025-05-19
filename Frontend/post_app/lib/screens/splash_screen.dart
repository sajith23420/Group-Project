import 'dart:async';
import 'package:flutter/material.dart';
import 'package:post_app/screens/login_screen.dart'; // Assuming your package name is post_app

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () {
        if (!mounted) return; // Prevent navigation if widget is disposed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/splash_background.png', // Replace with your image path
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
