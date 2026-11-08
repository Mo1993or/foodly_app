import 'package:foodly/model/dishes_model.dart';

class OrderModel {
  final String id;
  final String restauranId;
  CustomerModel? customer;
  List<CartModel>? item;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final int total;
  final String note;
  final String createdAt;

  OrderModel({
    required this.id,
    required this.restauranId,
    required this.customer,
    required this.item,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.total,
    required this.note,
    required this.createdAt,
  });

  factory OrderModel.fromJSON(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? "",
      restauranId: json['restauranId'] ?? "",
      customer: CustomerModel.fromJSON(json['customer']),
      item: List<CartModel>.from(
        json['items'].map((x) => CartModel.fromJSON(x)),
      ),
      paymentMethod: json['paymentMethod'] ?? "",
      paymentStatus: json['paymentStatus'] ?? "",
      status: json['status'] ?? "",
      total: json['total'] ?? 0,
      note: json['note'] ?? "",
      createdAt: json['createdAt'] ?? "",
    );
  }
}

class CustomerModel {
  final String name;
  final String phone;
  final String address;

  CustomerModel({
    required this.name,
    required this.phone,
    required this.address,
  });

  factory CustomerModel.fromJSON(Map<String, dynamic> json) {
    return CustomerModel(
      name: json['name'] ?? "",
      phone: json['phone'] ?? "",
      address: json['address'] ?? "",
    );
  }
}

class CartModel {
  final String productId;
  final String name;
  final int price;
  final int quantity;
  final String imageUrl;

  CartModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory CartModel.fromJSON(Map<String, dynamic> json) {
    return CartModel(
      productId: json['productId'] ?? "",
      name: json['name'] ?? "",
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 0,
      imageUrl: json['imageUrl'] ?? "",
    );
  }
}
