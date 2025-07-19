import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final addresses = List<Map<String, dynamic>>.from(userDoc.data()?['addresses'] ?? []);
    for (int i = 0; i < addresses.length; i++) {
      addresses[i]['isDefault'] = (i == addressIndex);
    }
    
    await _firestore.collection('users').doc(userId).update({
      'addresses': addresses,
    });
  }

  Future<String> createOrder({
    required String userId,
    required Map<String, dynamic> deliveryAddress,
    required List<MapEntry<Product, int>> items,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    try {
      print('🔥 FIRESTORE: Starting order creation...');
      print('🔥 FIRESTORE: User ID: $userId');
      print('🔥 FIRESTORE: Payment method: $paymentMethod');
      print('🔥 FIRESTORE: Total amount: $totalAmount');
      print('🔥 FIRESTORE: Items count: ${items.length}');
      
      // Convert items to match your exact schema
      final orderItems = items.map((entry) => {
        'price': entry.key.price,
        'productId': entry.key.id,
        'productName': entry.key.name,
        'quantity': entry.value,
      }).toList();

      print('🔥 FIRESTORE: Order items formatted: $orderItems');
      final deliveryAddressFormatted = {
        'city': deliveryAddress['city'] ?? 'Unknown',
        'state': deliveryAddress['state'] ?? 'Unknown', 
        'street': deliveryAddress['address'] ?? deliveryAddress['street'] ?? '',
        'zipCode': deliveryAddress['zipCode'] ?? '00000',
      };

      print('🔥 FIRESTORE: Delivery address formatted: $deliveryAddressFormatted');
      final orderData = {
        'deliveryAddress': deliveryAddressFormatted,
        'items': orderItems,
        'locationId': 'downtown_store',
        'orderDate': FieldValue.serverTimestamp(),
        'paymentMethod': paymentMethod,
        'status': 'pending',
        'totalAmount': totalAmount,
        'userId': userId,
      };

      print('🔥 FIRESTORE: Final order data: $orderData');
      print('🔥 FIRESTORE: Attempting to write to Firestore orders collection...');
      print('🔥 FIRESTORE: Using .add() method to create NEW DOCUMENT with AUTO-GENERATED ID');
      final orderRef = await _firestore.collection('orders').add(orderData);
      
      print('🔥 FIRESTORE: ✅ NEW ORDER DOCUMENT CREATED SUCCESSFULLY!');
      print('🔥 FIRESTORE: 📄 NEW Document ID: ${orderRef.id}');
      print('🔥 FIRESTORE: 📍 Document path: orders/${orderRef.id}');
      print('🔥 FIRESTORE: 🎯 Check Firebase Console at: orders/${orderRef.id}');
      
      return orderRef.id;
    } catch (e) {
      print('🔥 FIRESTORE: ❌ Error creating order: $e');
      print('🔥 FIRESTORE: Error type: ${e.runtimeType}');
      print('🔥 FIRESTORE: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<DocumentSnapshot>> getUserOrders(String userId) async {
    final querySnapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .get();
    
    return querySnapshot.docs;
  }
  Future<void> saveUserAddressAndMobile({
    required String userId,
    required String name,
    required String mobile,
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required String paymentMethod,
    bool isDefault = false,
  }) async {
    try {
      print('Saving address for user: $userId');
      
      final addressData = {
        'street': street,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'paymentMethod': paymentMethod,
        'isDefault': isDefault,
      };
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        final currentData = userDoc.data() as Map<String, dynamic>;
        final currentAddresses = List<Map<String, dynamic>>.from(currentData['addresses'] ?? []);
        bool addressExists = currentAddresses.any((addr) => 
          addr['street'] == street && 
          addr['city'] == city && 
          addr['zipCode'] == zipCode
        );
        
        if (!addressExists) {
          if (currentAddresses.isEmpty) {
            addressData['isDefault'] = true;
          }
          await _firestore.collection('users').doc(userId).update({
            'addresses': FieldValue.arrayUnion([addressData]),
          });
          
          print('Address saved successfully: $addressData');
        } else {
          print('Address already exists, skipping save');
        }
      }
    } catch (e) {
      print('Error saving user address: $e');
      rethrow;
    }
  }

  Future<DocumentSnapshot> getUserData(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }
}