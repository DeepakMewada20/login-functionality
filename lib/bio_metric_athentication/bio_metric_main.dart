import 'package:authentication/bio_metric_athentication/biometric_login_page.dart';
import 'package:authentication/bio_metric_athentication/biometric_setup_age.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biometric Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BiometricSetupPage(),
      routes: {
        '/biometric-setup': (context) => BiometricSetupPage(),
        '/biometric-login': (context) => BiometricLoginPage(),
      },
    );
  }
}
