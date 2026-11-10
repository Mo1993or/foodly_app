class RestaurantDashboardModel {
  final int totalOrders;
  final int pendingOrders;
  final int activeOrders;
  final int completedOrders;
  final double totalRevenue;
  final double averageBasket;
  final List<WeeklyRevenueModel> weeklyRevenue;
  final OrderDistributionModel orderDistribution;
  final List<RecentOrderModel> recentOrders;

  RestaurantDashboardModel({
    required this.totalOrders,
    required this.pendingOrders,
    required this.activeOrders,
    required this.completedOrders,
    required this.totalRevenue,
    required this.averageBasket,
    required this.weeklyRevenue,
    required this.orderDistribution,
    required this.recentOrders,
  });

  factory RestaurantDashboardModel.fromJson(Map<String, dynamic> json) {
    return RestaurantDashboardModel(
      totalOrders: _toInt(json['totalOrders']),
      pendingOrders: _toInt(json['pendingOrders']),
      activeOrders: _toInt(json['activeOrders']),
      completedOrders: _toInt(json['completedOrders']),
      totalRevenue: _toDouble(json['totalRevenue']),
      averageBasket: _toDouble(json['averageBasket']),
      weeklyRevenue: (json['weeklyRevenue'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                WeeklyRevenueModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      orderDistribution: OrderDistributionModel.fromJson(
        Map<String, dynamic>.from(json['orderDistribution'] ?? {}),
      ),
      recentOrders: (json['recentOrders'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                RecentOrderModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class WeeklyRevenueModel {
  final String date;
  final String day;
  final double revenue;

  WeeklyRevenueModel({
    required this.date,
    required this.day,
    required this.revenue,
  });

  factory WeeklyRevenueModel.fromJson(Map<String, dynamic> json) {
    return WeeklyRevenueModel(
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      revenue: _toDouble(json['revenue']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class OrderDistributionModel {
  final int pending;
  final int active;
  final int completed;

  OrderDistributionModel({
    required this.pending,
    required this.active,
    required this.completed,
  });

  factory OrderDistributionModel.fromJson(Map<String, dynamic> json) {
    return OrderDistributionModel(
      pending: _toInt(json['pending']),
      active: _toInt(json['active']),
      completed: _toInt(json['completed']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class RecentOrderModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final double total;
  final String status;
  final DateTime? createdAt;

  RecentOrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory RecentOrderModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] is Map
        ? Map<String, dynamic>.from(json['customer'])
        : <String, dynamic>{};

    return RecentOrderModel(
      id: json['_id']?.toString() ?? '',
      customerName: customer['name']?.toString() ?? '',
      customerPhone: customer['phone']?.toString() ?? '',
      total: _toDouble(json['total']),
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String get formattedStatus {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'En attente';
      case 'CONFIRMED':
        return 'Acceptée';
      case 'PREPARING':
        return 'En préparation';
      case 'READY':
        return 'Prête';
      case 'DELIVERED':
        return 'Livrée';
      case 'CANCELLED':
        return 'Annulée';
      default:
        return status;
    }
  }
}
