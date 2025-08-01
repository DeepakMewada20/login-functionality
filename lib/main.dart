import 'package:authentication/controlers/phone_number_login_controller.dart';
import 'package:authentication/controlers/google_sing_in_controler.dart';
import 'package:authentication/pages/forgot_password_page.dart';
import 'package:authentication/pages/home_page.dart';
import 'package:authentication/pages/login_page.dart';
import 'package:authentication/pages/otp_verifecation_page.dart';
import 'package:authentication/pages/singup_page.dart';
import 'package:authentication/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(GoogleSingInControler()); // Initialize the Google Sign-In controller
  Get.put(PhoneNumberLoginController());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth Pages',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/otp-verification': (context) => OtpVerificationPage(),
        '/home': (context) => HomePage(),
      },
      home: Wrapper(),
    );
  }
}
