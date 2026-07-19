import 'package:flutter/material.dart';
import 'page_choice_user.dart';
import 'connection_config_page.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();

    // Animasi masuk (logo muncul)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleIn = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Fade + scale in
    _fadeController.forward();
    _scaleController.forward();

    // Tahan 1.5 detik
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // Fade out
    _fadeController.reverse();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Navigate ke connection config
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ConnectionConfigPage(
          onConfigured: () async {
            await ApiService.checkConnection();
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => ChoiceUserPage()),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeIn,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeIn.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.4,
                  colors: isDark
                      ? [
                          const Color(0xFF1C2233),
                          const Color(0xFF0D1117),
                        ]
                      : [
                          const Color(0xFFFFFFFF),
                          const Color(0xFFEEF3F8),
                        ],
                ),
              ),
              child: Stack(
                children: [
                  // Logo utama
                  Center(
                    child: AnimatedBuilder(
                      animation: _scaleIn,
                      builder: (context, child) => Transform.scale(
                        scale: _scaleIn.value,
                        child: child,
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Versi di bawah
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _fadeIn,
                      builder: (context, child) => Opacity(
                        opacity: _fadeIn.value,
                        child: child,
                      ),
                      child: Text(
                        'v1.0.2',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
