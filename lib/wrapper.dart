import 'package:authentication/pages/email_verification_page.dart';
import 'package:authentication/pages/home_page.dart';
import 'package:authentication/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool _isPhoneAuth = false;

  @override
  void initState() {
    _getAuthenticationStatus();
    super.initState();
  }

  Future<void> _getAuthenticationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPhoneAuth = prefs.getBool('isPhoneAuth') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (snapshot.hasData) {
              if (_isPhoneAuth) {
                return HomePage(); // Navigate to Home Page if phone authentication is used
              } else {
                if (user!.emailVerified) {
                  return HomePage(); // Navigate to Home Page if email is verified
                } else {
                  // Navigate to Email Verification Page if email is not verified
                  if (user.email != null) {
                    return EmailVerificationPage();
                  } else {
                    // If user email is null, redirect to Signup Page
                    return LoginPage();
                  }
                } // Navigate to Login Page
              }
            } else {
              return LoginPage();
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
