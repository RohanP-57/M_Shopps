import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser {
    final user = _auth.currentUser;
    print('Current user: ${user?.email ?? 'null'}');
    return user;
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In...');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In was cancelled by user');
        return null;
      }

      print('Google user obtained: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('Google auth tokens obtained');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Firebase credential created');

      // Sign in with credential
      final userCredential = await _auth.signInWithCredential(credential);
      print('Firebase sign-in successful: ${userCredential.user?.email}');

      // Create/update user document in Firestore
      if (userCredential.user != null) {
        try {
          await _createOrUpdateUser(userCredential.user!);
          print('User document created/updated in Firestore');
        } catch (firestoreError) {
          print('Error creating/updating user in Firestore: $firestoreError');
          // Continue even if Firestore fails - user is still authenticated
        }
      }

      return userCredential;
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

  // Create or update user in Firestore
  Future<void> _createOrUpdateUser(User user) async {
    try {
      print('Creating/updating user: ${user.uid}');
      final userDoc = _firestore.collection('users').doc(user.uid);
      
      // Check if user exists
      final docSnapshot = await userDoc.get();
      print('User document exists: ${docSnapshot.exists}');
      
      if (docSnapshot.exists) {
        // Update existing user
        await userDoc.update({
          'displayName': user.displayName ?? 'Unknown',
          'email': user.email ?? 'unknown@email.com',
        });
        print('User document updated');
      } else {
        // Create new user with your exact schema structure
        final userData = {
          'displayName': user.displayName ?? 'Unknown',
          'email': user.email ?? 'unknown@email.com',
          'username': _generateUsername(user.displayName ?? 'user'),
          'createdAt': FieldValue.serverTimestamp(),
          'addresses': <Map<String, dynamic>>[], // Empty list of addresses
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

  // Generate username from display name
  String _generateUsername(String displayName) {
    final username = displayName.toLowerCase().replaceAll(' ', '_');
    return '${username}_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  // Manually create user document for already authenticated user
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

  // Update username
  Future<bool> updateUsername(String username) async {
    if (currentUser == null) return false;
    
    try {
      // First ensure user document exists
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

  // Get user data
  Future<DocumentSnapshot?> getUserData() async {
    if (currentUser == null) return null;
    
    try {
      return await _firestore.collection('users').doc(currentUser!.uid).get();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}