import 'package:authentication/pages/phone_opt_verification_page.dart';
import 'package:authentication/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class PhoneNumberLoginController extends GetxController {
  static PhoneNumberLoginController instance = Get.find();
  RxBool isLoading = false.obs;
  String _verificationId = "";
  int? _resendToken;
  RxBool canResend = false.obs;
  RxInt resendTimer = 60.obs;

  // Method to handle phone number login
  Future<void> loginWithPhoneNumber({required String phoneNumber}) async {
    isLoading.value = true;
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 30),
        forceResendingToken: canResend.value ? _resendToken : null,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            // Automatically sign in the user
            await FirebaseAuth.instance.signInWithCredential(credential).then((
              value,
            ) {
              Get.snackbar('Success', 'Logged in successfully');
              // Navigate to home or main screen
              Get.offAll(() => Wrapper());
            });
          } catch (e) {
            Get.snackbar('Error', 'Failed to auto-login: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar('verification Failed', e.toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          Get.to(() => PhoneOTPPage(), arguments: phoneNumber);
          Get.snackbar(
            'Code Sent!!!!!!!!!!!',
            'A verification code has been sent to $phoneNumber',
          );
          isLoading.value = false;
          // Navigate to OTP verification screen
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          // Optionally handle timeout
          Get.snackbar('Timeout', 'Verification code retrieval timed out');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to login with phone number: $e');
    }
    // finally {
    //   isLoading.value = false;
    // }
  }

  Future<void> singInWithOTP(String otp) async {
    isLoading.value = true;
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential).then((
        value,
      ) {
        Get.snackbar('Success', 'Logged in successfully');
        // Navigate to home or main screen
        Get.offAll(() => Wrapper());
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in with OTP: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void startResendTimer() {
    canResend.value = false;
    resendTimer.value = 40; // Reset timer to 40 seconds
    _tick();
  }

  void _tick() {
    Future.delayed(Duration(seconds: 1), () {
      if (resendTimer.value > 0) {
        resendTimer--;
        _tick();
      } else {
        canResend.value = true;
      }
    });
  }
}
