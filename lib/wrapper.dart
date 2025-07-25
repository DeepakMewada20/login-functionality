import 'package:authentication/pages/email_verification_page.dart';
import 'package:authentication/pages/home_page.dart';
import 'package:authentication/pages/phone_login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (snapshot.hasData) {
              if (user!.emailVerified) {
                return HomePage(); // Navigate to Home Page if email is verified
              } else {
                // Navigate to Email Verification Page if email is not verified
                return EmailVerificationPage();
              } // Navigate to Login Page
            } else {
              return PhoneLoginPage();
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
