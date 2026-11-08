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
  bool _isLoading = false;
  var statusTranslate = "";

  _checkStatus(String status) {
    setState(() {
      switch (status) {
        case "PENDING":
          statusTranslate = "En attente";
          break;
        case "CONFIRMED":
          statusTranslate = "Acceptée";
        case "PREPARING":
          statusTranslate = "En préparation";
        case "READY":
          statusTranslate = "Prête";
        case "DELIVERED":
          statusTranslate = "Terminée";
        case "CANCELLED":
          statusTranslate = "Refusée";
        default:
      }
    });
  }

  List<OrderModel> listOrders = [];
  _fetchOrder() async {
    try {
      await OrdersService()
          .fetchOrders(idRestaurants: widget.restaurant?.id ?? "")
          .then(
            (value) => {
              setState(() {
                listOrders = value;
                for (var item in listOrders) {
                  _checkStatus(item.status);
                }
              }),
            },
          );
    } catch (e) {
      print("error $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchOrder();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: restaurantData,
      builder: (context, _) {
        final orders = listOrders.reversed.where((order) {
          //  _checkStatus(order.status);
          return _filter == 'Toutes' || statusTranslate == _filter;
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
                        setState(() => _filter = filter);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: orders.isEmpty
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
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) =>
                            _orderCard(context, orders[index]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _orderCard(BuildContext context, OrderModel order) {
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
              _statusBadge(statusTranslate),
            ],
          ),
          const SizedBox(height: 12),
          for (CartModel element in order.item ?? []) ...{
            Text(
              element.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          },
          const SizedBox(height: 5),
          Text(
            '${order.item?.length} ligne(s) de commande',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            order.customer?.address ?? "",
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
                        statusTranslate: statusTranslate,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Détails',
                  style: TextStyle(color: foodlyOrange),
                ),
              ),
            ],
          ),
          if (statusTranslate == 'En attente') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _confirmStatus(context, order, 'Refusée', "CANCELLED"),
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
                    onPressed: () => _confirmStatus(
                      context,
                      order,
                      statusTranslate,
                      order.status,
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
          ] else if (_nextStatus(statusTranslate) != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    setState(() {
                      _isLoading = true;
                    });
                    switch (statusTranslate) {
                      case 'Acceptée':
                        await OrdersService().updateOrders(
                          order.id,
                          "PREPARING",
                        );
                        await _fetchOrder();
                        setState(() {
                          _isLoading = false;
                        });
                      case 'En préparation':
                        await OrdersService().updateOrders(order.id, "READY");
                        await _fetchOrder();
                        setState(() {
                          _isLoading = false;
                        });
                      case 'En attente':
                        await OrdersService().updateOrders(
                          order.id,
                          "CONFIRMED",
                        );
                        await _fetchOrder();
                        setState(() {
                          _isLoading = false;
                        });
                      case 'Prête':
                        await OrdersService().updateOrders(
                          order.id,
                          "DELIVERED",
                        );
                        await _fetchOrder();
                        setState(() {
                          _isLoading = false;
                        });
                      default:
                        await OrdersService().updateOrders(
                          order.id,
                          "CANCELLED",
                        );
                        await _fetchOrder();
                        setState(() {
                          _isLoading = false;
                        });
                    }
                  } catch (e) {
                    print("error $e");
                  }
                  // restaurantData.updateOrderStatus(
                  //   order.id,
                  //   _nextStatus(statusTranslate)!,
                  // );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: foodlyGreen,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Passer à : ${_nextStatus(statusTranslate)}'),
              ),
            ),
          ],
        ],
      ),
    );
  }

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

  Future<void> _confirmStatus(
    BuildContext context,
    OrderModel order,
    String status,
    String backStatus,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$status la commande ?'),
        content: Text(
          'Voulez-vous vraiment ${status.toLowerCase()} ${order.id} ?',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                setState(() {
                  _isLoading = true;
                });

                await OrdersService().updateOrders(order.id, "CANCELLED");
                await _fetchOrder();
                setState(() {
                  _isLoading = false;
                });
                Navigator.pop(dialogContext, true);
              } catch (e) {
                print("error $e");
                setState(() {
                  _isLoading = false;
                });
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                setState(() {
                  _isLoading = true;
                });
                await OrdersService().updateOrders(order.id, "CONFIRMED");
                await _fetchOrder();
                setState(() {
                  _isLoading = false;
                });
                Navigator.pop(dialogContext, true);
              } catch (e) {
                print("error $e");
                setState(() {
                  _isLoading = false;
                });
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      restaurantData.updateOrderStatus(order.id, status);
    }
  }

  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case 'Terminée':
      case 'Livrée':
        color = Colors.green;
        break;
      case 'Refusée':
        color = Colors.red;
        break;
      case 'En préparation':
      case 'Prête':
        color = Colors.deepPurple;
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
