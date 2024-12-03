import 'dart:async';
import 'package:acousti_care_frontend/home_page.dart';
import 'package:acousti_care_frontend/views/images.dart';
import 'package:acousti_care_frontend/views/profile/profile_setup.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashPage extends StatefulWidget {
  const FlashPage({super.key});

  @override
  State<FlashPage> createState() => _FlashPageState();
}

class _FlashPageState extends State<FlashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(_controller);
    _controller.forward();
    Timer(const Duration(seconds: 3), _checkProfileSetup);
  }

  Future<void> _checkProfileSetup() async {
    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isProfileSetup = prefs.getBool('isProfileSetup') ?? false;

    if (isProfileSetup) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileSetup(isAddingNewProfile: false)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  logo,
                  width: getScreenWidth(context) * 0.65,
                ),
              ),
              FadeTransition(
                opacity: _opacityAnimation,
                child: Image.asset(
                  logoName,
                  width: getScreenWidth(context) * 0.70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

