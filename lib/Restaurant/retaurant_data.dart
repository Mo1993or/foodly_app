import 'dart:ui';

import 'package:flutter/foundation.dart';

const Color foodlyOrange = Color(0xFFF56624);
const Color foodlyGreen = Color(0xFF173D32);
const Color foodlyBackground = Color(0xFFFAF8F3);

class RestaurantDish {
  final String id;
  String name;
  String description;
  int price;
  String category;
  String imageUrl;
  bool isAvailable;

  RestaurantDish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl = '',
    this.isAvailable = true,
  });
}

class RestaurantOrder {
  final String id;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final DateTime createdAt;
  final List<Map<String, dynamic>> items;
  final int total;
  String status;

  RestaurantOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.createdAt,
    required this.items,
    required this.total,
    this.status = 'En attente',
  });
}

class RestaurantData extends ChangeNotifier {
  String name = 'Chez Awa';
  String address = 'Dakar, Sénégal';
  String phone = '+221 77 000 00 00';
  String email = 'chezawa@example.com';
  String description = 'Cuisine locale et spécialités sénégalaises';
  bool isOpen = true;

  final List<RestaurantDish> dishes = [
    RestaurantDish(
      id: 'dish_1',
      name: 'Thieboudienne',
      description: 'Riz au poisson accompagné de légumes.',
      price: 2500,
      category: 'Plats locaux',
    ),
    RestaurantDish(
      id: 'dish_2',
      name: 'Yassa Poulet',
      description: 'Poulet mariné aux oignons et au citron.',
      price: 3000,
      category: 'Plats locaux',
    ),
    RestaurantDish(
      id: 'dish_3',
      name: 'Jus de bissap',
      description: 'Jus de bissap frais fait maison.',
      price: 1000,
      category: 'Boissons',
    ),
  ];

  final List<RestaurantOrder> orders = [
    RestaurantOrder(
      id: 'CMD-1001',
      customerName: 'Mamadou Ndiaye',
      customerPhone: '+221 77 111 22 33',
      deliveryAddress: 'Plateau, Dakar',
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      items: [
        {'name': 'Thieboudienne', 'quantity': 2, 'price': 2500},
        {'name': 'Jus de bissap', 'quantity': 1, 'price': 1000},
      ],
      total: 6000,
    ),
    RestaurantOrder(
      id: 'CMD-1002',
      customerName: 'Aminata Fall',
      customerPhone: '+221 76 444 55 66',
      deliveryAddress: 'Mermoz, Dakar',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      items: [
        {'name': 'Yassa Poulet', 'quantity': 1, 'price': 3000},
      ],
      total: 3000,
      status: 'En préparation',
    ),
  ];

  int get pendingOrders =>
      orders.where((order) => order.status == 'En attente').length;

  int get todayOrders => orders.length;

  int get todayRevenue => orders
      .where((order) => order.status == 'Terminée' || order.status == 'Livrée')
      .fold<int>(0, (sum, order) => sum + order.total);

  void updateOrderStatus(String id, String status) {
    final index = orders.indexWhere((order) => order.id == id);
    if (index == -1) return;

    orders[index].status = status;
    notifyListeners();
  }

  void addDish(RestaurantDish dish) {
    dishes.add(dish);
    notifyListeners();
  }

  void updateDish(RestaurantDish updatedDish) {
    final index = dishes.indexWhere((dish) => dish.id == updatedDish.id);
    if (index == -1) return;

    dishes[index] = updatedDish;
    notifyListeners();
  }

  void deleteDish(String id) {
    dishes.removeWhere((dish) => dish.id == id);
    notifyListeners();
  }

  void toggleDishAvailability(String id) {
    final index = dishes.indexWhere((dish) => dish.id == id);
    if (index == -1) return;

    dishes[index].isAvailable = !dishes[index].isAvailable;
    notifyListeners();
  }

  void updateRestaurant({
    required String name,
    required String address,
    required String phone,
    required String email,
    required String description,
    required bool isOpen,
  }) {
    this.name = name;
    this.address = address;
    this.phone = phone;
    this.email = email;
    this.description = description;
    this.isOpen = isOpen;
    notifyListeners();
  }
}

final RestaurantData restaurantData = RestaurantData();

String formatCfa(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    buffer.write(digits[i]);

    final remaining = digits.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write(' ');
    }
  }

  return '${buffer.toString()} FCFA';
}
