import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const Color foodlyOrange = Color(0xFFF56624);
const Color foodlyGreen = Color(0xFF173D32);
const Color foodlyBackground = Color(0xFFFAF8F3);

class RestaurantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final List<Map<String, dynamic>> dishes;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
    this.dishes = const [],
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  GoogleMapController? _mapController;

  Map<String, dynamic> get restaurant => widget.restaurant;

  String _text(String key, [String fallback = '']) {
    return restaurant[key]?.toString() ?? fallback;
  }

  double _coordinate(String key, double fallback) {
    final value = restaurant[key];

    if (value is num) return value.toDouble();

    if (value is String) {
      return double.tryParse(value.trim()) ?? fallback;
    }

    return fallback;
  }

  double get latitude => _coordinate('latitude', 14.6928);

  double get longitude => _coordinate('longitude', -17.4467);

  String get name => _text('name', 'Restaurant');

  String get imageUrl => _text('image');

  String get category => _text('category', 'Restaurant');

  String get cuisine => _text('cuisine', category);

  String get description =>
      _text('description', 'Découvrez les spécialités de $name.');

  String get rating => _text('rating', '4.5');

  String get deliveryTime => _text('time', '20-30 min');

  Color get restaurantColor {
    final color = restaurant['color'];
    return color is Color ? color : foodlyGreen;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _openDirections() async {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '$latitude,$longitude',
      'travelmode': 'driving',
    });

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'ouvrir l'itinéraire.")),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir Google Maps.")),
      );
    }
  }

  void _openMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RestaurantMenuScreen(restaurant: restaurant, dishes: widget.dishes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final position = LatLng(latitude, longitude);

    return Scaffold(
      backgroundColor: foodlyBackground,
      body: CustomScrollView(
        slivers: [
          // Même image que sur la Home page
          SliverAppBar(
            expandedHeight: 270,
            pinned: true,
            backgroundColor: foodlyGreen,
            foregroundColor: Colors.white,
            title: const Text('Restaurant'),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _restaurantImage(),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black26,
                          Colors.transparent,
                          Colors.black38,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Nom et note
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: foodlyGreen,
                  ),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _infoBadge(Icons.restaurant, category),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF5A623),
                          size: 22,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Temps de livraison
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: foodlyOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.delivery_dining_rounded,
                          color: foodlyOrange,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Temps de livraison estimé',
                              style: TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              deliveryTime,
                              style: const TextStyle(
                                color: foodlyGreen,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                const Text(
                  'À propos du restaurant',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: foodlyGreen,
                  ),
                ),
                const SizedBox(height: 9),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.6,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  cuisine,
                  style: const TextStyle(
                    color: foodlyGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 28),

                // Localisation Google Maps
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: foodlyOrange,
                      size: 25,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Où nous trouver ?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: foodlyGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: SizedBox(
                    height: 230,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: position,
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('restaurant'),
                          position: position,
                          infoWindow: InfoWindow(title: name, snippet: cuisine),
                        ),
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      mapToolbarEnabled: false,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _openDirections,
                  icon: const Icon(Icons.directions_rounded),
                  label: const Text('Obtenir l’itinéraire'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: foodlyGreen,
                    side: const BorderSide(color: foodlyGreen),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Aperçu du menu
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Quelques plats du menu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: foodlyGreen,
                        ),
                      ),
                    ),
                    if (widget.dishes.isNotEmpty)
                      TextButton(
                        onPressed: _openMenu,
                        child: const Text(
                          'Voir tout',
                          style: TextStyle(color: foodlyOrange),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                if (widget.dishes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Le menu de ce restaurant sera bientôt disponible.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                else
                  ...widget.dishes.take(2).map((dish) => _dishPreview(dish)),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: _openMenu,
                  icon: const Icon(Icons.restaurant_menu_rounded),
                  label: const Text(
                    'Voir le menu complet',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: foodlyOrange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _restaurantImage() {
    if (imageUrl.isEmpty) {
      return _imageFallback();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imageFallback(),
    );
  }

  Widget _imageFallback() {
    return ColoredBox(
      color: restaurantColor,
      child: const Center(
        child: Icon(Icons.restaurant_rounded, color: Colors.white, size: 75),
      ),
    );
  }

  Widget _infoBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: foodlyGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foodlyGreen, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: foodlyGreen,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dishPreview(Map<String, dynamic> dish) {
    final image = dish['image']?.toString() ?? '';
    final price = dish['price']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 72,
              width: 78,
              child: image.isEmpty
                  ? const ColoredBox(
                      color: Color(0xFFFFE9D9),
                      child: Icon(Icons.restaurant, color: foodlyOrange),
                    )
                  : Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Color(0xFFFFE9D9),
                        child: Icon(Icons.restaurant, color: foodlyOrange),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish['name']?.toString() ?? 'Plat',
                  style: const TextStyle(
                    color: foodlyGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  price,
                  style: const TextStyle(
                    color: foodlyOrange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.black38),
        ],
      ),
    );
  }
}

// ======================================================
// PAGE MENU DU RESTAURANT
// ======================================================

class RestaurantMenuScreen extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final List<Map<String, dynamic>> dishes;

  const RestaurantMenuScreen({
    super.key,
    required this.restaurant,
    required this.dishes,
  });

  @override
  Widget build(BuildContext context) {
    final name = restaurant['name']?.toString() ?? 'Restaurant';
    final image = restaurant['image']?.toString() ?? '';
    final color = restaurant['color'] is Color
        ? restaurant['color'] as Color
        : foodlyGreen;

    return Scaffold(
      backgroundColor: foodlyBackground,
      appBar: AppBar(
        backgroundColor: foodlyBackground,
        foregroundColor: foodlyGreen,
        elevation: 0,
        title: const Text(
          'Notre menu',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    height: 72,
                    width: 78,
                    child: image.isEmpty
                        ? ColoredBox(
                            color: color,
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 35,
                            ),
                          )
                        : Image.network(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: color,
                              child: const Icon(
                                Icons.restaurant,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: foodlyGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${dishes.length} plat${dishes.length > 1 ? 's' : ''} disponible${dishes.length > 1 ? 's' : ''}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Tous nos plats',
              style: TextStyle(
                color: foodlyGreen,
                fontWeight: FontWeight.w800,
                fontSize: 21,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: dishes.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Aucun plat disponible pour le moment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: dishes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final dish = dishes[index];
                      final dishImage = dish['image']?.toString() ?? '';

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                height: 100,
                                width: 105,
                                child: dishImage.isEmpty
                                    ? const ColoredBox(
                                        color: Color(0xFFFFE9D9),
                                        child: Icon(
                                          Icons.restaurant,
                                          color: foodlyOrange,
                                          size: 35,
                                        ),
                                      )
                                    : Image.network(
                                        dishImage,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const ColoredBox(
                                              color: Color(0xFFFFE9D9),
                                              child: Icon(
                                                Icons.restaurant,
                                                color: foodlyOrange,
                                                size: 35,
                                              ),
                                            ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dish['name']?.toString() ?? 'Plat',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: foodlyGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    dish['price']?.toString() ?? '',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: foodlyOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
