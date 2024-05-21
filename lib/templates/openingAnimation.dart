import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../domains/handlers/contactHandler.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  SplashScreen({required this.onFinish});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
    // addMessengerToMatchingContacts();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 5000), () {
      widget.onFinish();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: RiveAnimation.asset(
          'assets/animations/opening.riv',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

