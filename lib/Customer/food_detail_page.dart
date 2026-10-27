import 'package:flutter/material.dart';
import 'package:foodly/Customer/panier_page.dart';

const Color foodlyOrange = Color(0xFFF56624);
const Color foodlyGreen = Color(0xFF173D32);
const Color foodlyBackground = Color(0xFFFAF8F3);

class FoodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> dish;
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

  String get foodName => widget.dish['name']?.toString() ?? 'Plat';

  int get foodPrice => int.parse(
    widget.dish['price'].toString().replaceAll(" ", '').substring(0, 4),
  );

  String? get imageUrl {
    final value =
        widget.dish['imageUrl'] ??
        widget.dish['image'] ??
        widget.dish['image_url'];

    if (value == null || value.toString().isEmpty) return null;
    return value.toString();
  }

  String get description =>
      widget.dish['description']?.toString() ??
      'Découvre ce délicieux plat préparé avec soin par notre restaurant partenaire.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: foodlyBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: foodlyBackground,
            foregroundColor: foodlyGreen,
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
                    style: const TextStyle(
                      color: foodlyOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    foodName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: foodlyGreen,
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
                        widget.dish['rating']?.toString() ?? 'Nouveau',
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: foodlyOrange,
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: foodlyGreen,
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
                  const Text(
                    'Quantité',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: foodlyGreen,
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
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: foodlyGreen,
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
                    backgroundColor: foodlyOrange,
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
        child: const Center(
          child: Icon(Icons.fastfood_rounded, size: 100, color: foodlyOrange),
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: const Color(0xFFFFE9D9),
          child: const Center(
            child: Icon(Icons.fastfood_rounded, size: 100, color: foodlyOrange),
          ),
        );
      },
    );
  }

  void _addToCart() {
    final dishId =
        widget.dish['id']?.toString() ??
        '${widget.restaurantId ?? widget.restaurantName}_$foodName';

    foodlyCart.addItem(
      id: dishId,
      name: foodName,
      restaurantName: widget.restaurantName,
      unitPrice: foodPrice,
      quantity: quantity,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$foodName ajouté au panier'),
        backgroundColor: foodlyGreen,
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
        child: Icon(icon, color: onPressed == null ? Colors.grey : foodlyGreen),
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
