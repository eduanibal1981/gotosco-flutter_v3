import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/repositories/auth_repository_impl.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Performance: Set status bar color to match background for seamless look
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // 2. Setup High-Performance Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6)),
    );

    _controller.forward();

    // 3. Trigger Initialization
    _initApp();
  }

  Future<void> _initApp() async {
    // Performance: Run display timer and initialization checks in PARALLEL.
    // We wait for whichever takes longer. This ensures we don't hold the user
    // if the DB is fast, but we show the brand for at least 1.5s if DB is instant.

    final minDisplayTime = Future.delayed(const Duration(milliseconds: 1500));
    final initTask = _initializeCriticalData();

    await Future.wait([minDisplayTime, initTask]);

    if (!mounted) return;

    // 4. Navigation Logic
    _checkAuthAndNavigate();
  }

  /// Place to pre-load assets or fetch critical configs
  Future<void> _initializeCriticalData() async {
    // Example: Precache the Login Screen images here so the next screen
    // appears INSTANTLY without "pop-in".
    // await precacheImage(const AssetImage('assets/images/login_bg.png'), context);

    // Simulate other startup checks (like checking internet connection)
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _checkAuthAndNavigate() {
    // Read the current user synchronously (fast)
    final user = ref.read(authRepositoryProvider).currentUser;

    if (user != null) {
      // Check role and route accordingly
      final role = user.metadata?['role'];
      if (role == 'driver') {
        context.go('/driver-home');
      } else {
        context.go('/parent-home');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Professional Gradient consistent with Login Screen
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.indigo.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- Logo Image ---
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- App Name ---
                      const Text(
                        'GoToSco',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),

                      // --- Tagline ---
                      const SizedBox(height: 8),
                      Text(
                        'Safe School Transport',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 60),

                      // --- Loading Indicator ---
                      // Small and minimalistic to not distract from branding
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
