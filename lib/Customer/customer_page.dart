import 'package:flutter/material.dart';
import 'package:foodly/Auth/login_screen.dart';
import 'package:foodly/Customer/checkout_page.dart';
import 'package:foodly/Customer/explorer_page.dart';
import 'package:foodly/Customer/food_detail_page.dart';
import 'package:foodly/Customer/food_detail_screen.dart';
import 'package:foodly/Customer/my_order_screen.dart';
import 'package:foodly/Customer/panier_page.dart';
import 'package:foodly/Customer/profile_page.dart';
import 'package:foodly/Onboarding/role_page.dart';
import 'package:foodly/main.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  int _selectedCategory = 0;
  int _selectedTab = 0;
  final Set<String> _cart = {};

  final List<String> _categories = [
    'Tout',
    'Sénégalais',
    'Fast-food',
    'Pizza',
    'Poulet',
    'Desserts',
  ];

  final List<Map<String, dynamic>> _restaurants = [
    {
      'name': 'Le Bon Goût',
      'cuisine': 'Cuisine sénégalaise',
      'rating': '4.8',
      'time': '20-30 min',
      'category': 'Sénégalais',
      'color': const Color(0xFFB95D2B),
      'image':
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=700',
    },
    {
      'name': 'Burger House',
      'cuisine': 'Burgers • Fast-food',
      'rating': '4.7',
      'time': '15-25 min',
      'category': 'Fast-food',
      'color': const Color(0xFF9C5636),
      'image':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=700',
    },
    {
      'name': 'Pizza Palace',
      'cuisine': 'Pizza • Italienne',
      'rating': '4.6',
      'time': '25-35 min',
      'category': 'Pizza',
      'color': const Color(0xFFC17D32),
      'image':
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=700',
    },
  ];

  final List<Map<String, dynamic>> _dishes = [
    {
      'name': 'Poulet braisé',
      'restaurant': 'Le Bon Goût',
      'price': '4 500 FCFA',
      'image':
          'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=500',
    },
    {
      'name': 'Burger classique',
      'restaurant': 'Burger House',
      'price': '3 500 FCFA',
      'image':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
    },
    {
      'name': 'Pizza Margherita',
      'restaurant': 'Pizza Palace',
      'price': '5 000 FCFA',
      'image':
          'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500',
    },
  ];

  List<Map<String, dynamic>> get _filteredRestaurants {
    final query = _searchController.text.trim().toLowerCase();

    return _restaurants.where((restaurant) {
      final matchesSearch =
          restaurant['name'].toString().toLowerCase().contains(query) ||
          restaurant['cuisine'].toString().toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == 0 ||
          restaurant['category'] == _categories[_selectedCategory];

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoodlyApp.background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTab,
          children: [
            _buildHome(),
            ExploreScreen(),
            MyOrdersScreen(),
            ProfilePage(
              onLogout: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RestaurantLoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() => _selectedTab = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: FoodlyApp.orange.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explorer',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Commandes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(child: _buildHeader()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(child: _buildSearch()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          sliver: SliverToBoxAdapter(child: _buildBanner()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
          sliver: SliverToBoxAdapter(child: _buildCategories()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _sectionTitle(
              'Restaurants à découvrir',
              'Voir tout',
              () => setState(() => _selectedTab = 1),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final restaurants = _filteredRestaurants;

              if (restaurants.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Aucun restaurant trouvé. '
                    'Essayez une autre recherche.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _restaurantCard(restaurants[index], _dishes[index]),
              );
            }, childCount: _filteredRestaurants.length.clamp(0, 3)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _sectionTitle(
              'Les plats populaires',
              'Explorer',
              () => setState(() => _selectedTab = 1),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              height: 225,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _dishes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) =>
                    _dishCard(_dishes[index], _restaurants[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: FoodlyApp.orange,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.restaurant_menu_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VOTRE DESTINATION',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.1,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: FoodlyApp.orange,
                    size: 17,
                  ),
                  SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      'Dakar, Sénégal',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: FoodlyApp.green,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ],
          ),
        ),
        _roundAction(Icons.shopping_bag_outlined, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CartScreen(
                onCheckout: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
              ),
            ),
          );
        }, badge: _cart.length),
      ],
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFECEAE5)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Restaurant, plat, cuisine...',
          hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: FoodlyApp.green),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Les filtres avancés arrivent bientôt.'),
                ),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 180,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: FoodlyApp.green,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1547592180-85f173990554?w=900',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: FoodlyApp.green),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FoodlyApp.green.withValues(alpha: 0.95),
                    FoodlyApp.green.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 230,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: FoodlyApp.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'BIENVENUE CHEZ FOODLY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Vos envies,\nvos restaurants.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explorez les saveurs autour de vous.',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final icons = [
      Icons.grid_view_rounded,
      Icons.rice_bowl_rounded,
      Icons.lunch_dining_rounded,
      Icons.local_pizza_rounded,
      Icons.set_meal_rounded,
      Icons.icecream_rounded,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Explorer par envie', null, null),
        const SizedBox(height: 16),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final selected = _selectedCategory == index;

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedCategory = index;
                }),
                child: SizedBox(
                  width: 68,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: selected ? FoodlyApp.orange : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? FoodlyApp.orange
                                : const Color(0xFFECEAE5),
                          ),
                        ),
                        child: Icon(
                          icons[index],
                          size: 27,
                          color: selected ? Colors.white : FoodlyApp.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _categories[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: selected ? FoodlyApp.orange : FoodlyApp.green,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _restaurantCard(
    Map<String, dynamic> restaurant,
    Map<String, dynamic> dish,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final restaurantDishes = _dishes.where((dish) {
            return dish['restaurant'] == restaurant['name'];
          }).toList();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantDetailScreen(
                restaurant: restaurant,
                dishes: restaurantDishes,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 155,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    restaurant['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: restaurant['color'],
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'À découvrir',
                        style: TextStyle(
                          color: FoodlyApp.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: _roundAction(Icons.favorite_border_rounded, () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Les favoris seront disponibles bientôt.',
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant['name'],
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: FoodlyApp.green,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        size: 19,
                        color: Color(0xFFF5A623),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant['rating'],
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    restaurant['cuisine'],
                    style: const TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: FoodlyApp.orange,
                        size: 17,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        restaurant['time'],
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: FoodlyApp.orange,
                        size: 19,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> restaurants = [
    {
      'id': 'restaurant_1',
      'name': 'Le Bon Goût',
      'cuisine': 'Cuisine sénégalaise',
      'rating': '4.8',
      'time': '20-30 min',
      'category': 'Sénégalais',
      'color': const Color(0xFFB95D2B),
      'image':
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=700',
      'latitude': 14.6928,
      'longitude': -17.4467,
      'description': 'Cuisine sénégalaise et plats traditionnels.',
    },
    {
      'id': 'restaurant_2',
      'name': 'Burger House',
      'cuisine': 'Burgers • Fast-food',
      'rating': '4.7',
      'time': '15-25 min',
      'category': 'Fast-food',
      'color': const Color(0xFF9C5636),
      'image':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=700',
      'latitude': 14.6995,
      'longitude': -17.4570,
      'description': 'Burgers et repas rapides.',
    },
    {
      'id': 'restaurant_3',
      'name': 'Pizza Palace',
      'cuisine': 'Pizza • Italienne',
      'rating': '4.6',
      'time': '25-35 min',
      'category': 'Pizza',
      'color': const Color(0xFFC17D32),
      'image':
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=700',
      'latitude': 14.7050,
      'longitude': -17.4400,
      'description': 'Pizzas et spécialités italiennes.',
    },
  ];

  Widget _dishCard(Map<String, dynamic> dish, Map<String, dynamic> restaurant) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodDetailScreen(
              dish: dish,
              restaurantName: restaurant['name']?.toString() ?? 'Restaurant',
              restaurantId: restaurant['id']?.toString(),
            ),
          ),
        );
      },
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFECEAE5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              width: double.infinity,
              child: Image.network(
                dish['image'],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFFFE9D9),
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: FoodlyApp.orange,
                    size: 35,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(
                dish['name'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: FoodlyApp.green,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                dish['restaurant'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF888888), fontSize: 10),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 5, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      dish['price'],
                      style: const TextStyle(
                        color: FoodlyApp.orange,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        foodlyCart.addItem(
                          id:
                              dish['id']?.toString() ??
                              '${restaurant['name']}_${dish['name']}',
                          name: dish['name']?.toString() ?? 'Plat',
                          restaurantName:
                              restaurant['name']?.toString() ?? 'Restaurant',
                          unitPrice: int.parse(
                            dish['price']
                                .toString()
                                .replaceAll(' ', '')
                                .substring(0, 4),
                          ),
                        );
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${dish['name']} ajouté au panier.'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: FoodlyApp.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String? action, VoidCallback? onTap) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: FoodlyApp.green,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              action,
              style: const TextStyle(
                color: FoodlyApp.orange,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _roundAction(IconData icon, VoidCallback onTap, {int badge = 0}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFECEAE5)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: FoodlyApp.green, size: 22),
            if (badge > 0)
              Positioned(
                top: 1,
                right: 1,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: FoodlyApp.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(IconData icon, String title, String description) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: FoodlyApp.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 43, color: FoodlyApp.orange),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: FoodlyApp.green,
                fontWeight: FontWeight.w800,
                fontSize: 23,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF777777), height: 1.5),
            ),
            const SizedBox(height: 18),
            const Text(
              'Cette partie sera développée ensuite.',
              style: TextStyle(
                color: FoodlyApp.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
