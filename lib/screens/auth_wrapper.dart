import 'package:flutter/material.dart';
import '../services/services.dart';
import '../services/mock_firebase_service.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MockUser?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is signed in, check if they have a username
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<Map<String, dynamic>?>(
            future: AuthService().getUserData(),
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final userData = userDataSnapshot.data;
              
              // If user doesn't have username, show auth screen for username setup
              if (userData == null || userData['username'] == null) {
                return const AuthScreen();
              }

              // User is fully set up, show home screen
              return const HomeScreen();
            },
          );
        }

        // User is not signed in, show auth screen
        return const AuthScreen();
      },
    );
  }
}