import 'dart:async';
import 'package:flutter/material.dart';
import 'listing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to listing screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ListingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (Optional: put a Sikh symbol like Khanda here)
          Image.asset(
            'assets/images/khanda_bg.png',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.4),
            colorBlendMode: BlendMode.darken,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon or Symbol
              Image.asset(
                'assets/images/khanda_white.png',
                height: 100,
                color: Colors.amberAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                'ਨਿਤਨੇਮ - Nitnem',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                  fontFamily: 'GurbaniAkhar', // Optional custom font
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Daily Sikh Prayers',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
