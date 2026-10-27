import 'package:flutter/material.dart';
import 'package:foodly/Customer/food_detail_screen.dart';
import 'package:foodly/Restaurant/retaurant_data.dart'
    hide foodlyGreen, foodlyOrange, foodlyBackground;

class RestaurantOrderDetailScreen extends StatelessWidget {
  final RestaurantOrder order;

  const RestaurantOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: foodlyBackground,
      appBar: AppBar(
        backgroundColor: foodlyBackground,
        title: Text(
          order.id,
          style: const TextStyle(
            color: foodlyGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: foodlyGreen,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Montant de la commande',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  formatCfa(order.total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Statut : ${order.status}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Informations du client',
            style: TextStyle(
              color: foodlyGreen,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _infoTile(Icons.person_outline, order.customerName),
          _infoTile(Icons.phone_outlined, order.customerPhone),
          _infoTile(Icons.location_on_outlined, order.deliveryAddress),
          _infoTile(
            Icons.access_time,
            '${order.createdAt.day.toString().padLeft(2, '0')}/'
            '${order.createdAt.month.toString().padLeft(2, '0')}/'
            '${order.createdAt.year} à '
            '${order.createdAt.hour.toString().padLeft(2, '0')}:'
            '${order.createdAt.minute.toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 24),
          const Text(
            'Plats commandés',
            style: TextStyle(
              color: foodlyGreen,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) {
            final name = item['name']?.toString() ?? 'Plat';
            final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
            final price = (item['price'] as num?)?.toInt() ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: foodlyOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.restaurant, color: foodlyOrange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$quantity × ${formatCfa(price)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatCfa(quantity * price),
                    style: const TextStyle(
                      color: foodlyGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (order.status == 'En attente') ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                restaurantData.updateOrderStatus(order.id, 'Acceptée');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: foodlyOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Accepter la commande'),
            ),
          ] else if (order.status == 'Acceptée' ||
              order.status == 'En préparation' ||
              order.status == 'Prête') ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final next = order.status == 'Acceptée'
                    ? 'En préparation'
                    : order.status == 'En préparation'
                    ? 'Prête'
                    : 'Terminée';

                restaurantData.updateOrderStatus(order.id, next);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: foodlyGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                order.status == 'Prête'
                    ? 'Marquer comme terminée'
                    : 'Passer à l’étape suivante',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: foodlyOrange),
          const SizedBox(width: 12),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
