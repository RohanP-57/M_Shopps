import 'product.dart';

class Cart {
  static final List<Product> _cartItems = [];

  static void add(Product product) {
    _cartItems.add(product);
  }

  static List<Product> get items => _cartItems;

  static double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.price);
}
