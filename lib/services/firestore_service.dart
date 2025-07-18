import '../models/cart.dart';
import 'mock_firebase_service.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final MockAuthService _mockService = MockAuthService();

  // Save order to Firestore (using mock service)
  Future<String?> saveOrder({
    required List<CartItem> items,
    required double totalAmount,
    required Map<String, dynamic> deliveryAddress,
    required String locationId,
  }) async {
    try {
      // Convert cart items to map
      final orderItems = items.map((item) => {
        'productId': item.product.id,
        'productName': item.product.name,
        'quantity': item.quantity,
        'price': item.product.price,
      }).toList();

      return await _mockService.saveOrder(
        items: orderItems,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress,
        locationId: locationId,
      );
    } catch (e) {
      print('Error saving order: $e');
      return null;
    }
  }

  // Get user orders (using mock service)
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      return await _mockService.getUserOrders();
    } catch (e) {
      print('Error getting user orders: $e');
      return [];
    }
  }

  // Update user address (using mock service)
  Future<bool> updateUserAddress(Map<String, dynamic> address) async {
    try {
      final userData = await _mockService.getUserData();
      if (userData == null) return false;

      // Add address to user data (mock implementation)
      final addresses = List<Map<String, dynamic>>.from(userData['addresses'] ?? []);
      addresses.add(address);
      
      // In a real implementation, this would update the user document
      // For now, we'll just return true to simulate success
      return true;
    } catch (e) {
      print('Error updating user address: $e');
      return false;
    }
  }

  // Get user addresses (using mock service)
  Future<List<Map<String, dynamic>>> getUserAddresses() async {
    try {
      final userData = await _mockService.getUserData();
      if (userData == null) return [];
      
      if (userData['addresses'] != null) {
        return List<Map<String, dynamic>>.from(userData['addresses']);
      }
      
      return [];
    } catch (e) {
      print('Error getting user addresses: $e');
      return [];
    }
  }
}