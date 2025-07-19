import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../screens/order_confirmation_screen.dart';
import 'firestore_service.dart';
import 'auth_service.dart';

class PaymentService {
  static PaymentService? _instance;
  static PaymentService get instance => _instance ??= PaymentService._();
  
  PaymentService._();

  Future<void> showUPIPayment(BuildContext context, {
    required String name,
    required String mobile,
    required String address,
  }) async {
    final confirmed = await _showUPIDialog(context);
    if (confirmed == true) {
      await _processUPIPayment(context, name: name, mobile: mobile, address: address);
    }
  }
  Future<void> showCODPayment(BuildContext context, {
    required String name,
    required String mobile,
    required String address,
  }) async {
    final confirmed = await _showCODDialog(context);
    if (confirmed == true) {
      await _navigateToOrderConfirmation(context, 'Cash on Delivery', 'Pending', 
        name: name, mobile: mobile, address: address);
    }
  }

  Future<void> showRazorpayPayment(BuildContext context, {
    required String name,
    required String mobile,
    required String address,
  }) async {
    final confirmed = await _showRazorpayDialog(context);
    if (confirmed == true) {
      await _processRazorpayPayment(context, name: name, mobile: mobile, address: address);
    }
  }

  Future<bool?> _showUPIDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.payment, color: Color(0xFFFF9900)),
              SizedBox(width: 8),
              Text('UPI Payment'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Scan QR Code or Pay via UPI ID',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Icon(
                          Icons.qr_code,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'UPI ID: merchant@paytm',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Amount: ₹${Cart.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '(Simulated Payment - Click Confirm to proceed)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm Payment'),
            ),
          ],
        );
      },
    );
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

  Future<bool?> _showRazorpayDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.credit_card, color: Colors.blue),
              SizedBox(width: 8),
              Text('Razorpay Payment'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.credit_card,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Secure Payment Gateway',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Amount: ₹${Cart.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '(Test Mode - Payment will be simulated)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
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
              child: const Text('Pay Now'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processUPIPayment(BuildContext context, {
    required String name,
    required String mobile,
    required String address,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9900)),
                ),
                SizedBox(height: 16),
                Text('Processing UPI Payment...'),
              ],
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 3));
    if (context.mounted) {
      Navigator.of(context).pop();

      await _navigateToOrderConfirmation(context, 'UPI Payment', 'Paid',
        name: name, mobile: mobile, address: address);
    }
  }

  Future<void> _processRazorpayPayment(BuildContext context, {
    required String name,
    required String mobile,
    required String address,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 16),
                Text('Processing Razorpay Payment...'),
              ],
            ),
          ),
        );
      },
    );
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      Navigator.of(context).pop();
      await _navigateToOrderConfirmation(context, 'Razorpay', 'Paid',
        name: name, mobile: mobile, address: address);
    }
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
      print('💳 PAYMENT: Starting order save process...');
      final currentUser = AuthService().currentUser;
      print('💳 PAYMENT: Current user: ${currentUser?.uid ?? 'NULL'}');
      
      if (currentUser != null) {
        print('💳 PAYMENT: User authenticated, proceeding with order save...');
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

        print('💳 PAYMENT: About to call FirestoreService().createOrder()...');
        print('💳 PAYMENT: Cart items count: ${Cart.items.entries.length}');
        print('💳 PAYMENT: Total amount: ${Cart.totalPrice}');
        print('💳 PAYMENT: Payment method: $paymentMethod');
        
        final savedOrderId = await FirestoreService().createOrder(
          userId: currentUser.uid,
          deliveryAddress: deliveryAddress,
          items: Cart.items.entries.toList(),
          totalAmount: Cart.totalPrice,
          paymentMethod: paymentMethod,
        );

        print('💳 PAYMENT: ✅ Order saved to Firebase with ID: $savedOrderId');
        print('User address and mobile saved to users collection');
      }
    } catch (e) {
      print('Error saving order to Firebase: $e');
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