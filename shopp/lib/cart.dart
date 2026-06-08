import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final int? id;
  final String title;
  final String type;
  final double price;
  final String image;
  int quantity;

  CartItem({
    this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.image,
    this.quantity = 1,
  });
}

final cartListProvider = StateProvider<List<CartItem>>((ref) {
  return [];
});

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartListProvider);

    double totalPrice = cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Your Cart',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.purple.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearCartDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? _buildEmptyCart(context)
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return _buildCartItemCard(cartItems[index], ref, context);
                    },
                  ),
          ),
          if (cartItems.isNotEmpty) _buildCheckoutCard(totalPrice, context),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(
      CartItem item, WidgetRef ref, BuildContext context) {
    return Dismissible(
      key: Key(item.id.toString()),
      background: Container(color: Colors.red.shade100),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _removeItem(ref, item.id, context),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  image: AssetImage(item.image),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              QuantitySelector(
                quantity: item.quantity,
                onChanged: (newQuantity) =>
                    _updateQuantity(ref, item.id, newQuantity),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutCard(double totalPrice, BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontSize: 18)),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _checkout(context),
                child: const Text(
                  'CHECKOUT',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse our collection to add items',
            style: TextStyle(color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(WidgetRef ref, int? id, int newQuantity) {
    ref.read(cartListProvider.notifier).update((cart) {
      final index = cart.indexWhere((item) => item.id == id);
      if (index != -1) {
        final updatedItem = cart[index];
        updatedItem.quantity = newQuantity;
        return [...cart];
      }
      return cart;
    });
  }

  void _removeItem(WidgetRef ref, int? id, BuildContext context) {
    ref.read(cartListProvider.notifier).update((cart) {
      return cart.where((item) => item.id != id).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item removed from cart')),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartListProvider.notifier).state = [];
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _checkout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proceeding to checkout...')),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final Function(int) onChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
        ),
        Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onChanged(quantity + 1),
        ),
      ],
    );
  }
}
