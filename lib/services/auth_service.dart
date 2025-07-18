import 'mock_firebase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final MockAuthService _mockService = MockAuthService();

  // Get current user
  MockUser? get currentUser => _mockService.currentUser;

  // Auth state stream
  Stream<MockUser?> get authStateChanges => _mockService.authStateChanges;

  // Sign in with Google (using mock service)
  Future<MockUser?> signInWithGoogle() async {
    try {
      return await _mockService.signInWithGoogle();
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Update username
  Future<bool> updateUsername(String username) async {
    try {
      return await _mockService.updateUsername(username);
    } catch (e) {
      print('Error updating username: $e');
      return false;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      return await _mockService.getUserData();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _mockService.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}