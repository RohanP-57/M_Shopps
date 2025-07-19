// Mock Firebase service for web compatibility
// This will be replaced with real Firebase when web compatibility is fixed

class MockUser {
  final String uid;
  final String? email;
  final String? displayName;

  MockUser({
    required this.uid,
    this.email,
    this.displayName,
  });
}

class MockAuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  MockUser? _currentUser;
  final List<Map<String, dynamic>> _users = [];
  final List<Map<String, dynamic>> _orders = [];

  // Get current user
  MockUser? get currentUser => _currentUser;

  // Auth state stream (simplified)
  Stream<MockUser?> get authStateChanges async* {
    yield _currentUser;
  }

  // Sign in with Google (mock)
  Future<MockUser?> signInWithGoogle() async {
    // Simulate Google sign-in
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = MockUser(
      uid: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@example.com',
      displayName: 'Mock User',
    );
    
    // Create user document
    await _createUserDocument(_currentUser!);
    
    return _currentUser;
  }

  // Create user document
  Future<void> _createUserDocument(MockUser user) async {
    final existingUser = _users.where((u) => u['uid'] == user.uid).firstOrNull;
    
    if (existingUser == null) {
      _users.add({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'username': null,
        'createdAt': DateTime.now(),
        'addresses': [],
      });
    }
  }

  // Update username
  Future<bool> updateUsername(String username) async {
    if (_currentUser == null) return false;
    
    final userIndex = _users.indexWhere((u) => u['uid'] == _currentUser!.uid);
    if (userIndex != -1) {
      _users[userIndex]['username'] = username;
      return true;
    }
    
    return false;
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    if (_currentUser == null) return null;
    
    return _users.where((u) => u['uid'] == _currentUser!.uid).firstOrNull;
  }

  // Sign out
  Future<void> signOut() async {
    _currentUser = null;
  }

  // Save order
  Future<String?> saveOrder({
    required List<dynamic> items,
    required double totalAmount,
    required Map<String, dynamic> deliveryAddress,
    required String locationId,
  }) async {
    if (_currentUser == null) return null;
    
    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
    
    _orders.add({
      'id': orderId,
      'userId': _currentUser!.uid,
      'items': items,
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'orderDate': DateTime.now(),
      'status': 'pending',
      'locationId': locationId,
    });
    
    return orderId;
  }

  // Get user orders
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    if (_currentUser == null) return [];
    
    return _orders.where((order) => order['userId'] == _currentUser!.uid).toList();
  }
}