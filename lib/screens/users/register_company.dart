import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/models/message.dart';
import 'package:pos/domain/requests/users/register_company.dart';
import 'package:pos/presentation/registerCompanyBloc/bloc/register_company_bloc.dart';
import 'package:pos/screens/auth/otp.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';

class RegisterCompany extends StatefulWidget {
  const RegisterCompany({super.key});

  @override
  State<RegisterCompany> createState() => _RegisterCompanyState();
}

class _RegisterCompanyState extends State<RegisterCompany> {
  late final RemoteDataSource remoteDataSource;
  int step = 0;
  bool isLoading = false;
  String? industry;
  String? companySize;
  String? country;
  final companyNameCtrl = TextEditingController();
  final hqLocationCtrl = TextEditingController();

  final address1Ctrl = TextEditingController();
  final address2Ctrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final contactEmailCtrl = TextEditingController();

  final industries = [
    "Retail",
    "Hospitality",
    "Healthcare",
    "Education",
    "Technology",
    "Other",
  ];

  final sizes = [
    "1 – 10 employees",
    "11 – 50 employees",
    "51 – 200 employees",
    "200+ employees",
  ];

  final countries = [
    "Kenya",
    "Uganda",
    "Tanzania",
    "Rwanda",
    "South Africa",
    "Nigeria",
    "Ghana",
  ];
  Message? companyData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await getUserData();

    if (!mounted) return;

    setState(() {
      companyData = data;
    });
  }

  Future<Message?> getUserData() async {
    final storage = getIt<StorageService>();
    String? userDataJson = await storage.getString('userData');

    if (userDataJson == null) {
      return null;
    }

    Map<String, dynamic> userDataMap = jsonDecode(userDataJson);
    return Message.fromJson(userDataMap);
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return BlocListener<RegisterCompanyBloc, RegisterCompanyState>(
      listener: (context, state) {
        if (state is RegisterCompanyLoading) {
          setState(() {
            isLoading = true;
          });
        } else if (state is RegisterCompanySuccess) {
          setState(() {
            isLoading = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const OtpScreen(title: "register", showBackLogin: false),
            ),
          );
        } else if (state is RegisterCompanyFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: h * 0.04),
                SvgPicture.asset("assets/svgs/maiLogo.svg", height: 70),
                const SizedBox(height: 24),
                const Text(
                  "Create Your Account",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Start using Techsavanna POS for your\norganization.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                if (step == 0) _companyStep(),
                if (step == 1) _addressStep(),
                if (step == 2) _contactStep(),

                const SizedBox(height: 32),

                Row(
                  children: [
                    if (step > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => step--),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: AppColors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Back",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                      ),
                    if (step > 0) const SizedBox(width: 16),
                    Expanded(
                      child:
                          BlocBuilder<
                            RegisterCompanyBloc,
                            RegisterCompanyState
                          >(
                            builder: (context, state) {
                              final isLoading = state is RegisterCompanyLoading;

                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null // disable button while loading
                                    : () {
                                        getUserData();
                                        if (step < 2) {
                                          setState(() => step++);
                                        } else {
                                          final companyRequest = CompanyRequest(
                                            companyName: companyNameCtrl.text,
                                            abbr:
                                                companyNameCtrl.text.length >= 3
                                                ? companyNameCtrl.text
                                                      .substring(0, 3)
                                                      .toUpperCase()
                                                : companyNameCtrl.text
                                                      .toUpperCase(),
                                            country: country ?? 'Kenya',
                                            defaultCurrency: 'KES',
                                            companyAddress: CompanyAddress(
                                              addressLine1: address1Ctrl.text,
                                              addressLine2: address2Ctrl.text,
                                              city: cityCtrl.text,
                                              state: stateCtrl.text,
                                              country: country ?? 'Kenya',
                                              pincode: '',
                                              phone: phoneCtrl.text,
                                              emailId: emailCtrl.text,
                                            ),
                                            companyContact: CompanyContact(
                                              firstName: firstNameCtrl.text,
                                              lastName: lastNameCtrl.text,
                                              email: contactEmailCtrl.text,
                                            ),
                                          );
                                          context
                                              .read<RegisterCompanyBloc>()
                                              .add(
                                                RegisterCompanyEventIntial(
                                                  companyRequest:
                                                      companyRequest,
                                                ),
                                              );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        step == 2 ? "Finish" : "Continue",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              );
                            },
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _companyStep() {
    return Column(
      children: [
        const _InputLabel("Company Name"),
        _InputField(hint: "Tell us who you are", controller: companyNameCtrl),
        const SizedBox(height: 16),
        const _InputLabel("Industry Type"),
        _DropdownField(
          hint: "What is your industry?",
          value: industry,
          items: industries,
          onChanged: (v) => setState(() => industry = v),
        ),
        const SizedBox(height: 16),
        const _InputLabel("Company Size"),
        _DropdownField(
          hint: "How many employees do you have?",
          value: companySize,
          items: sizes,
          onChanged: (v) => setState(() => companySize = v),
        ),
        const SizedBox(height: 16),
        const _InputLabel("Country"),
        _DropdownField(
          hint: "Select your country",
          value: country,
          items: countries,
          onChanged: (v) => setState(() => country = v),
        ),
        const SizedBox(height: 16),
        const _InputLabel("Headquarter Location"),
        _InputField(
          hint: "Where are you located?",
          icon: Icons.location_on_outlined,
          controller: hqLocationCtrl,
        ),
      ],
    );
  }

  Widget _addressStep() {
    return Column(
      children: [
        const _InputLabel("Address Line 1"),
        _InputField(hint: "Address line 1", controller: address1Ctrl),
        const SizedBox(height: 16),
        const _InputLabel("Address Line 2"),
        _InputField(hint: "Address line 2", controller: address2Ctrl),
        const SizedBox(height: 16),
        const _InputLabel("City"),
        _InputField(hint: "City", controller: cityCtrl),
        const SizedBox(height: 16),
        const _InputLabel("State"),
        _InputField(hint: "State", controller: stateCtrl),
        const SizedBox(height: 16),
        const _InputLabel("Phone"),
        _InputField(hint: "Phone", controller: phoneCtrl),
        const SizedBox(height: 16),
        const _InputLabel("Email"),
        _InputField(hint: "Email", controller: emailCtrl),
      ],
    );
  }

  Widget _contactStep() {
    return Column(
      children: [
        const _InputLabel("First Name"),
        _InputField(hint: "First name", controller: firstNameCtrl),
        const SizedBox(height: 16),
        const _InputLabel("Last Name"),
        _InputField(hint: "Last name", controller: lastNameCtrl),
        const SizedBox(height: 16),
        const _InputLabel("Contact Email"),
        _InputField(hint: "Email", controller: contactEmailCtrl),
      ],
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;
  const _InputLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final IconData? icon;
  final TextEditingController controller;

  const _InputField({required this.hint, required this.controller, this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: icon != null ? Icon(icon) : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
    );
  }
}
