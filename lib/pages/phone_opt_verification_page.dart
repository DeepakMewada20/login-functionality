import 'package:authentication/controlers/phone_number_login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:shimmer/shimmer.dart';

// Phone OTP Verification Page
class PhoneOTPPage extends StatefulWidget {
  PhoneOTPPage({super.key});
  @override
  _PhoneOTPPageState createState() => _PhoneOTPPageState();
  final phoneNumber = Get.arguments as String;
}

class _PhoneOTPPageState extends State<PhoneOTPPage>
    with TickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _animation;

  // int _resendTimer = 30;
  // bool _canResend = false;

  @override
  void initState() {
    super.initState();
    //Get.put(PhoneNumberLoginController());
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.forward();
    //PhoneNumberLoginController.instance.startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    // final String phoneNumber =
    //     ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _animation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.message_outlined,
                    size: 50,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 30),
                // Title
                Text(
                  'Verify Phone Number',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: 'Code sent to '),
                      TextSpan(
                        text: widget.phoneNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                // Pinput OTP Input
                Pinput(
                  controller: _pinController,
                  focusNode: _pinFocusNode,
                  length: 6,
                  defaultPinTheme: PinTheme(
                    width: 50,
                    height: 60,
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 50,
                    height: 60,
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 50,
                    height: 60,
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                  ),
                  errorPinTheme: PinTheme(
                    width: 50,
                    height: 60,
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                  ),
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  cursor: Container(width: 2, height: 24, color: Colors.blue),
                  // onCompleted: (pin) {
                  //   print("#############################################$pin");
                  //   _verifyOTP(pin);
                  // },
                  onChanged: (value) {
                    // Clear any previous error state
                    if (_pinController.text.length < 6) {
                      setState(() {});
                    }
                  },
                ),
                SizedBox(height: 40),
                // Verify Button
                ElevatedButton(
                  onPressed: () => _verifyOTP(_pinController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),

                  child: Obx(
                    () => PhoneNumberLoginController.instance.isLoading.value
                        ? Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: Colors.grey[400]!,
                            child: Text(
                              'Verify & Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Text(
                            'Verify & Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 30),
                // Resend OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Obx(
                      () => PhoneNumberLoginController.instance.canResend.value
                          ? TextButton(
                              onPressed: _resendOTP,
                              child: Text(
                                'Resend',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Text(
                              'Resend in ${PhoneNumberLoginController.instance.resendTimer.value}s',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Change Phone Number
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Change Phone Number',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _verifyOTP(String otp) {
    if (otp.length == 6) {
      // Handle OTP verification
      PhoneNumberLoginController.instance.singInWithOTP(otp);
      // Clear the OTP input field
      _pinController.clear();
      _pinFocusNode.unfocus();
    } else {
      // Show error state in pinput
      _pinController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter complete OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resendOTP() {
    // PhoneNumberLoginController.instance.startResendTimer();
    // Clear OTP field
    PhoneNumberLoginController.instance.loginWithPhoneNumber(
      phoneNumber: widget.phoneNumber,
      isResend: true,
    );
    _pinController.clear();
    _pinFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }
}
