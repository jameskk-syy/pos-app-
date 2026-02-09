import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos/screens/users/bussiness_type.dart';
import 'package:pos/utils/themes/app_colors.dart';

class LoadingMessage extends StatefulWidget {
  final List<String>? messages;

  const LoadingMessage({
    super.key,
    this.messages,
  });

  @override
  State<LoadingMessage> createState() => _LoadingMessageState();
}

class _LoadingMessageState extends State<LoadingMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late List<String> _messages;
  int _currentIndex = 0;
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();

    _messages = widget.messages?.isNotEmpty == true
        ? widget.messages!
        : [
            "Welcome to Savanna POS",
            "This won’t take long. Your retail dashboard will be ready in a moment.",
          ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    if (_messages.length > 1) {
      _textTimer = Timer.periodic(
        const Duration(seconds: 4),
        (_) {
          if (!mounted) return;
          setState(() {
            _currentIndex = (_currentIndex + 1) % _messages.length;
          });
        },
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BussinessTypePage()),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/svgs/splash.svg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            SafeArea(
              child: SizedBox.expand(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'assets/svgs/logosplash.svg',
                              width: size.width * 0.45,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          _messages[_currentIndex],
                          key: ValueKey(_currentIndex),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/svgs/group.svg',
                width: size.width * 0.75,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
