import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientOrder {
  final String id;
  final String customerName;
  final String phone;
  final String address;
  final String notes;
  final List<Map<String, dynamic>> items;
  final int totalPrice;
  final DateTime createdAt;

  String status;

  ClientOrder({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    this.notes = '',
    required this.items,
    required this.totalPrice,
    required this.createdAt,
    this.status = 'En attente',
  });

  int get totalItems => items.fold(
    0,
    (sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 0),
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'notes': notes,
      'items': items,
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory ClientOrder.fromJson(Map<String, dynamic> json) {
    return ClientOrder(
      id: json['id'] as String,
      customerName: json['customerName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      totalPrice: (json['totalPrice'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      status: json['status'] as String? ?? 'En attente',
    );
  }
}

class ClientOrdersStore extends ChangeNotifier {
  static const String _storageKey = 'foodly_client_orders';

  final List<ClientOrder> _orders = [];

  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<ClientOrder> get orders => List.unmodifiable(_orders.reversed.toList());

  /// Charger les commandes sauvegardées sur le téléphone.
  Future<void> loadOrders() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();

    final storedOrders = prefs.getString(_storageKey);

    if (storedOrders != null && storedOrders.isNotEmpty) {
      try {
        final decoded = jsonDecode(storedOrders) as List<dynamic>;

        _orders
          ..clear()
          ..addAll(
            decoded.map(
              (item) =>
                  ClientOrder.fromJson(Map<String, dynamic>.from(item as Map)),
            ),
          );
      } catch (e) {
        debugPrint('Erreur chargement commandes locales : $e');
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  /// Ajouter une commande et la sauvegarder immédiatement.
  Future<void> addOrder(ClientOrder order) async {
    await loadOrders();

    _orders.add(order);

    await _saveOrders();

    notifyListeners();
  }

  /// Modifier le statut et sauvegarder le changement.
  Future<void> updateStatus(String id, String newStatus) async {
    await loadOrders();

    final index = _orders.indexWhere((order) => order.id == id);

    if (index == -1) return;

    _orders[index].status = newStatus;

    await _saveOrders();

    notifyListeners();
  }

  /// Retrouver une commande par son identifiant.
  ClientOrder? findById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }

    return null;
  }

  /// Supprimer une commande.
  Future<void> deleteOrder(String id) async {
    await loadOrders();

    _orders.removeWhere((order) => order.id == id);

    await _saveOrders();

    notifyListeners();
  }

  /// Supprimer tout l'historique local.
  Future<void> clearOrders() async {
    await loadOrders();

    _orders.clear();

    await _saveOrders();

    notifyListeners();
  }

  /// Enregistrer toute la liste dans SharedPreferences.
  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(_orders.map((order) => order.toJson()).toList());

    await prefs.setString(_storageKey, encoded);
  }
}

final ClientOrdersStore clientOrdersStore = ClientOrdersStore();
