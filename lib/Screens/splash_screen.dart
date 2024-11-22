import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Screens/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: 'assets/StreamX.gif',
      splashIconSize: 500,
      centered: true,
      nextScreen: HomeScreen(),
      backgroundColor: Colors.black,
      duration: 5000,
    );
  }
}
