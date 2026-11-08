import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OrderLocalService {
  static const String _ordersKey = 'foodly_customer_orders';

  /// Récupérer toutes les commandes enregistrées sur le téléphone.
  static Future<List<Map<String, dynamic>>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();

    final String? storedOrders = prefs.getString(_ordersKey);

    if (storedOrders == null || storedOrders.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(storedOrders);

      return decoded.map((order) => Map<String, dynamic>.from(order)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Enregistrer une nouvelle commande dans l'historique local.
  static Future<void> saveOrder(Map<String, dynamic> order) async {
    final prefs = await SharedPreferences.getInstance();

    final orders = await getOrders();

    final newOrder = Map<String, dynamic>.from(order);

    // Identifiant local unique.
    newOrder['localId'] ??= DateTime.now().microsecondsSinceEpoch.toString();

    // Date de création.
    newOrder['createdAt'] ??= DateTime.now().toIso8601String();

    orders.insert(0, newOrder);

    await prefs.setString(_ordersKey, jsonEncode(orders));
  }

  /// Supprimer une commande de l'historique local.
  static Future<void> deleteOrder(String localId) async {
    final prefs = await SharedPreferences.getInstance();

    final orders = await getOrders();

    orders.removeWhere((order) => order['localId'] == localId);

    await prefs.setString(_ordersKey, jsonEncode(orders));
  }

  /// Effacer tout l'historique local.
  static Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ordersKey);
  }
}
