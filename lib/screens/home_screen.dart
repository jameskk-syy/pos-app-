import 'package:flutter/material.dart';
import 'package:pos/screens/auth/login.dart';
import 'package:pos/screens/bussiness_type.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/utils/themes/app_sizes.dart';
import 'package:pos/widgets/app_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isTablet = _isTablet(context);

    // Responsive values
    final topPadding = isTablet ? size.height * 0.08 : size.height * 0.05;
    final imageHeight = isTablet ? size.height * 0.45 : size.height * 0.5;
    final spacing1 = isTablet ? size.height * 0.04 : size.height * 0.05;
    final titleFontSize = isTablet ? 28.0 : 22.0;
    final spacing2 = isTablet ? size.height * 0.04 : size.height * 0.05;
    final buttonWidth = isTablet ? 500.0 : size.width * 0.8;
    final buttonHeight = isTablet ? 50.0 : 40.0;
    final orSpacing = isTablet ? size.height * 0.015 : size.height * 0.01;
    final orFontSize = isTablet ? 16.0 : 14.0;
    final maxContentWidth = isTablet ? 700.0 : double.infinity;

    return Scaffold(
      backgroundColor: colors.primary,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: Column(
                children: [
                  SizedBox(
                    height: imageHeight,
                    child: Image.asset(
                      "assets/welcome.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: spacing1),
                  Text(
                    "Let's Get Started",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: spacing2),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppButton(
                          width: buttonWidth,
                          height: buttonHeight,
                          borderRadius: BorderRadius.circular(4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.padding / 2,
                          ),
                          buttonColor: Theme.of(context).colorScheme.surfaceContainer,
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builders) => SignInScreen(),
                              ),
                            )
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: isTablet ? 16.0 : 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: orSpacing),
                        Text(
                          "OR",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: orFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: orSpacing),
                        AppButton(
                          width: buttonWidth,
                          height: buttonHeight,
                          borderRadius: BorderRadius.circular(4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.padding / 2,
                          ),
                          buttonColor: Theme.of(context).colorScheme.secondaryContainer,
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builders) => BussinessTypePage(),
                              ),
                            )
                          },
                          child: Text(
                            "Join Us",
                            style: TextStyle(
                              fontSize: isTablet ? 16.0 : 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}