import 'package:flutter/material.dart';
import 'package:foodly/Customer/food_detail_page.dart';
import 'package:foodly/Customer/food_detail_screen.dart';
import 'package:foodly/model/dishes_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:foodly/model/restaurant_model.dart';
import 'package:foodly/service/restaurant_service.dart';

const Color foodlyOrange = Color(0xFFF56624);
const Color foodlyGreen = Color(0xFF173D32);
const Color foodlyBackground = Color(0xFFFAF8F3);

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  GoogleMapController? _mapController;

  Position? _currentPosition;

  final TextEditingController _searchController = TextEditingController();

  final RestaurantService _restaurantService = RestaurantService();

  List<RestaurantModel> _restaurants = [];

  bool _loadingLocation = false;
  bool _isLoadingRestaurants = true;

  String? _locationError;
  String? _restaurantError;

  String _selectedCategory = 'Tous';
  String _searchQuery = '';

  static const LatLng _dakarPosition = LatLng(14.6928, -17.4467);

  // --------------------------------------------------
  // INITIALISATION
  // --------------------------------------------------

  @override
  void initState() {
    super.initState();

    _fetchRestaurants();
    _fetchDishes();
    _getCurrentLocation();
  }

  // --------------------------------------------------
  // CHARGEMENT DES RESTAURANTS DEPUIS L'API
  // --------------------------------------------------

  Future<void> _fetchRestaurants() async {
    if (!mounted) return;

    setState(() {
      _isLoadingRestaurants = true;
      _restaurantError = null;
    });

    try {
      final result = await _restaurantService.fetchRestaurants();

      if (!mounted) return;

      setState(() {
        _restaurants = result;
        _isLoadingRestaurants = false;
      });

      debugPrint('Explorer : ${_restaurants.length} restaurants chargés');
    } catch (error) {
      debugPrint('Erreur chargement restaurants : $error');

      if (!mounted) return;

      setState(() {
        _isLoadingRestaurants = false;
        _restaurantError = 'Impossible de charger les restaurants.';
      });
    }
  }

  // --------------------------------------------------
  // CATÉGORIES DYNAMIQUES
  // --------------------------------------------------

  List<String> get _categories {
    final categories = _restaurants
        .map((restaurant) => restaurant.restaurantType.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();

    categories.sort();

    return ['Tous', ...categories];
  }

  // --------------------------------------------------
  // FILTRAGE ET RECHERCHE
  // --------------------------------------------------

  List<RestaurantModel> get _filteredRestaurants {
    final query = _searchQuery.trim().toLowerCase();

    return _restaurants.where((restaurant) {
      final categoryMatches =
          _selectedCategory == 'Tous' ||
          restaurant.restaurantType == _selectedCategory;

      final searchMatches =
          query.isEmpty ||
          restaurant.name.toLowerCase().contains(query) ||
          restaurant.restaurantType.toLowerCase().contains(query) ||
          restaurant.address.toLowerCase().contains(query) ||
          restaurant.description.toLowerCase().contains(query);

      return categoryMatches && searchMatches;
    }).toList();
  }

  // --------------------------------------------------
  // MARQUEURS GOOGLE MAPS
  // --------------------------------------------------

  Set<Marker> get _markers {
    return _filteredRestaurants
        .where((restaurant) {
          return restaurant.latitude != 0 &&
              restaurant.longitude != 0 &&
              restaurant.latitude >= -90 &&
              restaurant.latitude <= 90 &&
              restaurant.longitude >= -180 &&
              restaurant.longitude <= 180;
        })
        .map((restaurant) {
          return Marker(
            markerId: MarkerId(restaurant.id),
            position: LatLng(restaurant.latitude, restaurant.longitude),
            infoWindow: InfoWindow(
              title: restaurant.name,
              snippet: restaurant.address,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            onTap: () => _showRestaurant(restaurant),
          );
        })
        .toSet();
  }

  // --------------------------------------------------
  // GÉOLOCALISATION
  // --------------------------------------------------

  Future<void> _getCurrentLocation() async {
    if (_loadingLocation) return;

    setState(() {
      _loadingLocation = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Active le GPS de ton téléphone.');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Autorisation de localisation refusée.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Autorise la localisation dans les paramètres du téléphone.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
      });

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _locationError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  // --------------------------------------------------
  // RECHERCHE
  // --------------------------------------------------

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  List<DishesModel> _dishes = [];
  Future<void> _fetchDishes() async {
    try {
      final result = await _restaurantService.fetchDishes(idRestaurants: "");

      if (!mounted) return;

      setState(() {
        _dishes = result;
      });
    } catch (error) {
      debugPrint('Erreur chargement des plats : $error');
    }
  }
  // --------------------------------------------------
  // DÉPLACEMENT VERS UN RESTAURANT
  // --------------------------------------------------

  Future<void> _moveToRestaurant(RestaurantModel restaurant) async {
    if (restaurant.latitude == 0 || restaurant.longitude == 0) {
      _showRestaurant(restaurant);
      return;
    }

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(restaurant.latitude, restaurant.longitude),
        16,
      ),
    );

    if (!mounted) return;

    _showRestaurant(restaurant);
  }

  // --------------------------------------------------
  // DÉTAIL DU RESTAURANT
  // --------------------------------------------------

  void _showRestaurant(RestaurantModel restaurant) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 65,
                      height: 65,
                      child: restaurant.logoUrl.isNotEmpty
                          ? Image.network(
                              restaurant.logoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return _restaurantPlaceholder();
                              },
                            )
                          : _restaurantPlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: foodlyGreen,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          restaurant.restaurantType,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                restaurant.description.isNotEmpty
                    ? restaurant.description
                    : 'Découvrez les spécialités de ce restaurant.',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),

              const SizedBox(height: 12),

              if (restaurant.address.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: foodlyOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        restaurant.address,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber),
                  const SizedBox(width: 5),
                  Text(
                    restaurant.reviewNote.isNotEmpty
                        ? restaurant.reviewNote
                        : 'Nouveau',
                  ),
                  const Spacer(),
                  Icon(
                    restaurant.isOpen ? Icons.circle : Icons.circle_outlined,
                    color: restaurant.isOpen ? Colors.green : Colors.grey,
                    size: 10,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    restaurant.isOpen ? 'Ouvert' : 'Fermé',
                    style: TextStyle(
                      color: restaurant.isOpen ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);

                    final restaurantDishes = _dishes.where((dish) {
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: foodlyOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Voir le restaurant',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _restaurantPlaceholder() {
    return Container(
      color: foodlyBackground,
      child: const Icon(Icons.restaurant, color: foodlyOrange, size: 30),
    );
  }

  // --------------------------------------------------
  // DISPOSE
  // --------------------------------------------------

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // INTERFACE
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final initialPosition = _currentPosition == null
        ? _dakarPosition
        : LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    final restaurants = _filteredRestaurants;

    return Scaffold(
      backgroundColor: foodlyBackground,
      body: SafeArea(
        child: Column(
          children: [
            // EN-TÊTE
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explorer',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: foodlyGreen,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Trouve un restaurant près de toi',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    onPressed: _getCurrentLocation,
                    tooltip: 'Ma position',
                    style: IconButton.styleFrom(
                      backgroundColor: foodlyOrange,
                      foregroundColor: Colors.white,
                    ),
                    icon: _loadingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),

            // RECHERCHE
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Restaurant, pizza, burger...',
                  hintStyle: const TextStyle(
                    color: Colors.black45,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: foodlyOrange,
                    size: 25,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Effacer la recherche',
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.12),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: foodlyOrange,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // CATÉGORIES
            SizedBox(
              height: 45,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final selected = category == _selectedCategory;

                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    selectedColor: foodlyGreen,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : foodlyGreen,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // GOOGLE MAPS
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: initialPosition,
                      zoom: 13,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;

                      if (_currentPosition != null) {
                        controller.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            14,
                          ),
                        );
                      }
                    },
                    markers: _markers,
                    myLocationEnabled: _currentPosition != null,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                ),
              ),
            ),

            // ERREUR DE LOCALISATION
            // if (_locationError != null)
            //   Padding(
            //     padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            //     child: Text(
            //       _locationError!,
            //       style: const TextStyle(color: Colors.red, fontSize: 12),
            //     ),
            //   ),

            // TITRE DES RÉSULTATS
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Restaurants à découvrir',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: foodlyGreen,
                      ),
                    ),
                  ),
                  Text(
                    '${restaurants.length} résultat'
                    '${restaurants.length > 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            // LISTE DES RESTAURANTS
            SizedBox(
              height: 130,
              child: _isLoadingRestaurants
                  ? const Center(
                      child: CircularProgressIndicator(color: foodlyOrange),
                    )
                  : _restaurantError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _restaurantError!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                            TextButton(
                              onPressed: _fetchRestaurants,
                              child: const Text(
                                'Réessayer',
                                style: TextStyle(color: foodlyOrange),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : restaurants.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 30,
                              color: Colors.black38,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Aucun restaurant trouvé pour « $_searchQuery ».'
                                  : 'Aucun restaurant disponible.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: restaurants.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final restaurant = restaurants[index];

                        return InkWell(
                          onTap: () => _moveToRestaurant(restaurant),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 235,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurant.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: foodlyGreen,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  restaurant.restaurantType,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      restaurant.reviewNote.isNotEmpty
                                          ? restaurant.reviewNote
                                          : 'Nouveau',
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.location_on_outlined,
                                      color: foodlyOrange,
                                      size: 18,
                                    ),
                                    const Text(
                                      'Sur la carte',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
