import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos/screens/auth/login.dart';
import 'package:pos/screens/auth/register_user.dart';
import 'package:pos/utils/themes/app_colors.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;
  Timer? _timer;

  final slides = [
    {
      'svg': 'assets/svgs/posone.svg',
      'text': 'Process sales that fit your business flow.',
    },
    {
      'svg': 'assets/svgs/postwo.svg',
      'text': 'Complete transactions in seconds, no friction.',
    },
    {
      'svg': 'assets/svgs/posthree.svg',
      'text': 'Track your inventory and manage stock easily.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _currentPage++;
      if (_currentPage >= _totalPages) _currentPage = 0;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1100;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = _isTablet(context);
    final isDesktop = _isDesktop(context);

    // Responsive configurations
    final double maxContentWidth = isDesktop
        ? 800.0
        : (isTablet ? 600.0 : double.infinity);

    // SVG sizing: Fixed max height for desktop to prevent it from being huge
    final double svgHeight = isDesktop
        ? 350.0
        : (isTablet ? size.height * 0.35 : size.height * 0.35);

    // PageView height needs to accommodate SVG + Text + Spacing
    final double pageViewHeight = isDesktop
        ? 500.0
        : (isTablet ? size.height * 0.5 : size.height * 0.55);

    final double fontSize = isDesktop
        ? 24.0
        : (isTablet ? 22.0 : size.width * 0.05);
    final double buttonHeight = isDesktop
        ? 56.0
        : (isTablet ? 56.0 : size.height * 0.06); // Slightly taller on mobile
    final double buttonFontSize = isDesktop
        ? 18.0
        : (isTablet ? 18.0 : size.width * 0.045);

    // Spacing
    final double topSpacing = isDesktop
        ? 40.0
        : (isTablet ? size.height * 0.08 : size.height * 0.08);
    final double bottomSpacing = isDesktop ? 40.0 : size.height * 0.22;

    // Background decoration constraints
    final double groupWidth = isDesktop
        ? 400.0
        : (isTablet ? 300.0 : size.width * 0.6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: isDesktop ? 600 : size.height,
                    ), // Relax minHeight on desktop
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center vertically on desktop
                      children: [
                        SizedBox(height: topSpacing),
                        SizedBox(
                          height: pageViewHeight,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: slides.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final slide = slides[index];
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    slide['svg']!,
                                    height: svgHeight,
                                    width: isDesktop
                                        ? 400
                                        : null, // Limit width too
                                  ),
                                  const SizedBox(height: 32),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isDesktop
                                          ? 20.0
                                          : 0, // Less internal padding on desktop as container is already constrained
                                    ),
                                    child: Text(
                                      slide['text']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            slides.length,
                            (index) => _dot(
                              index == _currentPage,
                              isTablet || isDesktop,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop
                                ? 100.0
                                : 0, // Narrower button area on desktop
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: buttonHeight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context2) => SignUpScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.blue,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ), // Softer corners
                                      ),
                                    ),
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: SizedBox(
                                  height: buttonHeight,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context2) => SignInScreen(),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.blue,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: bottomSpacing),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: isDesktop ? 0.0 : 1.0,
                  child: isDesktop
                      ? const SizedBox.shrink()
                      : SvgPicture.asset(
                          'assets/svgs/group.svg',
                          width: groupWidth,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(bool active, bool isLargeScreen) {
    final dotSize = isLargeScreen
        ? (active ? 14.0 : 10.0)
        : (active ? 12.0 : 8.0);
    final activeWidth = isLargeScreen
        ? 32.0
        : 24.0; // Elongated active dot for modern look

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? activeWidth : dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: active ? AppColors.blue : AppColors.blue.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
