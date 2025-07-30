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
    return user;
  }
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // For web, use Firebase Auth directly with Google provider
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        final userCredential = await _auth.signInWithPopup(googleProvider);
        
        if (userCredential.user != null) {
          try {
            await _createOrUpdateUser(userCredential.user!);
          } catch (firestoreError) {
            // Handle error silently
          }
        }
        
        return userCredential;
      } else {
        // For mobile platforms, use the existing Google Sign-In flow
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return null;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          try {
            await _createOrUpdateUser(userCredential.user!);
          } catch (firestoreError) {
            // Handle error silently
          }
        }

        return userCredential;
      }
    } catch (e) {
      return null;
    }
  }
  Future<void> _createOrUpdateUser(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
      
      if (docSnapshot.exists) {
        await userDoc.update({
          'displayName': user.displayName ?? 'Unknown',
          'email': user.email ?? 'unknown@email.com',
        });
      } else {
        final userData = {
          'displayName': user.displayName ?? 'Unknown',
          'email': user.email ?? 'unknown@email.com',
          'username': _generateUsername(user.displayName ?? 'user'),
          'createdAt': FieldValue.serverTimestamp(),
          'addresses': <Map<String, dynamic>>[],
        };
        
        await userDoc.set(userData);
      }
    } catch (e) {
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
      final userDoc = _firestore.collection('users').doc(currentUser!.uid);
      
      final userData = {
        'displayName': currentUser!.displayName ?? 'Unknown User',
        'email': currentUser!.email ?? 'unknown@email.com',
        'username': _generateUsername(currentUser!.displayName ?? 'user'),
        'createdAt': FieldValue.serverTimestamp(),
        'addresses': <Map<String, dynamic>>[],
      };
      
      await userDoc.set(userData);
      return true;
    } catch (e) {
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
      return false;
    }
  }

  Future<DocumentSnapshot?> getUserData() async {
    if (currentUser == null) return null;
    
    try {
      return await _firestore.collection('users').doc(currentUser!.uid).get();
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}