import 'package:flutter/material.dart';
import 'razorpay_payment_service.dart';
import 'cod_payment_service.dart';

class PaymentService {
  static PaymentService? _instance;
  static PaymentService get instance => _instance ??= PaymentService._();
  
  PaymentService._();

  Future<void> processPayment(
    BuildContext context, {
    required String paymentMethod,
    required String name,
    required String mobile,
    required String address,
  }) async {
    switch (paymentMethod.toLowerCase()) {
      case 'razorpay':
        await RazorpayPaymentService.instance.processPayment(
          context,
          name: name,
          mobile: mobile,
          address: address,
        );
        break;
      case 'cod':
      case 'cash on delivery':
        await CODPaymentService.instance.processPayment(
          context,
          name: name,
          mobile: mobile,
          address: address,
        );
        break;
      default:
        throw Exception('Unsupported payment method: $paymentMethod');
    }
  }
}