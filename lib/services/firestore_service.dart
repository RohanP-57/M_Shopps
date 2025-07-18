import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User methods
  Future<void> updateUserAddress({
    required String userId,
    required Map<String, dynamic> address,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'addresses': FieldValue.arrayUnion([address]),
    });
  }

  Future<void> setDefaultAddress({
    required String userId,
    required int addressIndex,
  }) async {
    // Get current addresses
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final addresses = List<Map<String, dynamic>>.from(userDoc.data()?['addresses'] ?? []);
    
    // Update isDefault flag
    for (int i = 0; i < addresses.length; i++) {
      addresses[i]['isDefault'] = (i == addressIndex);
    }
    
    // Update in Firestore
    await _firestore.collection('users').doc(userId).update({
      'addresses': addresses,
    });
  }

  // Order methods
  Future<String> createOrder({
    required String userId,
    required Map<String, dynamic> deliveryAddress,
    required List<MapEntry<Product, int>> items,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    // Convert items to match your exact schema
    final orderItems = items.map((entry) => {
      'productId': entry.key.id,
      'productName': entry.key.name,
      'price': entry.key.price,
      'quantity': entry.value,
    }).toList();

    // Convert deliveryAddress to match your schema
    final deliveryAddressFormatted = {
      'street': deliveryAddress['address'] ?? '',
      'city': deliveryAddress['city'] ?? 'Unknown',
      'state': deliveryAddress['state'] ?? 'Unknown',
      'zipCode': deliveryAddress['zipCode'] ?? '00000',
    };

    // Create order document with your exact schema
    final orderRef = await _firestore.collection('orders').add({
      'userId': userId,
      'deliveryAddress': deliveryAddressFormatted,
      'items': orderItems,
      'totalAmount': totalAmount,
      'status': 'pending',
      'orderDate': FieldValue.serverTimestamp(),
      'locationId': 'downtown_store',
    });

    return orderRef.id;
  }

  // Get user's orders
  Future<List<DocumentSnapshot>> getUserOrders(String userId) async {
    final querySnapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .get();
    
    return querySnapshot.docs;
  }

  // Get user data
  Future<DocumentSnapshot> getUserData(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }
}