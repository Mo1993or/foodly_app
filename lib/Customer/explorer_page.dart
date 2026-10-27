import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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

  bool _loadingLocation = false;
  String? _locationError;
  String _selectedCategory = 'Tous';

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  final List<Map<String, dynamic>> _restaurants = [
    {
      'id': 'restaurant_1',
      'name': 'Chez Awa',
      'category': 'Sénégalais',
      'rating': 4.7,
      'latitude': 14.6928,
      'longitude': -17.4467,
      'description': 'Cuisine sénégalaise traditionnelle',
    },
    {
      'id': 'restaurant_2',
      'name': 'Le Gourmet',
      'category': 'Fast-food',
      'rating': 4.5,
      'latitude': 14.6995,
      'longitude': -17.4570,
      'description': 'Burgers et repas rapides',
    },
    {
      'id': 'restaurant_3',
      'name': 'Saveurs du Terroir',
      'category': 'Sénégalais',
      'rating': 4.8,
      'latitude': 14.6810,
      'longitude': -17.4520,
      'description': 'Des plats locaux faits maison',
    },
    {
      'id': 'restaurant_4',
      'name': 'Pizza House',
      'category': 'Pizza',
      'rating': 4.4,
      'latitude': 14.7050,
      'longitude': -17.4400,
      'description': 'Pizzas et spécialités italiennes',
    },
  ];

  final List<String> _categories = ['Tous', 'Sénégalais', 'Fast-food', 'Pizza'];

  // Recherche par nom, catégorie ou description,
  // combinée avec le filtre de catégorie sélectionné.
  List<Map<String, dynamic>> get _filteredRestaurants {
    final query = _searchQuery.trim().toLowerCase();

    return _restaurants.where((restaurant) {
      final categoryMatches =
          _selectedCategory == 'Tous' ||
          restaurant['category'] == _selectedCategory;

      final name = restaurant['name'].toString().toLowerCase();
      final category = restaurant['category'].toString().toLowerCase();
      final description = restaurant['description'].toString().toLowerCase();

      final searchMatches =
          query.isEmpty ||
          name.contains(query) ||
          category.contains(query) ||
          description.contains(query);

      return categoryMatches && searchMatches;
    }).toList();
  }

  Set<Marker> get _markers {
    return _filteredRestaurants.map((restaurant) {
      final id = restaurant['id'].toString();

      return Marker(
        markerId: MarkerId(id),
        position: LatLng(
          (restaurant['latitude'] as num).toDouble(),
          (restaurant['longitude'] as num).toDouble(),
        ),
        infoWindow: InfoWindow(
          title: restaurant['name'].toString(),
          snippet: restaurant['description'].toString(),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () => _showRestaurant(restaurant),
      );
    }).toSet();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

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
        setState(() => _loadingLocation = false);
      }
    }
  }

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

  Future<void> _moveToRestaurant(Map<String, dynamic> restaurant) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          (restaurant['latitude'] as num).toDouble(),
          (restaurant['longitude'] as num).toDouble(),
        ),
        16,
      ),
    );

    if (!mounted) return;
    _showRestaurant(restaurant);
  }

  void _showRestaurant(Map<String, dynamic> restaurant) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant['name'].toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: foodlyGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(restaurant['description'].toString()),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber),
                  const SizedBox(width: 5),
                  Text('${restaurant['rating']}'),
                  const SizedBox(width: 12),
                  Text(
                    restaurant['category'].toString(),
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Restaurant sélectionné : '
                          '${restaurant['name']}',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: foodlyOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Voir le restaurant'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = _currentPosition == null
        ? const LatLng(14.6928, -17.4467)
        : LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    final restaurants = _filteredRestaurants;

    return Scaffold(
      backgroundColor: foodlyBackground,
      body: SafeArea(
        child: Column(
          children: [
            // En-tête
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

            // Champ de recherche
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

            // Filtres par catégorie
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

            // Carte Google Maps avec marqueurs filtrés
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

            // Erreur de géolocalisation
            if (_locationError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  _locationError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            // Titre et nombre de résultats
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

            // Résultats de recherche
            SizedBox(
              height: 130,
              child: restaurants.isEmpty
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
                              'Aucun restaurant trouvé'
                              '${_searchQuery.isNotEmpty ? ' pour « $_searchQuery »' : ''}.',
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
                                  restaurant['name'].toString(),
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
                                  restaurant['category'].toString(),
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
                                    Text('${restaurant['rating']}'),
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
