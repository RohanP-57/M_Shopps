import 'package:flutter/material.dart';
import '../../models/cart.dart';
import '../../screens/order_confirmation_screen.dart';
import '../firebase/firestore_service.dart';
import '../firebase/auth_service.dart';

class CODPaymentService {
  static CODPaymentService? _instance;
  static CODPaymentService get instance => _instance ??= CODPaymentService._();
  
  CODPaymentService._();

  Future<void> processPayment(BuildContext context, {
    required String name,
    required String mobile,
    required String address,
  }) async {
    final confirmed = await _showCODDialog(context);
    if (confirmed == true) {
      await _navigateToOrderConfirmation(
        context, 
        'Cash on Delivery', 
        'Pending',
        name: name, 
        mobile: mobile, 
        address: address
      );
    }
  }

  Future<bool?> _showCODDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.money, color: Colors.green),
              SizedBox(width: 8),
              Text('Cash on Delivery'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.delivery_dining,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                'Pay when your order is delivered',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Amount to pay: ₹${Cart.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please keep exact change ready',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm Order'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToOrderConfirmation(
    BuildContext context,
    String paymentMethod,
    String orderStatus, {
    required String name,
    required String mobile,
    required String address,
  }) async {
    final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    try {
      final currentUser = AuthService().currentUser;
      
      if (currentUser != null) {
        final addressParts = address.split(', ');
        final street = addressParts.isNotEmpty ? addressParts[0] : address;
        final city = addressParts.length > 2 ? addressParts[2] : 'Unknown';
        final state = addressParts.length > 3 ? addressParts[3] : 'Unknown';
        final zipCode = addressParts.isNotEmpty ? 
          addressParts.last.replaceAll(RegExp(r'[^0-9]'), '') : '00000';
        
        await FirestoreService().saveUserAddressAndMobile(
          userId: currentUser.uid,
          name: name,
          mobile: mobile,
          street: street,
          city: city,
          state: state,
          zipCode: zipCode.isNotEmpty ? zipCode : '00000',
          paymentMethod: paymentMethod,
        );

        final deliveryAddress = {
          'name': name,
          'mobile': mobile,
          'address': address,
          'city': city,
          'state': state,
          'zipCode': zipCode.isNotEmpty ? zipCode : '00000',
        };
        
        await FirestoreService().createOrder(
          userId: currentUser.uid,
          deliveryAddress: deliveryAddress,
          items: Cart.items.entries.toList(),
          totalAmount: Cart.totalPrice,
          paymentMethod: paymentMethod,
        );
      }
    } catch (e) {
      // Handle error silently
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(
          name: name,
          mobile: mobile,
          address: address,
          orderId: orderId,
          paymentMethod: paymentMethod,
          orderStatus: orderStatus,
          totalAmount: Cart.totalPrice,
          cartItems: Cart.items.entries.toList(),
        ),
      ),
    );
  }
}