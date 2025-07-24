import 'dart:async';

import 'package:authentication/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSingInControler extends GetxController {
  static GoogleSingInControler instence = Get.find();
  RxBool isLoading = false.obs;
  //Rx<User?> _currentUser = Rx<User?>(FirebaseAuth.instance.currentUser);
  GoogleSignIn googleSingIn = GoogleSignIn.instance;

  // Method to handle Google Sign-In
  Future<void> googleSignIn() async {
    //isLoading.value = true;
    GoogleSignInAccount? user;
    // Initialize Google Sign-In with your client ID (must be called before sign-in)
    unawaited(
      googleSingIn.initialize(
        clientId:
            '403819429629-c3rnkhtr68f5oe4dsggi037i82c0rgcb.apps.googleusercontent.com',
      ),
    );

    try {
      // 3. Try lightweight auth (may show UI on some platforms)
      //user = await googleSingIn.attemptLightweightAuthentication();

      user ??= await googleSingIn.authenticate();

      final GoogleSignInAuthentication googleAuth = user.authentication;

      // Create a new credential using the Google authentication token
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      await FirebaseAuth.instance.signInWithCredential(credential).then((
        UserCredential userCredential,
      ) {
        // Handle successful sign-in
        if (userCredential.user != null) {
          // Get the current user
          // _currentUser.value = userCredential.user;
          // Navigate to Wrapper or any other page
          Get.offAll(() => Wrapper());
        } else {
          _errorSnackbar('Sign-In Error', 'User is null after sign-in.');
        }
      });
      // If user is null, sign-in was cancelled
      // If user is not null, proceed with Firebase sign-in
    } on FirebaseAuthException catch (e) {
      _errorSnackbar(
        'Error',
        'Google Sign-In failed: ${_getErrormassage(e.code)}',
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        _errorSnackbar('google singIn', "Canceled");
      }
    } catch (e) {
      _errorSnackbar(
        'Error',
        "An unknown error occurred. Please try again later.${e.toString()}",
      );
    } finally {
      //isLoading.value = false;
    }
  }

  Future<void> googleSingOut() async {
    try {
      // Sign out from Google
      await FirebaseAuth.instance.signOut();
      await googleSingIn.disconnect();
    } catch (e) {
      _errorSnackbar(
        'Sign-Out Error',
        'Failed to sign out from : ${e.toString()}',
      );
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //Get.offAll(() => Wrapper()); // Navigate to Wrapper
    } on FirebaseAuthException catch (e) {
      _errorSnackbar('Login failed', _getErrormassage(e.code));
    } catch (e) {
      _errorSnackbar(
        'Login Failed',
        'An unknown error occurred. Please try again later.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}

dynamic _errorSnackbar(String title, String message) {
  // Close all existing snackbars before showing a new one
  // This prevents multiple snackbars from stacking up
  // and ensures that the user sees the most recent error message.
  Get.closeCurrentSnackbar();

  return Get.snackbar(
    title,
    message,
    // snackPosition: SnackPosition.BOTTOM,
    // backgroundColor: Colors.red,
    // colorText: Colors.white,
  );
}

String _getErrormassage(String errorCode) {
  switch (errorCode) {
    case 'account-exists-with-different-credential':
      return 'An account already exists with the same email address but different sign-in credentials. Please sign in using a different method.';
    case 'invalid-credential':
      return 'The provided credential is invalid.';
    case 'operation-not-allowed':
      return 'Google Sign-In is not enabled for this project.';
    case 'user-disabled':
      return 'This user has been disabled.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait.';
    case 'network-request-failed':
      return 'Please check your internet connection.';
    case 'user-not-found':
      return 'user-not-found';
    default:
      return 'An unknown error occurred. Please try again later.';
  }
}
