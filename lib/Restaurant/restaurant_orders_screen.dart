import 'package:flutter/material.dart';
import 'package:foodly/Restaurant/retaurant_data.dart';
import 'package:foodly/Restaurant/retaurant_orders_detail_screen.dart';
import 'package:foodly/model/order_model.dart';
import 'package:foodly/model/restaurant_model.dart';
import 'package:foodly/service/order_service.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key, required this.restaurant});

  final RestaurantModel? restaurant;

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen> {
  String _filter = 'Toutes';

  final List<String> _filters = [
    'Toutes',
    'En attente',
    'Acceptée',
    'En préparation',
    'Prête',
    'Terminée',
    'Refusée',
  ];

  List<OrderModel> listOrders = [];

  final Set<String> _updatingOrderIds = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  // Traduction du statut de chaque commande.
  String _checkStatus(String status) {
    switch (status.trim().toUpperCase()) {
      case 'PENDING':
        return 'En attente';

      case 'CONFIRMED':
        return 'Acceptée';

      case 'PREPARING':
        return 'En préparation';

      case 'READY':
        return 'Prête';

      case 'DELIVERED':
      case 'COMPLETED':
        return 'Terminée';

      case 'CANCELLED':
      case 'REJECTED':
        return 'Refusée';

      default:
        return status;
    }
  }

  // Récupération des commandes.
  Future<void> _fetchOrder() async {
    try {
      final orders = await OrdersService().fetchOrders(
        idRestaurants: widget.restaurant?.id ?? '',
      );

      if (!mounted) return;

      setState(() {
        listOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur récupération commandes : $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de charger les commandes.')),
      );
    }
  }

  // Modification d'une seule commande grâce à son ID.
  Future<void> _updateOrder(OrderModel order, String newStatus) async {
    if (_updatingOrderIds.contains(order.id)) return;

    setState(() {
      _updatingOrderIds.add(order.id);
    });

    try {
      await OrdersService().updateOrders(order.id, newStatus);

      await _fetchOrder();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande mise à jour avec succès.'),
          backgroundColor: foodlyGreen,
        ),
      );
    } catch (e) {
      debugPrint('Erreur modification commande ${order.id} : $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de modifier cette commande.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingOrderIds.remove(order.id);
        });
      }
    }
  }

  // Confirmation d'une action.
  Future<void> _confirmStatus(
    OrderModel order, {
    required String action,
    required String newStatus,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$action la commande ?'),
          content: Text(
            'Voulez-vous vraiment ${action.toLowerCase()} '
            'la commande ${order.id} ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus == 'CANCELLED'
                    ? Colors.red
                    : foodlyGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _updateOrder(order, newStatus);
    }
  }

  // Prochaine étape du statut.
  String? _nextStatus(String status) {
    switch (status) {
      case 'Acceptée':
        return 'En préparation';

      case 'En préparation':
        return 'Prête';

      case 'Prête':
        return 'Terminée';

      default:
        return null;
    }
  }

  // Code envoyé au backend.
  String? _nextStatusCode(String status) {
    switch (status) {
      case 'Acceptée':
        return 'PREPARING';

      case 'En préparation':
        return 'READY';

      case 'Prête':
        return 'DELIVERED';

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: restaurantData,
      builder: (context, _) {
        // Chaque commande utilise son propre statut.
        final orders = listOrders.reversed.where((order) {
          final orderStatus = _checkStatus(order.status);

          return _filter == 'Toutes' || orderStatus == _filter;
        }).toList();

        return Scaffold(
          backgroundColor: foodlyBackground,
          appBar: AppBar(
            leading: Container(),
            backgroundColor: foodlyBackground,
            elevation: 0,
            title: const Text(
              'Mes commandes',
              style: TextStyle(color: foodlyGreen, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: _isLoading ? null : _fetchOrder,
                icon: const Icon(Icons.refresh, color: foodlyGreen),
              ),
            ],
          ),
          body: Column(
            children: [
              SizedBox(
                height: 54,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final selected = _filter == filter;

                    return ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      selectedColor: foodlyGreen,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : foodlyGreen,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _filter = filter;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: foodlyGreen),
                      )
                    : orders.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 56,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text('Aucune commande dans cette catégorie.'),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: foodlyGreen,
                        onRefresh: _fetchOrder,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            return _orderCard(context, orders[index]);
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Carte individuelle de commande.
  Widget _orderCard(BuildContext context, OrderModel order) {
    // IMPORTANT : statut propre à cette commande.
    final orderStatus = _checkStatus(order.status);

    final isUpdating = _updatingOrderIds.contains(order.id);

    final nextStatus = _nextStatus(orderStatus);
    final nextStatusCode = _nextStatusCode(orderStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: const TextStyle(
                    color: foodlyGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              _statusBadge(orderStatus),
            ],
          ),

          const SizedBox(height: 12),

          for (final element in order.item ?? [])
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                element.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

          const SizedBox(height: 5),

          Text(
            '${order.item?.length ?? 0} ligne(s) de commande',
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 5),

          Text(
            order.customer?.address ?? '',
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Text(
                  formatCfa(order.total),
                  style: const TextStyle(
                    color: foodlyGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantOrderDetailScreen(
                        order: order,
                        statusTranslate: orderStatus,
                      ),
                    ),
                  ).then((_) {
                    _fetchOrder();
                  });
                },
                child: const Text(
                  'Détails',
                  style: TextStyle(color: foodlyOrange),
                ),
              ),
            ],
          ),

          // Commande en attente.
          if (orderStatus == 'En attente') ...[
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isUpdating
                        ? null
                        : () => _confirmStatus(
                            order,
                            action: 'Refuser',
                            newStatus: 'CANCELLED',
                          ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Refuser'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: isUpdating
                        ? null
                        : () => _confirmStatus(
                            order,
                            action: 'Accepter',
                            newStatus: 'CONFIRMED',
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: foodlyOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accepter'),
                  ),
                ),
              ],
            ),
          ]
          // Progression des commandes acceptées.
          else if (nextStatus != null && nextStatusCode != null) ...[
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUpdating
                    ? null
                    : () => _updateOrder(order, nextStatusCode),
                style: ElevatedButton.styleFrom(
                  backgroundColor: foodlyGreen,
                  foregroundColor: Colors.white,
                ),
                child: isUpdating
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Passer à : $nextStatus'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Badge de statut.
  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case 'Terminée':
        color = Colors.green;
        break;

      case 'Refusée':
        color = Colors.red;
        break;

      case 'En préparation':
      case 'Prête':
        color = Colors.deepPurple;
        break;

      case 'Acceptée':
        color = foodlyGreen;
        break;

      default:
        color = foodlyOrange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
