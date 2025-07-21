import 'package:authentication/pages/forgot_password_page.dart';
import 'package:authentication/pages/home_page.dart';
import 'package:authentication/pages/login_page.dart';
import 'package:authentication/pages/verifecation_page.dart';
import 'package:authentication/pages/singup_page.dart';
import 'package:authentication/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Auth Pages',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/otp-verification': (context) => VerificationPage(),
        '/home': (context) => HomePage(),
      },
      home: Wrapper(),
    );
  }
}
