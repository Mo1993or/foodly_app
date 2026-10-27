import 'package:flutter/material.dart';
import 'package:foodly/Customer/customer_order_store.dart';

const Color foodlyOrange = Color(0xFFF56624);
const Color foodlyGreen = Color(0xFF173D32);
const Color foodlyBackground = Color(0xFFFAF8F3);

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: clientOrdersStore,
      builder: (context, _) {
        final orders = clientOrdersStore.orders;

        return Scaffold(
          backgroundColor: foodlyBackground,
          appBar: AppBar(
            backgroundColor: foodlyBackground,
            elevation: 0,
            title: const Text(
              'Mes commandes',
              style: TextStyle(color: foodlyGreen, fontWeight: FontWeight.bold),
            ),
          ),
          body: orders.isEmpty
              ? const _EmptyOrders()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    return _OrderCard(
                      order: order,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(order: order),
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final ClientOrder order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Commande #${order.id}',
                    style: const TextStyle(
                      color: foodlyGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${order.totalItems} article(s)',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              '${order.totalPrice} FCFA',
              style: const TextStyle(
                color: foodlyOrange,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(order.createdAt),
              style: const TextStyle(color: Colors.black45, fontSize: 12),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Voir les détails',
                  style: TextStyle(
                    color: foodlyGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 5),
                Icon(Icons.arrow_forward_ios, size: 14, color: foodlyGreen),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final ClientOrder order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: clientOrdersStore,
      builder: (context, _) {
        final currentOrder = clientOrdersStore.findById(order.id) ?? order;

        return Scaffold(
          backgroundColor: foodlyBackground,
          appBar: AppBar(
            backgroundColor: foodlyBackground,
            elevation: 0,
            title: const Text(
              'Détails de la commande',
              style: TextStyle(color: foodlyGreen, fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commande #${currentOrder.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: foodlyGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatusBadge(status: currentOrder.status),
                    const SizedBox(height: 12),
                    Text(_formatDate(currentOrder.createdAt)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Articles commandés',
                style: TextStyle(
                  fontSize: 19,
                  color: foodlyGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...currentOrder.items.map((item) {
                final name = item['name']?.toString() ?? 'Plat';
                final restaurant =
                    item['restaurantName']?.toString() ?? 'Restaurant';
                final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
                final subtotal = (item['subtotal'] as num?)?.toInt() ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        color: foodlyOrange,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              restaurant,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            Text('Quantité : $quantity'),
                          ],
                        ),
                      ),
                      Text(
                        '$subtotal FCFA',
                        style: const TextStyle(
                          color: foodlyGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Livraison',
                      style: TextStyle(
                        color: foodlyGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(currentOrder.customerName),
                    const SizedBox(height: 5),
                    Text(currentOrder.phone),
                    const SizedBox(height: 5),
                    Text(currentOrder.address),
                    if (currentOrder.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Note : ${currentOrder.notes}'),
                    ],
                    const Divider(height: 28),
                    const Text(
                      'Total à payer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${currentOrder.totalPrice} FCFA',
                      style: const TextStyle(
                        color: foodlyOrange,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      'Acceptée' => Colors.blue,
      'Refusée' => Colors.red,
      'En préparation' => foodlyOrange,
      'Prête' => foodlyGreen,
      'Terminée' => Colors.grey,
      _ => Colors.orange,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 76,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 18),
            const Text(
              'Aucune commande pour le moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: foodlyGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tes commandes apparaîtront ici après confirmation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year;
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day/$month/$year à $hour:$minute';
}
