import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/cart.dart';
import '../../screens/order_confirmation_screen.dart';
import '../firebase/firestore_service.dart';
import '../firebase/auth_service.dart';

class RazorpayPaymentService {
  static RazorpayPaymentService? _instance;
  static RazorpayPaymentService get instance => _instance ??= RazorpayPaymentService._();
  
  late Razorpay _razorpay;
  BuildContext? _currentContext;
  String? _currentName;
  String? _currentMobile;
  String? _currentAddress;
  
  RazorpayPaymentService._() {
    try {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      
      final apiKey = _getRazorpayApiKey();
    } catch (e) {
    }
  }
  
  void dispose() {
    _razorpay.clear();
  }

  String? _getRazorpayApiKey() {
    final key = dotenv.env['rzp_api'];
    if (key == null || key.isEmpty) {
      return 'rzp_test_msmoBeDjsPwMS1';
    }
    return key;
  }

  Future<void> processPayment(BuildContext context, {
    required String name,
    required String mobile,
    required String address,
  }) async {
    try {
      _currentContext = context;
      _currentName = name;
      _currentMobile = mobile;
      _currentAddress = address;
      
      await _openRazorpayCheckout();
    } catch (e) {
      _showError('Error starting Razorpay: $e');
    }
  }

  Future<void> _openRazorpayCheckout() async {

    if (_currentContext != null) {
      showDialog(
        context: _currentContext!,
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
                  Text('Initializing Razorpay...'),
                ],
              ),
            ),
          );
        },
      );
    }

    final razorpayKey = _getRazorpayApiKey();
    
    if (razorpayKey == null || razorpayKey.isEmpty) {
      if (_currentContext != null) Navigator.of(_currentContext!).pop();
      _showError('Razorpay API key not found. Please check configuration.');
      return;
    }
    


    final currentUser = AuthService().currentUser;
    final amount = (Cart.totalPrice * 100).toInt();
    final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';

    var options = {
      'key': razorpayKey,
      'amount': amount,
      'name': 'Mini Shopping App',
      'description': 'Payment for Order #${orderId.substring(orderId.length - 6)}',
      'prefill': {
        'contact': _currentMobile ?? '9999999999',
        'email': currentUser?.email ?? 'test@example.com',
        'name': _currentName ?? 'Customer',
      },
      'theme': {
        'color': '#FF9900'
      },
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true,
      },
      'notes': {
        'address': _currentAddress ?? '',
        'merchant_order_id': orderId,
        'customer_name': _currentName ?? '',
        'customer_mobile': _currentMobile ?? '',
      },
    };

    if (_currentContext != null) Navigator.of(_currentContext!).pop();

    try {
      if (kIsWeb) {
        _showWebPaymentDialog();
      } else {
        _razorpay.open(options);
      }
    } catch (e) {
      _showError('Error opening payment gateway: $e');
    }
  }

  void _showWebPaymentDialog() {
    if (_currentContext == null) return;
    
    showDialog(
      context: _currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.info, color: Color(0xFFFF9900)),
              SizedBox(width: 8),
              Text('Web Payment Demo'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.credit_card,
                size: 64,
                color: Color(0xFFFF9900),
              ),
              const SizedBox(height: 16),
              const Text(
                'Razorpay Integration Demo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Amount: ₹${Cart.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This is a demo of Razorpay integration. In a real mobile app, this would open the actual Razorpay payment gateway.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'Click "Simulate Payment" to proceed with a demo transaction.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _simulateWebPayment();
              },
              child: const Text('Simulate Payment'),
            ),
          ],
        );
      },
    );
  }

  void _simulateWebPayment() {
    if (_currentContext == null) return;
    
    showDialog(
      context: _currentContext!,
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
                Text('Processing Demo Payment...'),
              ],
            ),
          ),
        );
      },
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(_currentContext!).pop(); // Close processing dialog
      
      // Simulate success
      final fakePaymentId = 'pay_demo_${DateTime.now().millisecondsSinceEpoch}';
      _showSuccess('Payment Successful! ID: ${fakePaymentId.substring(0, 15)}...');
      
      // Navigate to order confirmation
      _navigateToOrderConfirmation(
        _currentContext!,
        'Razorpay Demo ($fakePaymentId)',
        'Paid',
        name: _currentName!,
        mobile: _currentMobile!,
        address: _currentAddress!,
      );
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _showSuccess('Payment Successful! Payment ID: ${response.paymentId?.substring(0, 10)}...');
    
    if (_currentContext != null) {
      // Show success loading
      showDialog(
        context: _currentContext!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Payment Successful!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Payment ID: ${response.paymentId?.substring(0, 15)}...'),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  const SizedBox(height: 8),
                  const Text('Processing your order...'),
                ],
              ),
            ),
          );
        },
      );

      // Delay to show success message, then navigate
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(_currentContext!).pop(); // Close success dialog
        _navigateToOrderConfirmation(
          _currentContext!,
          'Razorpay (${response.paymentId?.substring(0, 10)}...)',
          'Paid',
          name: _currentName!,
          mobile: _currentMobile!,
          address: _currentAddress!,
        );
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    String errorMessage = 'Payment Failed';
    
    if (response.code == Razorpay.NETWORK_ERROR) {
      errorMessage = 'Network error. Please check your internet connection and try again.';
    } else if (response.code == Razorpay.PAYMENT_CANCELLED) {
      errorMessage = 'Payment was cancelled by user.';
    } else {
      errorMessage = response.message ?? 'Payment failed. Please try again.';
    }
    
    _showError(errorMessage);
    
    // Show retry dialog for certain errors
    if (_currentContext != null && response.code != Razorpay.PAYMENT_CANCELLED) {
      Future.delayed(const Duration(seconds: 2), () {
        _showRetryDialog();
      });
    }
  }

  void _showRetryDialog() {
    if (_currentContext == null) return;
    
    showDialog(
      context: _currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.refresh, color: Color(0xFFFF9900)),
              SizedBox(width: 8),
              Text('Retry Payment?'),
            ],
          ),
          content: const Text(
            'Would you like to try the payment again?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openRazorpayCheckout();
              },
              child: const Text('Retry Payment'),
            ),
          ],
        );
      },
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSuccess('Payment initiated via ${response.walletName}. Please complete the payment in the app.');
    
    // Show external wallet processing dialog
    if (_currentContext != null) {
      showDialog(
        context: _currentContext!,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Color(0xFFFF9900)),
                const SizedBox(width: 8),
                Text('${response.walletName} Payment'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.open_in_new,
                  size: 48,
                  color: Color(0xFFFF9900),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please complete your payment in the ${response.walletName} app.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Return to this app after completing the payment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
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