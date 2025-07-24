import 'package:authentication/controlers/google_sing_in_controler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> singout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page")),
      body: Center(
        child: Column(
          children: [
            Text(
              FirebaseAuth.instance.currentUser?.email ?? "User",
              style: TextStyle(fontSize: 20),
            ),
            Text("Welcome to the Home Page!"),
            ElevatedButton(onPressed: GoogleSingInControler.instence.googleSingOut, child: Text("Logout")),
          ],
        ),
      ),
    );
  }
}
