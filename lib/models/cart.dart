import 'product.dart';

class Cart {
  static final Map<Product, int> _items = {};

  static Map<Product, int> get items => _items;

  static void add(Product product) {
    if (_items.containsKey(product)) {
      _items[product] = _items[product]! + 1;
    } else {
      _items[product] = 1;
    }
  }

  static void removeOne(Product product) {
    if (_items.containsKey(product)) {
      if (_items[product]! > 1) {
        _items[product] = _items[product]! - 1;
      } else {
        _items.remove(product);
      }
    }
  }

  static void removeAllOf(Product product) {
    _items.remove(product);
  }

  static void clear() {
    _items.clear();
  }

  static int getQuantity(Product product) {
    return _items[product] ?? 0;
  }

  static int get totalItems {
    int total = 0;
    _items.forEach((_, qty) => total += qty);
    return total;
  }
}
