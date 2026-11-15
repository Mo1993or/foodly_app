import 'package:flutter/material.dart';
import 'package:foodly/Auth/login_screen.dart';
import 'package:foodly/Customer/checkout_page.dart';
import 'package:foodly/Customer/explorer_page.dart';
import 'package:foodly/Customer/food_detail_page.dart';
import 'package:foodly/Customer/food_detail_screen.dart';
import 'package:foodly/Customer/my_order_screen.dart';
import 'package:foodly/Customer/panier_page.dart';
import 'package:foodly/Customer/profile_page.dart';
import 'package:foodly/Utils/theme.dart';
import 'package:foodly/model/dishes_model.dart';
import 'package:foodly/model/restaurant_model.dart';
import 'package:foodly/service/restaurant_service.dart';
import 'package:foodly/widget/shimers.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  int _selectedCategory = 0;
  int _selectedTab = 0;

  List<dynamic> categories = [];
  List<dynamic> restaurantTypes = [];

  List<RestaurantModel> restaurants = [];
  List<DishesModel> dishes = [];

  bool isLoading = true;

  // FOODLY COLOR PALETTE

  List<RestaurantModel> get _filteredRestaurants {
    final query = _searchController.text.trim().toLowerCase();

    return restaurants.where((restaurant) {
      final matchesSearch =
          restaurant.name.toLowerCase().contains(query) ||
          restaurant.restaurantType.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == 0 ||
          (_selectedCategory < categories.length &&
              restaurant.restaurantType == categories[_selectedCategory]);

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    foodlyCart.loadCart();

    _fetchRestaurant();
    _fetchTypesList();
    _fetchDishes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRestaurant() async {
    try {
      if (mounted) {
        setState(() => isLoading = true);
      }

      final value = await RestaurantService().fetchRestaurants();

      if (!mounted) return;

      setState(() {
        restaurants = value;
        isLoading = false;
      });
    } catch (error) {
      debugPrint('Erreur restaurants : $error');

      if (!mounted) return;

      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshHome() async {
    await Future.wait([_fetchRestaurant(), _fetchTypesList(), _fetchDishes()]);
  }

  Future<void> _fetchTypesList() async {
    try {
      final value = await RestaurantService().fetchTypesRestaurants();

      if (!mounted) return;

      setState(() => categories = value);
    } catch (error) {
      debugPrint('Erreur catégories : $error');
    }
  }

  Future<void> _fetchDishes() async {
    try {
      final value = await RestaurantService().fetchDishes(idRestaurants: "");

      if (!mounted) return;

      setState(() => dishes = value);
    } catch (error) {
      debugPrint('Erreur plats : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTab,
          children: [
            isLoading ? const RestaurantShimmer(itemCount: 3) : _buildHome(),
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
        indicatorColor: softPink,
        elevation: 8,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: green),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded, color: green),
            label: 'Explorer',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: green),
            label: 'Commandes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: green),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    final filteredRestaurants = _filteredRestaurants;

    return RefreshIndicator(
      color: green,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      displacement: 55,
      onRefresh: _refreshHome,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
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
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (filteredRestaurants.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Aucun restaurant trouvé. Essayez une autre recherche.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryText),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _restaurantCard(filteredRestaurants[index]),
                  );
                },
                childCount: filteredRestaurants.isEmpty
                    ? 1
                    : filteredRestaurants.length.clamp(0, 3),
              ),
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
                child: dishes.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun plat disponible pour le moment.',
                          style: TextStyle(color: secondaryText),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: dishes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          return _dishCard(
                            dishes[index],
                            dishes[index].restaurant,
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: foodlyCart,
      builder: (context, child) {
        return Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(15),
                image: const DecorationImage(
                  image: AssetImage("assets/images/logo.png"),
                  fit: BoxFit.cover,
                ),
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
                      color: secondaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: green, size: 17),
                      SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          'Dakar, Sénégal',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: green,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded, color: green),
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
                        MaterialPageRoute(builder: (_) => CheckoutScreen()),
                      );
                    },
                  ),
                ),
              );
            }, badge: foodlyCart.totalItems),
          ],
        );
      },
    );
  }

  // SEARCH
  Widget _buildSearch() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: lightBorder),
        boxShadow: [
          BoxShadow(
            color: green.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: green, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Restaurant, plat, cuisine...',
          hintStyle: const TextStyle(color: secondaryText, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: green),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune_rounded, color: orange),
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

  // BANNER
  Widget _buildBanner() {
    return Container(
      height: 180,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: green,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1547592180-85f173990554?w=900',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(color: green),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    green.withValues(alpha: 0.96),
                    green.withValues(alpha: 0.18),
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
                      color: orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'BIENVENUE CHEZ THIOP',
                      style: TextStyle(
                        color: green,
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

  // CATEGORIES
  Widget _buildCategories() {
    final List<IconData> icons = [
      Icons.grid_view_rounded, // Tout
      Icons.restaurant_rounded, // Restaurant traditionnel
      Icons.lunch_dining_rounded, // Fast-food
      Icons.local_pizza_rounded, // Pizzeria
      Icons.outdoor_grill_rounded, // Grillades
      Icons.rice_bowl_rounded, // Cuisine sénégalaise
      Icons.dinner_dining_rounded, // Cuisine africaine
      Icons.ramen_dining_rounded, // Cuisine asiatique
      Icons.cake_rounded, // Pâtisserie
      Icons.bakery_dining_rounded, // Boulangerie
      Icons.coffee_rounded, // Café
      Icons.local_cafe_rounded, // Jus et boissons
      Icons.restaurant_menu_rounded, // Restaurant gastronomique
      Icons.eco_rounded, // Végétarien
      Icons.set_meal_rounded, // Fruits de mer
      Icons.more_horiz_rounded, // Autre
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Explorer par envie', null, null),
        const SizedBox(height: 16),
        SizedBox(
          height: 96,
          child: categories.isEmpty
              ? const Center(
                  child: Text(
                    'Chargement des catégories...',
                    style: TextStyle(color: secondaryText, fontSize: 12),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final selected = _selectedCategory == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = index;
                        });
                      },
                      child: SizedBox(
                        width: 68,
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: selected ? green : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected ? green : lightBorder,
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: green.withValues(alpha: 0.13),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                icons[index % icons.length],
                                size: 27,
                                color: selected ? Colors.white : orange,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              categories[index].toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: selected ? green : secondaryText,
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

  // RESTAURANT CARD
  Widget _restaurantCard(RestaurantModel restaurant) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final restaurantDishes = dishes.where((dish) {
            return dish.restaurant?.name == restaurant.name;
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
                    restaurant.coverPhotoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: restaurant.colors.isNotEmpty
                          ? restaurant.colors[0].toColor
                          : green,
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
                          color: green,
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
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: green,
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
                        restaurant.reviewNote,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    restaurant.restaurantType,
                    style: const TextStyle(color: secondaryText, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  if (restaurant.isOpen)
                    const Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: success,
                          size: 17,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Ouvert',
                          style: TextStyle(
                            fontSize: 12,
                            color: success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: green,
                          size: 19,
                        ),
                      ],
                    )
                  else
                    const Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: darkPink,
                          size: 17,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Fermé',
                          style: TextStyle(
                            fontSize: 12,
                            color: darkPink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: darkPink,
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

  // DISH CARD
  Widget _dishCard(DishesModel dish, RestaurantModel? restaurant) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodDetailScreen(
              dish: dish,
              restaurantName: restaurant?.name.toString() ?? "",
              restaurantId: restaurant?.id.toString(),
            ),
          ),
        );
      },
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: lightBorder),
          boxShadow: [
            BoxShadow(
              color: green.withValues(alpha: 0.025),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              width: double.infinity,
              child: Image.network(
                dish.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: softPink,
                  child: Icon(Icons.restaurant_rounded, color: green, size: 35),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(
                dish.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: green,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                dish.restaurant?.name ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: secondaryText, fontSize: 10),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 5, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${dish.price} FCFA',
                      style: const TextStyle(
                        color: secondaryText,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      foodlyCart.addItem(
                        id: dish.id.toString(),
                        name: dish.name.toString(),
                        restaurantName: restaurant?.name.toString() ?? "",
                        unitPrice: dish.price,
                        idRestaurant: restaurant?.id.toString() ?? "",
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${dish.name} ajouté au panier.'),
                          backgroundColor: green,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: green,
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

  // SECTION TITLE
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
              color: secondaryText,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              action,
              style: const TextStyle(
                color: darkPink,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  // ROUND ACTION + CART BADGE
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
          border: Border.all(color: lightBorder),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: green, size: 22),
            if (badge > 0)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 19,
                    minHeight: 19,
                  ),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: green,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badge > 99 ? '99+' : '$badge',
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

  // PLACEHOLDER
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
                color: softPink,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 43, color: green),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: green,
                fontWeight: FontWeight.w800,
                fontSize: 23,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: secondaryText, height: 1.5),
            ),
            const SizedBox(height: 18),
            const Text(
              'Cette partie sera développée ensuite.',
              style: TextStyle(color: darkPink, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
