import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/services.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          print('User is signed in: ${snapshot.data!.email}');
          return FutureBuilder<DocumentSnapshot?>(
            future: AuthService().getUserData(),
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (userDataSnapshot.hasError) {
                print('Error getting user data: ${userDataSnapshot.error}');
                return const AuthScreen();
              }

              Map<String, dynamic>? userData;
              try {
                userData = userDataSnapshot.data?.data() as Map<String, dynamic>?;
                print('User data retrieved: $userData');
              } catch (e) {
                print('Error parsing user data: $e');
                userData = null;
              }
              if (userData == null || userData['username'] == null) {
                print('User needs username setup');
                return const AuthScreen();
              }
              print('User is fully set up, showing home screen');
              return const HomeScreen();
            },
          );
        }
        return const AuthScreen();
      },
    );
  }
}