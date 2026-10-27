import 'package:flutter/material.dart';
import 'package:foodly/Restaurant/retaurant_data.dart';
import 'restaurant_add_edit_dish_screen.dart';

class RestaurantMenuScreen extends StatelessWidget {
  const RestaurantMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: restaurantData,
      builder: (context, _) {
        final dishes = restaurantData.dishes;

        return Scaffold(
          backgroundColor: foodlyBackground,
          appBar: AppBar(
            backgroundColor: foodlyBackground,
            title: const Text(
              'Mon menu',
              style: TextStyle(color: foodlyGreen, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: () => _openDishForm(context),
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: foodlyOrange,
                  size: 28,
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openDishForm(context),
            backgroundColor: foodlyOrange,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un plat'),
          ),
          body: dishes.isEmpty
              ? const Center(
                  child: Text('Aucun plat. Ajoutez votre premier plat.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: dishes.length,
                  itemBuilder: (context, index) {
                    final dish = dishes[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _dishImage(dish),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dish.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: foodlyGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dish.category,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  formatCfa(dish.price),
                                  style: const TextStyle(
                                    color: foodlyOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  dish.isAvailable
                                      ? 'Disponible'
                                      : 'Indisponible',
                                  style: TextStyle(
                                    color: dish.isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (action) {
                              if (action == 'edit') {
                                _openDishForm(context, dish: dish);
                              } else if (action == 'availability') {
                                restaurantData.toggleDishAvailability(dish.id);
                              } else if (action == 'delete') {
                                _deleteDish(context, dish);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Modifier'),
                              ),
                              PopupMenuItem(
                                value: 'availability',
                                child: Text(
                                  dish.isAvailable ? 'Désactiver' : 'Activer',
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Supprimer',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _dishImage(RestaurantDish dish) {
    return Container(
      width: 88,
      height: 94,
      decoration: BoxDecoration(
        color: foodlyBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: dish.imageUrl.isNotEmpty
          ? Image.network(
              dish.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.fastfood, color: foodlyOrange, size: 35),
            )
          : const Icon(Icons.fastfood, color: foodlyOrange, size: 35),
    );
  }

  Future<void> _openDishForm(
    BuildContext context, {
    RestaurantDish? dish,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantAddEditDishScreen(dish: dish),
      ),
    );
  }

  Future<void> _deleteDish(BuildContext context, RestaurantDish dish) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer ce plat ?'),
        content: Text('Voulez-vous supprimer « ${dish.name} » ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      restaurantData.deleteDish(dish.id);
    }
  }
}
