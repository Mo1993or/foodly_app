import 'package:flutter/material.dart';
import 'package:foodly/Customer/food_detail_screen.dart';
import 'package:foodly/Restaurant/retaurant_data.dart';
import 'package:foodly/Utils/network.dart';
import 'package:foodly/Utils/theme.dart';
import 'package:foodly/main.dart';
import 'package:foodly/model/order_model.dart';
import 'package:foodly/model/restaurant_model.dart';

class RestaurantOrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  final String statusTranslate;
  final RestaurantModel? restaurant;

  const RestaurantOrderDetailScreen({
    super.key,
    required this.order,
    required this.statusTranslate,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: Text(
          order.id,
          style: TextStyle(
            color: restaurant?.colors.first.toString().toColor(),
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
              color: restaurant?.colors.first.toString().toColor(),
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
                  'Statut : ${statusTranslate}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Informations du client',
            style: TextStyle(
              color: restaurant?.colors.first.toString().toColor(),
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _infoTile(Icons.person_outline, order.customer?.name ?? ""),
          _infoTile(Icons.phone_outlined, order.customer?.phone ?? ""),
          _infoTile(Icons.location_on_outlined, order.customer?.address ?? ""),
          _infoTile(
            Icons.access_time,
            '${DateTime.parse(order.createdAt).day.toString().padLeft(2, '0')}/'
            '${DateTime.parse(order.createdAt).month.toString().padLeft(2, '0')}/'
            '${DateTime.parse(order.createdAt).year} à '
            '${DateTime.parse(order.createdAt).hour.toString().padLeft(2, '0')}:'
            '${DateTime.parse(order.createdAt).minute.toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 24),
          Text(
            'Plats commandés',
            style: TextStyle(
              color: restaurant?.colors.first.toString().toColor(),
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...order.item!.map((item) {
            final name = item.name;
            final quantity = item.quantity;
            final price = item.price;

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
                      image: DecorationImage(
                        image: NetworkImage(item.imageUrl),
                        fit: .cover,
                      ),
                      color: orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    style: TextStyle(
                      color: restaurant?.colors.first.toString().toColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (statusTranslate == 'En attente') ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                restaurantData.updateOrderStatus(order.id, 'Acceptée');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Accepter la commande'),
            ),
          ] else if (statusTranslate == 'Acceptée' ||
              statusTranslate == 'En préparation' ||
              statusTranslate == 'Prête') ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final next = statusTranslate == 'Acceptée'
                    ? 'En préparation'
                    : statusTranslate == 'En préparation'
                    ? 'Prête'
                    : 'Terminée';

                restaurantData.updateOrderStatus(order.id, next);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: restaurant?.colors.first.toString().toColor(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                statusTranslate == 'Prête'
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
          Icon(icon, color: orange),
          const SizedBox(width: 12),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
