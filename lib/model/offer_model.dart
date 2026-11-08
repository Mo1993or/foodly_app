class OfferModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final int price;
  final String billingPeriod;
  final List<dynamic> features;
  final bool isPopular;
  final bool isActive;
  final int sortOrder;

  const OfferModel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.price,
    required this.billingPeriod,
    required this.features,
    required this.isPopular,
    required this.isActive,
    required this.sortOrder,
  });
  factory OfferModel.fromJSON(Map<String, dynamic> json) {
    return OfferModel(
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
      code: json['code'] ?? "",
      description: json['description'] ?? "",
      price: json['price'] ?? 0,
      billingPeriod: json['billingPeriod'] ?? "",
      features: json['features'] ?? [],
      isPopular: json["isPopular"] ?? false,
      isActive: json["isActive"] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }
}

class SubscriptionModel {
  final String offerName;
  final String offerCode;
  final int amount;
  final String paymentMethod;
  final String status;

  SubscriptionModel({
    required this.offerName,
    required this.offerCode,
    required this.amount,
    required this.paymentMethod,
    required this.status,
  });

  factory SubscriptionModel.fromJSON(Map<String, dynamic> json) {
    return SubscriptionModel(
      offerName: json['offerName'] ?? "",
      offerCode: json['offerCode'] ?? "",
      amount: json['amount'] ?? 0,
      paymentMethod: json['paymentMethod'] ?? "",
      status: json['status'] ?? "",
    );
  }
}
