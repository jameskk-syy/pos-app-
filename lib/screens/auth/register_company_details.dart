import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/requests/register_company.dart';
import 'package:pos/domain/requests/register_user.dart';
import 'package:pos/presentation/registerCompanyBloc/bloc/register_company_bloc.dart';
import 'package:pos/screens/bussiness_type.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RegisterCompanyDetails extends StatefulWidget {
  final RegisterRequest? registerRequest;

  const RegisterCompanyDetails({super.key, this.registerRequest});

  @override
  State<RegisterCompanyDetails> createState() => _RegisterCompanyDetailsState();
}

class _RegisterCompanyDetailsState extends State<RegisterCompanyDetails> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController abbrController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.registerRequest != null) {
      companyNameController.text = widget.registerRequest!.businessName;
      abbrController.text = _generateAbbr(widget.registerRequest!.businessName);
    } else {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString('userData');
    if (userDataJson != null) {
      final userData = jsonDecode(userDataJson);
      setState(() {
        // Pre-fill what we can from saved userData if available
        // Note: business_name was not saved earlier as it's the 2nd step
      });
      debugPrint('Loaded user data for persistence: $userData');
    }
  }

  String _generateAbbr(String name) {
    String cleanName = name
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toUpperCase();
    if (cleanName.length >= 3) {
      return cleanName.substring(0, 3);
    } else if (cleanName.length >= 2) {
      return cleanName;
    } else {
      return ("${cleanName}POS").substring(0, 3);
    }
  }

  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final isTablet = _isTablet(context);
    final maxFormWidth = isTablet ? 600.0 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (_) => getIt<RegisterCompanyBloc>(),
        child: BlocConsumer<RegisterCompanyBloc, RegisterCompanyState>(
          listener: (context, state) {
            if (state is RegisterCompanyFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state is RegisterCompanySuccess) {
              SharedPreferences.getInstance().then((prefs) {
                prefs.setBool('company_registered', true);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Company registered successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const BussinessTypePage()),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is RegisterCompanyLoading;

            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxFormWidth),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 20,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: h * 0.05),
                        SvgPicture.asset("assets/svgs/maiLogo.svg", height: 70),
                        const SizedBox(height: 24),
                        Text(
                          "Company Details",
                          style: TextStyle(
                            fontSize: isTablet ? 32 : 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: isTablet ? 10 : 6),
                        Text(
                          "Tell us more about your business.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: isTablet ? 40 : 32),

                        _InputLabel("Company Name", isTablet: isTablet),
                        _InputField(
                          controller: companyNameController,
                          hint: "Your business name",
                          isTablet: isTablet,
                          onChanged: (v) {
                            abbrController.text = _generateAbbr(v);
                          },
                        ),

                        SizedBox(height: isTablet ? 20 : 16),

                        _InputLabel("Abbreviation", isTablet: isTablet),
                        _InputField(
                          controller: abbrController,
                          hint: "COY",
                          isTablet: isTablet,
                        ),

                        SizedBox(height: isTablet ? 20 : 16),

                        _InputLabel("Country", isTablet: isTablet),
                        _InputField(
                          controller: countryController,
                          hint: "Enter your country",
                          isTablet: isTablet,
                        ),

                        SizedBox(height: isTablet ? 20 : 16),

                        _InputLabel("City", isTablet: isTablet),
                        _InputField(
                          controller: cityController,
                          hint: "Enter your city",
                          isTablet: isTablet,
                        ),

                        SizedBox(height: isTablet ? 36 : 28),

                        SizedBox(
                          width: double.infinity,
                          height: isTablet ? 56 : 52,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (countryController.text.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please enter a country',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    if (cityController.text.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please enter a city'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    final email =
                                        widget.registerRequest?.email ?? "";
                                    final firstName =
                                        widget.registerRequest?.firstName ?? "";
                                    final lastName =
                                        widget.registerRequest?.lastName ?? "";

                                    final companyRequest = CompanyRequest(
                                      companyName: companyNameController.text
                                          .trim(),
                                      abbr: abbrController.text.trim(),
                                      country: countryController.text.trim(),
                                      defaultCurrency: "KES",
                                      companyAddress: CompanyAddress(
                                        addressLine1: cityController.text
                                            .trim(),
                                        addressLine2: "",
                                        city: cityController.text.trim(),
                                        state: "",
                                        country: countryController.text.trim(),
                                        pincode: "",
                                        phone: "",
                                        emailId: email,
                                      ),
                                      companyContact: CompanyContact(
                                        firstName: firstName,
                                        lastName: lastName,
                                        email: email,
                                      ),
                                    );

                                    context.read<RegisterCompanyBloc>().add(
                                      RegisterCompanyEventIntial(
                                        companyRequest: companyRequest,
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: isTablet ? 24 : 22,
                                    width: isTablet ? 24 : 22,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Finish",
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;
  final bool isTablet;
  const _InputLabel(this.text, {this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isTablet ? 16 : 14,
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool isTablet;
  final ValueChanged<String>? onChanged;
  const _InputField({
    required this.hint,
    this.controller,
    this.isTablet = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(fontSize: isTablet ? 16 : 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 18 : 16,
          vertical: isTablet ? 16 : 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
