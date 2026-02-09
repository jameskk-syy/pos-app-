import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos/screens/sales/iintroduction_screen.dart';
import 'package:pos/screens/sales/dashboard.dart';
// import 'package:pos/screens/auth/register_company_details.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/screens/sales/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _logoOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Delay navigation until animation completes
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(
      const Duration(milliseconds: 3000),
    ); // wait for animation
    final storage = getIt<StorageService>();
    final onboarded = await storage.getBool('ON_BOARDING') ?? true;
    final accessToken = await storage.getString('access_token');

    if (!mounted) return;

    if (accessToken != null && accessToken.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => onboarded ? const IntroScreen() : const HomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = _isTablet(context);

    // Responsive sizing
    final logoWidth = isTablet ? size.width * 0.3 : size.width * 0.5;
    final groupWidth = isTablet ? size.width * 0.5 : size.width * 0.8;
    final backgroundOpacity = isTablet ? 0.85 : 0.9;

    return Scaffold(
      backgroundColor: AppColors.blue,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: backgroundOpacity,
              child: SvgPicture.asset(
                'assets/svgs/splash.svgs',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: _logoScale,
              child: FadeTransition(
                opacity: _logoOpacity,
                child: SvgPicture.asset(
                  'assets/svgs/logosplash.svg',
                  width: logoWidth,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/svgs/group.svg',
              width: groupWidth,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
