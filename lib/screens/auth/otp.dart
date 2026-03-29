import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/domain/requests/biller/biller_requests.dart';
import 'package:pos/presentation/biller/bloc/biller_bloc.dart';
import 'package:pos/presentation/loginBloc/bloc/login_bloc.dart';
import 'package:pos/screens/sales/dashboard.dart';
import 'package:pos/screens/users/bussiness_type.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/screens/auth/login.dart';
import 'package:pos/screens/auth/set_new_password.dart';
import 'package:pos/widgets/biller/biller_selector_sheet.dart';

class OtpScreen extends StatefulWidget {
  final bool showBackLogin;
  final String title;
  final String? email;

  const OtpScreen({
    super.key,
    required this.title,
    this.showBackLogin = false,
    this.email,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool _isInitializingBiller = false;

  /// Mirrors the biller init logic from lock_screen.dart:
  /// Fetches user context, auto-selects if one biller, or shows sheet.
  Future<void> _handleBillerInit() async {
    setState(() => _isInitializingBiller = true);
    try {
      final billerBloc = context.read<BillerBloc>();
      billerBloc.add(GetUserContext());

      final state = await billerBloc.stream.firstWhere(
        (s) => s is UserContextLoaded || s is UserContextError,
      );

      if (state is UserContextError) throw Exception(state.message);

      final contextData = (state as UserContextLoaded).response.data;
      final storage = getIt<StorageService>();
      await storage.setString('user_context', jsonEncode(contextData));

      if (!mounted) return;

      if (contextData.allowedBillers.length > 1) {
        setState(() => _isInitializingBiller = false);
        BillerSelectorSheet.show(
          context,
          allowedBillers: contextData.allowedBillers,
          currentActiveBiller: contextData.activeBiller,
          isDismissible: false,
        );
      } else {
        // Auto-select the single biller and go to dashboard
        if (contextData.allowedBillers.isNotEmpty) {
          final biller = contextData.allowedBillers.first;
          billerBloc.add(SetActiveBiller(SetActiveBillerRequest(billerName: biller.name)));
          await billerBloc.stream.firstWhere(
            (s) => s is SetActiveBillerSuccess || s is SetActiveBillerError,
          );
          billerBloc.add(GetBillerDetails(GetBillerDetailsRequest(billerName: biller.name)));
          final detailState = await billerBloc.stream.firstWhere(
            (s) => s is BillerDetailsLoaded || s is BillerDetailsError,
          );
          await storage.setString('active_biller', jsonEncode(biller.toJson()));
          if (detailState is BillerDetailsLoaded) {
            await storage.setString(
              'active_biller_details',
              jsonEncode(detailState.response.data.toJson()),
            );
          }
        }
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializingBiller = false);
        // Fallback — still go to dashboard even if biller init fails
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.orange, width: 1),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: AppColors.orange,
              size: 28,
            ),
          ),
        ),
      ),
      body: _isInitializingBiller
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Setting up your workspace...'),
                ],
              ),
            )
          : BlocProvider(
              create: (context) => getIt<LoginBloc>(),
              child: BlocConsumer<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state is LoginUserSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Verification successful'),
                      ),
                    );

                    if (widget.title == "reset") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => SetPasswordPage(email: widget.email ?? '')),
                      );
                    } else {
                      final storage = getIt<StorageService>();
                      storage.getBool('is_seeded').then((isSeeded) {
                        if (!context.mounted) return;
                        if (isSeeded == true) {
                          _handleBillerInit();
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BussinessTypePage(showBackButton: false),
                            ),
                          );
                        }
                      });
                    }
                  } else if (state is VerifyEmailCodeFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error)),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is VerifyEmailCodeLoading;
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: h * 0.06),
                                SvgPicture.asset(
                                  "assets/svgs/maiLogo.svg",
                                  height: 70,
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  "Verification",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "We sent a code to ${widget.email ?? 'your email'}. Enter the code to proceed",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0xFF757575)),
                                ),
                                const SizedBox(height: 48),
                                OtpForm(
                                  title: widget.title,
                                  email: widget.email,
                                  isLoading: isLoading,
                                ),
                                const SizedBox(height: 16),
                                ResendCodeWidget(email: widget.email),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.03,
                                ),
                                if (widget.showBackLogin)
                                  GestureDetector(
                                    onTap: () => {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context2) => SignInScreen(),
                                        ),
                                      ),
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_back, color: AppColors.red),
                                        SizedBox(width: 4),
                                        Text(
                                          "Back to Login",
                                          style: TextStyle(
                                            color: AppColors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
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

class ResendCodeWidget extends StatefulWidget {
  final String? email;
  const ResendCodeWidget({super.key, this.email});

  @override
  State<ResendCodeWidget> createState() => _ResendCodeWidgetState();
}

class _ResendCodeWidgetState extends State<ResendCodeWidget> {
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _secondsRemaining = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _resendCode() {
    if (_canResend && widget.email != null) {
      context.read<LoginBloc>().add(SendOtp(email: widget.email!));
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Didn't receive the code?"),
        SizedBox(width: 4),
        GestureDetector(
          onTap: _canResend ? _resendCode : null,
          child: Text(
            _canResend ? "Resend" : "Resend in ${_secondsRemaining}s",
            style: TextStyle(
              color: _canResend ? AppColors.red : Color(0xFF757575),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(12)),
);

class OtpForm extends StatefulWidget {
  final String title;
  final String? email;
  final bool isLoading;
  const OtpForm({
    super.key,
    required this.title,
    this.email,
    this.isLoading = false,
  });

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  // Use list to store individual digits
  final List<String> _otp = List.filled(6, "");
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.length > 1) {
      // Handle paste
      _handlePaste(value);
      return;
    }

    setState(() {
      if (value.isNotEmpty) {
        _otp[index] = value;
        if (index < 5) {
          _focusNodes[index + 1].requestFocus();
        } else {
          _focusNodes[index].unfocus();
        }
      } else {
        _otp[index] = "";
        if (index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      }
    });
  }

  void _handlePaste(String value) {
    if (value.length > 6) {
      value = value.substring(0, 6);
    }

    // Only digits
    if (!RegExp(r'^\d+$').hasMatch(value)) return;

    setState(() {
      for (int i = 0; i < value.length; i++) {
        if (i < 6) {
          _otp[i] = value[i];
          _controllers[i].text = value[i];
        }
      }

      // Focus logic after paste
      if (value.length < 6) {
        _focusNodes[value.length].requestFocus();
      } else {
        _focusNodes[5].unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isComplete = _otp.every((digit) => digit.isNotEmpty);

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  height: 80, // Large height
                  width: 48, // Reduced width to fix overflow
                  child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (event) {
                      if (event is KeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.backspace &&
                            _controllers[index].text.isEmpty &&
                            index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      }
                    },
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      onChanged: (value) => _onCodeChanged(value, index),
                      textInputAction: index == 5
                          ? TextInputAction.done
                          : TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24, // Increased font size
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        hintText: "-",
                        hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                        filled: true,
                        fillColor: Colors.grey[50], // Light background
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Less rounded, more square-ish
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (widget.isLoading || !isComplete)
                  ? null
                  : () {
                      String otpCode = _otp.join();
                      if (widget.email != null) {
                        context.read<LoginBloc>().add(
                          VerifyEmailCode(email: widget.email!, code: otpCode),
                        );
                      } else {
                        // fallback or error
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Email not found")),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                disabledBackgroundColor: AppColors.blue.withAlpha(
                  50,
                ), // Visual disabled state
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: (widget.isLoading)
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
