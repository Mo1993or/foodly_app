import 'package:foodly/model/restaurant_model.dart';

class DishesModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final String category;
  final String imageUrl;
  final String imagePublicId;
  RestaurantModel? restaurant;
  final bool isAvailable;

  DishesModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.imagePublicId,
    required this.restaurant,
    required this.isAvailable,
  });

  factory DishesModel.fromJSON(Map<String, dynamic> json) {
    return DishesModel(
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      category: json['category'] ?? "",
      price: json['price'] ?? 0,
      imageUrl: json['imageUrl'] ?? "",
      imagePublicId: json['imagePublicId'] ?? "",
      restaurant: RestaurantModel.fromJSON(json["restaurantId"]),
      isAvailable: json['isAvailable'] ?? bool,
    );
  }
}
