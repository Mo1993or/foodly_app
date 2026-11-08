import 'dart:ffi';

class RestaurantModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String commercialPhone;
  final String description;
  final String restaurantType;
  final String logoUrl;
  final String coverPhotoUrl;
  final List<dynamic> colors;
  final double latitude;
  final double longitude;
  final String ownerId;
  final String reviewNote;
  final bool isOpen;
  final String activeOffer;
  final String subscriptionExpiresAt;
  final String subscriptionStatus;
  final String trialEndsAt;
  final String trialStartedAt;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.commercialPhone,
    required this.logoUrl,
    required this.colors,
    required this.description,
    required this.coverPhotoUrl,
    required this.latitude,
    required this.longitude,
    required this.ownerId,
    required this.restaurantType,
    required this.reviewNote,
    required this.isOpen,
    required this.activeOffer,
    required this.subscriptionExpiresAt,
    required this.subscriptionStatus,
    required this.trialEndsAt,
    required this.trialStartedAt,
  });

  factory RestaurantModel.fromJSON(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
      address: json['address'] ?? "",
      phone: json['phone'] ?? "",
      commercialPhone: json['commercialPhone'] ?? "",
      logoUrl: json['logoUrl'] ?? "",
      colors: json['colors'] ?? [],
      description: json['description'] ?? "",
      coverPhotoUrl: json['coverPhotoUrl'] ?? "",
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      ownerId: json['ownerId'] ?? "",
      restaurantType: json['restaurantType'] ?? "",
      reviewNote: json['reviewNote'] ?? "",
      isOpen: json['isOpen'] ?? false,
      activeOffer: json["activeOffer"] ?? "",
      subscriptionExpiresAt: json["subscriptionExpiresAt"] ?? "",
      subscriptionStatus: json["subscriptionStatus"] ?? "",
      trialStartedAt: json["trialStartedAt"] ?? "",
      trialEndsAt: json["trialEndsAt"] ?? "",
    );
  }
}
