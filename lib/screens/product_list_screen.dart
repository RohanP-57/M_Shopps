import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/product.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final products = Product.getDummyProducts();

  void _addToCart(Product product) {
    setState(() {
      Cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product added to cart")),
    );
  }

  void _increment(Product product) {
    setState(() {
      Cart.add(product);
    });
  }

  void _decrement(Product product) {
    setState(() {
      Cart.removeOne(product);
    });
  }

  int _getQuantity(Product product) {
    return Cart.getQuantity(product);
  }

  void _goToCheckout() {
    if (Cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty")),
      );
    } else {
      Navigator.pushNamed(context, '/checkout').then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _goToCheckout,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final quantity = _getQuantity(product);

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.network(
                product.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(product.name),
              subtitle: Text('₹${product.price}'),
              trailing: quantity == 0
                  ? ElevatedButton(
                onPressed: () => _addToCart(product),
                child: const Text("Add to Cart"),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => _decrement(product),
                  ),
                  Text(quantity.toString(),
                      style: const TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _increment(product),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCheckout,
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
