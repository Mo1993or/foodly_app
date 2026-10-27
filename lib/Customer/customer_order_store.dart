import 'package:flutter/foundation.dart';

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
}

class ClientOrdersStore extends ChangeNotifier {
  final List<ClientOrder> _orders = [];

  List<ClientOrder> get orders => List.unmodifiable(_orders.reversed.toList());

  void addOrder(ClientOrder order) {
    _orders.add(order);
    notifyListeners();
  }

  void updateStatus(String id, String newStatus) {
    final index = _orders.indexWhere((order) => order.id == id);

    if (index == -1) return;

    _orders[index].status = newStatus;
    notifyListeners();
  }

  ClientOrder? findById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }
}

final ClientOrdersStore clientOrdersStore = ClientOrdersStore();
