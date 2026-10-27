import 'package:flutter/material.dart';

const Color foodlyOrange = Color(0xFFF56624);
const Color foodlyGreen = Color(0xFF173D32);
const Color foodlyBackground = Color(0xFFFAF8F3);

class CartItem {
  final String id;
  final String name;
  final String restaurantName;
  final int unitPrice;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.restaurantName,
    required this.unitPrice,
    this.quantity = 1,
  });

  int get subtotal => unitPrice * quantity;
}

class FoodlyCart extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (total, item) => total + item.quantity);

  int get totalPrice => _items.fold(0, (total, item) => total + item.subtotal);

  void addItem({
    required String id,
    required String name,
    required String restaurantName,
    required int unitPrice,
    int quantity = 1,
  }) {
    final index = _items.indexWhere((item) => item.id == id);

    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          id: id,
          name: name,
          restaurantName: restaurantName,
          unitPrice: unitPrice,
          quantity: quantity,
        ),
      );
    }

    notifyListeners();
  }

  Map<String, dynamic> toOrderMap({
    required String customerName,
    required String phone,
    required String address,
    String notes = '',
  }) {
    return {
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'notes': notes,
      'items': _items.map((item) {
        return {
          'id': item.id,
          'name': item.name,
          'restaurantName': item.restaurantName,
          'unitPrice': item.unitPrice,
          'quantity': item.quantity,
          'subtotal': item.subtotal,
        };
      }).toList(),
      'totalItems': totalItems,
      'totalPrice': totalPrice,
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'pending',
    };
  }

  void increaseQuantity(String id) {
    final item = _items.firstWhere((item) => item.id == id);
    item.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

final FoodlyCart foodlyCart = FoodlyCart();

class CartScreen extends StatelessWidget {
  final VoidCallback onCheckout;

  const CartScreen({super.key, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: foodlyCart,
      builder: (context, _) {
        final items = foodlyCart.items;

        return Scaffold(
          backgroundColor: foodlyBackground,
          appBar: AppBar(
            backgroundColor: foodlyBackground,
            elevation: 0,
            title: const Text(
              'Mon panier',
              style: TextStyle(color: foodlyGreen, fontWeight: FontWeight.bold),
            ),
            iconTheme: const IconThemeData(color: foodlyGreen),
          ),
          body: items.isEmpty
              ? const _EmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: foodlyOrange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.fastfood_rounded,
                                    color: foodlyOrange,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: foodlyGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.restaurantName,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${item.subtotal} FCFA',
                                        style: const TextStyle(
                                          color: foodlyOrange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _QuantityButton(
                                          icon: Icons.remove,
                                          onTap: () => foodlyCart
                                              .decreaseQuantity(item.id),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        _QuantityButton(
                                          icon: Icons.add,
                                          onTap: () => foodlyCart
                                              .increaseQuantity(item.id),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          foodlyCart.removeItem(item.id),
                                      child: const Text(
                                        'Supprimer',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    _CartSummary(onCheckout: onCheckout),
                  ],
                ),
        );
      },
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: foodlyBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: foodlyGreen),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final VoidCallback onCheckout;

  const _CartSummary({required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Articles', style: TextStyle(color: Colors.black54)),
              Text('${foodlyCart.totalItems}'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total à payer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: foodlyGreen,
                ),
              ),
              Text(
                '${foodlyCart.totalPrice} FCFA',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  color: foodlyOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: foodlyCart.items.isEmpty ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: foodlyOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Passer la commande',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 76,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              'Ton panier est vide',
              style: TextStyle(
                color: foodlyGreen,
                fontWeight: FontWeight.bold,
                fontSize: 21,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoute tes plats préférés pour commencer ta commande.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
