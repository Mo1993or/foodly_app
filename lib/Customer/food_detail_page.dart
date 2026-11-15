import 'package:flutter/material.dart';
import 'package:foodly/Customer/panier_page.dart';
import 'package:foodly/Restaurant/restaurant_add_edit_dish_screen.dart';
import 'package:foodly/Utils/theme.dart';
import 'package:foodly/model/dishes_model.dart';

class FoodDetailScreen extends StatefulWidget {
  final DishesModel dish;
  final String restaurantName;
  final String? restaurantId;

  const FoodDetailScreen({
    super.key,
    required this.dish,
    required this.restaurantName,
    this.restaurantId,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int quantity = 1;

  String get foodName => widget.dish.name.toString();

  int get foodPrice => widget.dish.price;

  String? get imageUrl {
    final value = widget.dish.imageUrl;

    if (value == null || value.toString().isEmpty) return null;
    return value.toString();
  }

  String get description => widget.dish.description.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: background,
            foregroundColor: green,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(background: _buildFoodImage()),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _FoodCartShortcut(),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurantName,
                    style: TextStyle(
                      color: orange,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    foodName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 22,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Nouveau',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.restaurant_outlined,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          widget.restaurantName,
                          style: TextStyle(color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '$foodPrice FCFA',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: orange,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Quantité',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onPressed: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onPressed: () {
                          setState(() => quantity++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total', style: TextStyle(color: Colors.black54)),
                  Text(
                    '${foodPrice * quantity} FCFA',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: foodPrice <= 0 ? null : _addToCart,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text(
                    'Ajouter au panier',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodImage() {
    if (imageUrl == null) {
      return Container(
        color: const Color(0xFFFFE9D9),
        child: Center(
          child: Icon(Icons.fastfood_rounded, size: 100, color: orange),
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: const Color(0xFFFFE9D9),
          child: Center(
            child: Icon(Icons.fastfood_rounded, size: 100, color: orange),
          ),
        );
      },
    );
  }

  void _addToCart() {
    final dishId = widget.dish.id.toString();
    foodlyCart.addItem(
      id: dishId,
      name: foodName,
      restaurantName: widget.restaurantName,
      unitPrice: foodPrice,
      quantity: quantity,
      idRestaurant: widget.restaurantId ?? "",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$foodName ajouté au panier'),
        backgroundColor: green,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Icon(icon, color: onPressed == null ? Colors.grey : green),
      ),
    );
  }
}

// Raccourci temporaire vers le panier existant.
class _FoodCartShortcut extends StatelessWidget {
  const _FoodCartShortcut();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon panier')),
      body: const Center(child: Text('Ouvre ici ton CartScreen existant.')),
    );
  }
}
