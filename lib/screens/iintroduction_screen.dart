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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = _isTablet(context);
    
    // Responsive values
    final horizontalPadding = isTablet ? size.width * 0.15 : size.width * 0.05;
    final maxContentWidth = isTablet ? 600.0 : double.infinity;
    final svgHeight = isTablet ? size.height * 0.4 : size.height * 0.35;
    final pageViewHeight = isTablet ? size.height * 0.5 : size.height * 0.45;
    final fontSize = isTablet ? 22.0 : size.width * 0.05;
    final buttonHeight = isTablet ? 56.0 : size.height * 0.05;
    final buttonFontSize = isTablet ? 18.0 : size.width * 0.045;
    final topSpacing = isTablet ? size.height * 0.1 : size.height * 0.08;
    final bottomSpacing = isTablet ? size.height * 0.08 : size.height * 0.1;
    final groupWidth = isTablet ? size.width * 0.5 : size.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: size.height,
                    ),
                    child: Column(
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
                                children: [
                                  SvgPicture.asset(
                                    slide['svg']!,
                                    height: svgHeight,
                                  ),
                                  const SizedBox(height: 24),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: horizontalPadding,
                                    ),
                                    child: Text(
                                      slide['text']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            slides.length,
                            (index) => _dot(index == _currentPage, isTablet),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
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
                              const SizedBox(width: 16),
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
                                      side: const BorderSide(color: Colors.blue),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue,
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
              child: SvgPicture.asset(
                'assets/svgs/group.svg',
                width: groupWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(bool active, bool isTablet) {
    final dotSize = isTablet ? (active ? 14.0 : 10.0) : (active ? 12.0 : 8.0);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: active ? Colors.blue : Colors.blue.withAlpha(77),
        shape: BoxShape.circle,
      ),
    );
  }
}