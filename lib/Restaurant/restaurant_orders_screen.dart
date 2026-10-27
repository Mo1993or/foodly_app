import 'package:flutter/material.dart';
import 'package:foodly/Restaurant/retaurant_data.dart';
import 'package:foodly/Restaurant/retaurant_orders_detail_screen.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen> {
  String _filter = 'Toutes';

  final List<String> _filters = [
    'Toutes',
    'En attente',
    'Acceptée',
    'En préparation',
    'Prête',
    'Terminée',
    'Refusée',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: restaurantData,
      builder: (context, _) {
        final orders = restaurantData.orders.reversed.where((order) {
          return _filter == 'Toutes' || order.status == _filter;
        }).toList();

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
          body: Column(
            children: [
              SizedBox(
                height: 54,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final selected = _filter == filter;

                    return ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      selectedColor: foodlyGreen,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : foodlyGreen,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() => _filter = filter);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: orders.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 56,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text('Aucune commande dans cette catégorie.'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) =>
                            _orderCard(context, orders[index]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _orderCard(BuildContext context, RestaurantOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: const TextStyle(
                    color: foodlyGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              _statusBadge(order.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.customerName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            '${order.items.length} ligne(s) de commande',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            order.deliveryAddress,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatCfa(order.total),
                  style: const TextStyle(
                    color: foodlyGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantOrderDetailScreen(order: order),
                    ),
                  );
                },
                child: const Text(
                  'Détails',
                  style: TextStyle(color: foodlyOrange),
                ),
              ),
            ],
          ),
          if (order.status == 'En attente') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _confirmStatus(context, order, 'Refusée'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmStatus(context, order, 'Acceptée'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: foodlyOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accepter'),
                  ),
                ),
              ],
            ),
          ] else if (_nextStatus(order.status) != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => restaurantData.updateOrderStatus(
                  order.id,
                  _nextStatus(order.status)!,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: foodlyGreen,
                  foregroundColor: Colors.white,
                ),
                child: Text('Passer à : ${_nextStatus(order.status)}'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _nextStatus(String status) {
    switch (status) {
      case 'Acceptée':
        return 'En préparation';
      case 'En préparation':
        return 'Prête';
      case 'Prête':
        return 'Terminée';
      default:
        return null;
    }
  }

  Future<void> _confirmStatus(
    BuildContext context,
    RestaurantOrder order,
    String status,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$status la commande ?'),
        content: Text(
          'Voulez-vous vraiment ${status.toLowerCase()} ${order.id} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      restaurantData.updateOrderStatus(order.id, status);
    }
  }

  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case 'Terminée':
      case 'Livrée':
        color = Colors.green;
        break;
      case 'Refusée':
        color = Colors.red;
        break;
      case 'En préparation':
      case 'Prête':
        color = Colors.deepPurple;
        break;
      default:
        color = foodlyOrange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
