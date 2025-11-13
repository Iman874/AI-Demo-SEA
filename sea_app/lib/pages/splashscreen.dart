import 'package:flutter/material.dart';
// import halaman choice user
import 'page_choice_user.dart';
import 'connection_config_page.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1500), () async {
      _controller.reverse().then((_) async {
        if (!mounted) return;
        // Always show connection configuration after splash
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ConnectionConfigPage(
              onConfigured: () async {
                // Optional: quick connectivity check
                await ApiService.checkConnection();
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => ChoiceUserPage()),
                );
              },
            ),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            'assets/logo.png',
            width: 220,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
