import 'package:authentication/pages/singup_page.dart';
import 'package:authentication/wrapper.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  @override
  void initState() {
    super.initState();
    sendEmailVerification();
  }

  Future<void> sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user
          .sendEmailVerification()
          .then((value) {
            Get.snackbar(
              "Email Verification",
              "email verification link sent to ${user.email}",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.blue,
              colorText: Colors.white,
            );
          })
          .catchError((error) {
            Get.snackbar(
              "Error",
              "Failed to send verification email: $error",
              snackPosition: SnackPosition.BOTTOM,
            );
          });
    }
  }

  Future<void> reload() async {
    await FirebaseAuth.instance.currentUser
        ?.reload()
        .then((value) => Get.offAll(() => Wrapper()))
        .catchError((error) {
          Get.snackbar(
            "Error",
            "Failed to reload user: $error",
            snackPosition: SnackPosition.BOTTOM,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Email Verification"),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () {
            Get.offAll(() => SignupPage()); // Navigate back to Wrapper
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60),
              Icon(Icons.email_outlined, size: 80, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                'Email Verification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              // Text(
              //   'Please verify your email address to continue.',
              //   style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              //   textAlign: TextAlign.center,
              // ),
              Text(
                'We have sent a verification link to ${FirebaseAuth.instance.currentUser?.email}. plese check your inbox. and click on the link to verify your email. and then click on the reload button.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: reload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Reload'),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  sendEmailVerification();
                },
                child: Text('Resend Verification Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
