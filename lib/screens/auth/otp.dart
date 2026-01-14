import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pos/screens/auth/login.dart';
import 'package:pos/screens/auth/set_new_password.dart';
import 'package:pos/screens/loading_message.dart';
import 'package:pos/utils/themes/app_colors.dart';

class OtpScreen extends StatelessWidget {
  final bool showBackLogin;
  final String title;
  const OtpScreen({super.key, required this.title, this.showBackLogin = false});

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: h * 0.06),
                  SvgPicture.asset("assets/svgs/maiLogo.svg", height: 70),
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
                  const Text(
                    "We sent a code to youremail@mail.com. Enter the code to proceed",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 48),
                  OtpForm(title: title,),
                  const SizedBox(height: 16),
                  ResendCodeWidget(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  if (showBackLogin)
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
  }
}

class ResendCodeWidget extends StatefulWidget {
  const ResendCodeWidget({super.key});

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
    if (_canResend) {
      // Add your resend code logic here
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

class OtpForm extends StatelessWidget {
  final String title;
  const OtpForm({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: SizedBox(
                  height: 64,
                  width: 64,
                  child: TextFormField(
                    onChanged: (pin) {
                      if (pin.isNotEmpty) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "0",
                      hintStyle: const TextStyle(color: Color(0xFF757575)),
                      border: authOutlineInputBorder,
                      enabledBorder: authOutlineInputBorder,
                      focusedBorder: authOutlineInputBorder.copyWith(
                        borderSide: const BorderSide(color: Color(0xFFFF7643)),
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
              onPressed: () {
                if (title == "reset") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SetPasswordPage()),
                  );
                }
                else if (title == "register") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoadingMessage()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
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