import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/product.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  void _removeOne(Product product) {
    setState(() {
      Cart.removeOne(product);
    });
  }

  void _addOne(Product product) {
    setState(() {
      Cart.add(product);
    });
  }

  void _removeAll(Product product) {
    setState(() {
      Cart.removeAllOf(product);
    });
  }

  int _getTotalAmount() {
    int total = 0;
    Cart.items.forEach((product, quantity) {
      total += product.price * quantity;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = Cart.items.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final product = cartItems[index].key;
                final quantity = cartItems[index].value;

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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₹${product.price} x $quantity = ₹${product.price * quantity}'),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _removeOne(product),
                            ),
                            Text('$quantity', style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _addOne(product),
                            ),
                            const SizedBox(width: 10),
                            TextButton.icon(
                              onPressed: () => _removeAll(product),
                              icon: const Icon(Icons.delete),
                              label: const Text("Remove"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total Amount: ₹${_getTotalAmount()}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Order placed successfully via UPI!")),
                    );
                    setState(() {
                      Cart.clear();
                    });
                  },
                  child: const Text("Pay with UPI"),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Order placed with Cash on Delivery!")),
                    );
                    setState(() {
                      Cart.clear();
                    });
                  },
                  child: const Text("Cash on Delivery"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
