import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser {
    final user = _auth.currentUser;
    print('Current user: ${user?.email ?? 'null'}');
    return user;
  }
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In...');
      
      // For web, use Firebase Auth directly with Google provider
      if (kIsWeb) {
        print('Using web-specific Google Sign-In');
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        final userCredential = await _auth.signInWithPopup(googleProvider);
        print('Web Google Sign-In successful: ${userCredential.user?.email}');
        
        if (userCredential.user != null) {
          try {
            await _createOrUpdateUser(userCredential.user!);
            print('User document created/updated in Firestore');
          } catch (firestoreError) {
            print('Error creating/updating user in Firestore: $firestoreError');
          }
        }
        
        return userCredential;
      } else {
        // For mobile platforms, use the existing Google Sign-In flow
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          print('Google Sign-In was cancelled by user');
          return null;
        }

        print('Google user obtained: ${googleUser.email}');
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        print('Google auth tokens obtained');
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        print('Firebase credential created');
        final userCredential = await _auth.signInWithCredential(credential);
        print('Firebase sign-in successful: ${userCredential.user?.email}');
        if (userCredential.user != null) {
          try {
            await _createOrUpdateUser(userCredential.user!);
            print('User document created/updated in Firestore');
          } catch (firestoreError) {
            print('Error creating/updating user in Firestore: $firestoreError');
          }
        }

        return userCredential;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      print('Error type: ${e.runtimeType}');
      if (e.toString().contains('network_error')) {
        print('Network error - check internet connection');
      } else if (e.toString().contains('sign_in_failed')) {
        print('Sign-in failed - check Firebase configuration');
      }
      return null;
    }
  }
  Future<void> _createOrUpdateUser(User user) async {
    try {
      print('Creating/updating user: ${user.uid}');
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
      print('User document exists: ${docSnapshot.exists}');
      
      if (docSnapshot.exists) {
        await userDoc.update({
          'displayName': user.displayName ?? 'Unknown',
          'email': user.email ?? 'unknown@email.com',
        });
        print('User document updated');
      } else {
        final userData = {
          'displayName': user.displayName ?? 'Unknown',
          'email': user.email ?? 'unknown@email.com',
          'username': _generateUsername(user.displayName ?? 'user'),
          'createdAt': FieldValue.serverTimestamp(),
          'addresses': <Map<String, dynamic>>[],
        };
        
        print('Creating user document with data: $userData');
        await userDoc.set(userData);
        print('User document created successfully');
      }
    } catch (e) {
      print('Error in _createOrUpdateUser: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
  }
  String _generateUsername(String displayName) {
    final username = displayName.toLowerCase().replaceAll(' ', '_');
    return '${username}_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  Future<bool> createUserDocumentManually() async {
    if (currentUser == null) return false;
    
    try {
      print('Manually creating user document for: ${currentUser!.uid}');
      final userDoc = _firestore.collection('users').doc(currentUser!.uid);
      
      final userData = {
        'displayName': currentUser!.displayName ?? 'Unknown User',
        'email': currentUser!.email ?? 'unknown@email.com',
        'username': _generateUsername(currentUser!.displayName ?? 'user'),
        'createdAt': FieldValue.serverTimestamp(),
        'addresses': <Map<String, dynamic>>[],
      };
      
      await userDoc.set(userData);
      print('User document created manually: $userData');
      return true;
    } catch (e) {
      print('Error creating user document manually: $e');
      return false;
    }
  }
  Future<bool> updateUsername(String username) async {
    if (currentUser == null) return false;
    
    try {
      await createUserDocumentManually();
      
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'username': username,
      });
      return true;
    } catch (e) {
      print('Error updating username: $e');
      return false;
    }
  }

  Future<DocumentSnapshot?> getUserData() async {
    if (currentUser == null) return null;
    
    try {
      return await _firestore.collection('users').doc(currentUser!.uid).get();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}