import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/screens/auth/login.dart';
import 'package:pos/presentation/subdomainBloc/subdomain_bloc.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/presentation/widgets/custom_text_field.dart';

class SubdomainLoginScreen extends StatelessWidget {
  const SubdomainLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SubdomainBloc>(),
      child: const SubdomainLoginView(),
    );
  }
}

class SubdomainLoginView extends StatefulWidget {
  const SubdomainLoginView({super.key});

  @override
  State<SubdomainLoginView> createState() => _SubdomainLoginViewState();
}

class _SubdomainLoginViewState extends State<SubdomainLoginView> {
  final TextEditingController _slugController = TextEditingController();

  @override
  void dispose() {
    _slugController.dispose();
    super.dispose();
  }

  void _validateAndContinue() {
    final slug = _slugController.text.trim();
    if (slug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a subdomain slug")),
      );
      return;
    }
    context.read<SubdomainBloc>().add(ValidateSubdomain(slug: slug));
  }

  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final maxFormWidth = isTablet ? 600.0 : double.infinity;

    return Scaffold(
      backgroundColor: isTablet ? const Color(0xFFF5F5F5) : Colors.white,
      appBar: AppBar(
        backgroundColor: isTablet ? const Color(0xFFF5F5F5) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<SubdomainBloc, SubdomainState>(
        listener: (context, state) {
          if (state is SubdomainSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            );
          } else if (state is SubdomainFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          final isLoading = state is SubdomainLoading;

          Widget content = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                "assets/svgs/maiLogo.svg",
                height: isTablet ? 100 : 70,
              ),
              const SizedBox(height: 40),
              Text(
                "Sign in to your workspace",
                style: TextStyle(
                  fontSize: isTablet ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Enter your workspace subdomain slug to continue",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                controller: _slugController,
                label: "Subdomain Slug",
                hint: "e.g. my-subdomain",
                prefixIcon: const Icon(Icons.business),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: isTablet ? 60 : 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _validateAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          );

          if (isTablet) {
            content = Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: content,
              ),
            );
          }

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxFormWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : 20),
                  child: content,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
