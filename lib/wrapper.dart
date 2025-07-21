import 'package:authentication/pages/home_page.dart';
import 'package:authentication/pages/login_page.dart';
import 'package:authentication/pages/verifecation_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    sendEmailVerification();
    super.initState();
  }

  Future<void> sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification().then((value) {
        Get.snackbar(
          "Email Verification",
          "email verification link sent to ${user.email}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      });
      //   .catchError((error) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text("Error sending verification email: $error")),
      //     );
      //   }
      //   );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              return LoginPage(); // Navigate to Login Page
            } else {
              if (user.emailVerified) {
                return HomePage(); // Navigate to Home Page if email is verified
              } else {
                return VerificationPage();
              }
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            ); // Show loading indicator
          }
        },
      ),
    );
  }
}
