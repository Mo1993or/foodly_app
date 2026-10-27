import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodly/Auth/login_screen.dart';
import 'package:foodly/service/auth_service.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class RestaurantRegistrationPage extends StatefulWidget {
  const RestaurantRegistrationPage({super.key});

  @override
  State<RestaurantRegistrationPage> createState() =>
      _RestaurantRegistrationPageState();
}

class _RestaurantRegistrationPageState
    extends State<RestaurantRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _restaurantController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneCommercialController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final descriptionController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  final Color _orange = const Color(0xFFF56624);
  final Color _green = const Color(0xFF173D32);
  final Color _background = const Color(0xFFFAF8F3);

  File? _logo;
  String logoString = "";
  String coverString = "";
  File? _coverFile;
  bool _obscurePassword = true;
  bool _loading = false;
  bool _resolvingAddress = false;
  final TextEditingController _locationSearchController =
      TextEditingController();

  static const String _googlePlacesApiKey =
      'AIzaSyBDhN3cbJWJRRgVBtikVjp5o0_r0yO-yns';
  String? _selectedRestaurantType;

  GoogleMapController? _mapController;

  // Position initiale : Dakar, Sénégal.
  LatLng _restaurantPosition = const LatLng(14.7167, -17.4677);

  bool _locationSelected = false;

  final List<String> _restaurantTypes = [
    'Restaurant traditionnel',
    'Fast-food',
    'Pizzeria',
    'Grillades',
    'Cuisine sénégalaise',
    'Cuisine africaine',
    'Cuisine asiatique',
    'Pâtisserie',
    'Boulangerie',
    'Café',
    'Jus et boissons',
    'Restaurant gastronomique',
    'Végétarien',
    'Fruits de mer',
    'Autre',
  ];

  final List<Color> _restaurantColors = [];

  @override
  void dispose() {
    _restaurantController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _phoneCommercialController.dispose();
    _addressController.dispose();
    descriptionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _pickLogo() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image != null && mounted) {
        setState(() {
          _logo = File(image.path);
        });
        await _uploadMedia(image.path, "logo");
      }
    } catch (_) {
      _showMessage('Impossible de sélectionner cette image.');
    }
  }

  Future<void> _pickCover() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image != null && mounted) {
        setState(() => _coverFile = File(image.path));
      }
      await _uploadMedia(image?.path, "cover");
    } catch (_) {
      _showMessage('Impossible de sélectionner cette image.');
    }
  }

  Future<void> _openColorPicker() async {
    if (_restaurantColors.length >= 2) {
      _showMessage('Tu peux choisir deux couleurs maximum.');
      return;
    }

    Color selectedColor = _orange;

    final result = await showDialog<Color>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Personnalise tes couleurs',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            color: selectedColor,
            onColorChanged: (color) => selectedColor = color,
            width: 40,
            height: 40,
            borderRadius: 10,
            spacing: 8,
            runSpacing: 8,
            wheelDiameter: 220,
            enableShadesSelection: true,
            showColorCode: true,
            colorCodeHasColor: true,
            pickersEnabled: const {
              ColorPickerType.wheel: true,
              ColorPickerType.accent: true,
              ColorPickerType.primary: true,
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, selectedColor);
            },
            child: const Text('Choisir'),
          ),
        ],
      ),
    );

    if (result == null || !mounted) return;

    if (_restaurantColors.any(
      (color) => color.toARGB32() == result.toARGB32(),
    )) {
      _showMessage('Cette couleur est déjà sélectionnée.');
      return;
    }

    setState(() => _restaurantColors.add(result));
  }

  void _removeColor(int index) {
    setState(() => _restaurantColors.removeAt(index));
  }

  // Convertit les coordonnées du marqueur en adresse lisible.
  Future<void> _updateRestaurantAddress(LatLng position) async {
    setState(() {
      _restaurantPosition = position;
      _locationSelected = true;
      _resolvingAddress = true;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final parts =
            [
                  place.name,
                  place.street,
                  place.subLocality,
                  place.locality,
                  place.administrativeArea,
                  place.country,
                ]
                .whereType<String>()
                .map((part) => part.trim())
                .where((part) => part.isNotEmpty)
                .toSet()
                .toList();

        if (parts.isNotEmpty) {
          _addressController.text = parts.join(', ');
        } else {
          _addressController.text =
              '${position.latitude.toStringAsFixed(6)}, '
              '${position.longitude.toStringAsFixed(6)}';
        }
      } else {
        _addressController.text =
            '${position.latitude.toStringAsFixed(6)}, '
            '${position.longitude.toStringAsFixed(6)}';
      }
    } catch (_) {
      if (!mounted) return;

      // Même si l'adresse ne peut pas être résolue,
      // les coordonnées GPS restent disponibles.
      _addressController.text =
          '${position.latitude.toStringAsFixed(6)}, '
          '${position.longitude.toStringAsFixed(6)}';

      _showMessage(
        'Coordonnées enregistrées. Tu peux préciser l’adresse manuellement.',
      );
    } finally {
      if (mounted) {
        setState(() => _resolvingAddress = false);
      }
    }
  }

  Future<void> _openLocationPicker() async {
    LatLng temporaryPosition = _restaurantPosition;
    GoogleMapController? mapController;
    bool confirmed = false;

    _locationSearchController.clear();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: _orange,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Emplacement du restaurant',
                                  style: TextStyle(
                                    color: _green,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Recherche une adresse ou déplace la carte.',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // RECHERCHE GOOGLE PLACES
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: GooglePlaceAutoCompleteTextField(
                        textEditingController: _locationSearchController,
                        googleAPIKey: _googlePlacesApiKey,
                        focusNode: FocusNode(),
                        debounceTime: 600,
                        countries: const ['sn'],
                        isLatLngRequired: true,
                        inputDecoration: InputDecoration(
                          hintText: 'Rechercher un quartier, une rue...',
                          prefixIcon: Icon(Icons.search_rounded, color: _green),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),

                        // Déplacer la carte vers le lieu choisi.
                        getPlaceDetailWithLatLng: (Prediction prediction) {
                          final latitude = double.tryParse(
                            prediction.lat ?? '',
                          );
                          final longitude = double.tryParse(
                            prediction.lng ?? '',
                          );

                          if (latitude == null || longitude == null) {
                            _showMessage(
                              'Impossible de récupérer les coordonnées du lieu.',
                            );
                            return;
                          }

                          final selectedPosition = LatLng(latitude, longitude);

                          temporaryPosition = selectedPosition;

                          setSheetState(() {});

                          mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(selectedPosition, 17),
                          );
                        },

                        itemClick: (Prediction prediction) {
                          _locationSearchController.text =
                              prediction.description ?? '';

                          _locationSearchController.selection =
                              TextSelection.collapsed(
                                offset: _locationSearchController.text.length,
                              );
                        },

                        seperatedBuilder: Divider(
                          height: 1,
                          color: Colors.grey.shade200,
                        ),

                        itemBuilder: (context, index, Prediction prediction) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: _orange,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    prediction.description ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },

                        isCrossBtnShown: true,
                      ),
                    ),

                    // CARTE
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: temporaryPosition,
                              zoom: 15,
                            ),
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: true,
                            mapToolbarEnabled: false,
                            onMapCreated: (controller) {
                              mapController = controller;
                            },
                            onCameraMove: (position) {
                              temporaryPosition = position.target;
                            },
                            onCameraIdle: () {
                              setSheetState(() {});
                            },
                            onTap: (position) {
                              temporaryPosition = position;
                              setSheetState(() {});

                              mapController?.animateCamera(
                                CameraUpdate.newLatLng(position),
                              );
                            },
                          ),

                          // Marqueur fixe au centre.
                          IgnorePointer(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 36),
                              child: Icon(
                                Icons.location_pin,
                                size: 48,
                                color: _orange,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Positioned(
                            top: 12,
                            right: 12,
                            child: Material(
                              color: Colors.white,
                              elevation: 3,
                              borderRadius: BorderRadius.circular(12),
                              child: IconButton(
                                tooltip: 'Recentrer la carte',
                                onPressed: () {
                                  mapController?.animateCamera(
                                    CameraUpdate.newLatLng(temporaryPosition),
                                  );
                                },
                                icon: Icon(Icons.my_location, color: _green),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // CONFIRMATION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coordonnées sélectionnées',
                            style: TextStyle(
                              color: _green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${temporaryPosition.latitude.toStringAsFixed(6)}, '
                            '${temporaryPosition.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                confirmed = true;
                                Navigator.pop(sheetContext);
                              },
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Confirmer cet emplacement'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
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
          },
        );
      },
    );

    if (confirmed && mounted) {
      _restaurantPosition = temporaryPosition;
      await _updateRestaurantAddress(temporaryPosition);
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: _green),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _orange, width: 1.5),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: _inputDecoration(
        label: label,
        icon: icon,
        hint: hint,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildRestaurantTypeField() {
    return DropdownButtonFormField<String>(
      value: _selectedRestaurantType,
      isExpanded: true,
      borderRadius: BorderRadius.circular(16),
      decoration: _inputDecoration(
        label: 'Type de restaurant',
        icon: Icons.restaurant_menu_rounded,
        hint: 'Choisis une catégorie',
      ),
      items: _restaurantTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedRestaurantType = value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Sélectionne le type de restaurant.';
        }
        return null;
      },
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          minLines: 1,
          decoration: _inputDecoration(
            label: 'Adresse du restaurant',
            hint: 'Quartier, rue, ville...',
            icon: Icons.location_on_outlined,
            suffixIcon: _resolvingAddress
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    onPressed: _openLocationPicker,
                    tooltip: 'Choisir sur la carte',
                    icon: Icon(Icons.map_outlined, color: _orange),
                  ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Sélectionne une adresse ou saisis-la.';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _openLocationPicker,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _orange.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.map_rounded, color: _orange, size: 23),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _locationSelected
                            ? 'Emplacement sélectionné'
                            : 'Choisir sur la carte',
                        style: TextStyle(
                          color: _green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _locationSelected
                            ? '${_restaurantPosition.latitude.toStringAsFixed(5)}, '
                                  '${_restaurantPosition.longitude.toStringAsFixed(5)}'
                            : 'Place un marqueur à l’emplacement exact.',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _orange),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logo du restaurant',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _green,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Facultatif : ajoute le logo de ton établissement.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.antiAlias,
              child: _logo != null
                  ? Image.file(_logo!, fit: BoxFit.cover)
                  : Icon(
                      Icons.add_a_photo_outlined,
                      size: 30,
                      color: _green.withValues(alpha: 0.7),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickLogo,
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  _logo == null ? 'Ajouter un logo' : 'Changer le logo',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _green,
                  side: BorderSide(color: _green.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (_logo != null)
              IconButton(
                onPressed: () => setState(() => _logo = null),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoverPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Couverture du restaurant',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _green,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Facultatif : ajoute la couverture de ton établissement.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.antiAlias,
              child: _coverFile != null
                  ? Image.file(_coverFile!, fit: BoxFit.cover)
                  : Icon(
                      Icons.add_a_photo_outlined,
                      size: 30,
                      color: _green.withValues(alpha: 0.7),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickCover,
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  _coverFile == null
                      ? 'Ajouter une couverture'
                      : 'Changer la couverture',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _green,
                  side: BorderSide(color: _green.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (_coverFile != null)
              IconButton(
                onPressed: () => setState(() => _coverFile = null),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Couleurs du restaurant',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _green,
                ),
              ),
            ),
            Text(
              '${_restaurantColors.length}/2',
              style: TextStyle(color: _orange, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Choisis une ou deux couleurs pour personnaliser ta vitrine.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            ...List.generate(_restaurantColors.length, (index) {
              final color = _restaurantColors[index];
              final hex = color
                  .toARGB32()
                  .toRadixString(16)
                  .substring(2)
                  .toUpperCase();

              return Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Positioned(
                        right: -4,
                        top: -4,
                        child: GestureDetector(
                          onTap: () => _removeColor(index),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('#$hex', style: const TextStyle(fontSize: 10)),
                ],
              );
            }),
            if (_restaurantColors.length < 2)
              GestureDetector(
                onTap: _openColorPicker,
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: _orange, width: 1.5),
                      ),
                      child: Icon(Icons.add, color: _orange, size: 28),
                    ),
                    const SizedBox(height: 6),
                    const Text('Ajouter', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: _orange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _green,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }

  _uploadMedia(data, String typeMedia) async {
    try {
      var result = await AuthService().uploadMedia(data);
      print("result $result");
      if (typeMedia == "logo") {
        setState(() {
          logoString = result;
        });
      } else {
        setState(() {
          coverString = result;
        });
      }
    } catch (error) {
      print("erreur upload $error");
    }
  }

  Future<void> _registerRestaurant() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_restaurantColors.isEmpty) {
      _showMessage('Choisis au moins une couleur.');
      return;
    }

    if (!_locationSelected) {
      _showMessage('Sélectionne l’emplacement du restaurant sur la carte.');
      return;
    }

    setState(() => _loading = true);

    try {
      // Inscription simulée en attendant l'API Node.js.
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      setState(() => _loading = false);

      List<String> colors = [];
      for (var element in _restaurantColors) {
        colors.add(
          "#" + element.toARGB32().toRadixString(16).substring(2).toUpperCase(),
        );
      }
      print("colors $colors");
      var data = {
        "ownerName": _ownerController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text,
        "restaurantName": _restaurantController.text.trim(),
        "address": _addressController.text.trim(),
        "phone": _phoneController.text.trim(),
        "commercialPhone": _phoneCommercialController.text.trim(),
        "restaurantType": _selectedRestaurantType,
        "description": descriptionController.text.trim(),
        "logoUrl": logoString,
        "coverPhotoUrl": coverString,
        "colors": colors,
        "latitude": _restaurantPosition.latitude,
        "longitude": _restaurantPosition.longitude,
      };
      var result = await AuthService().registerRestaurant(data);

      print("result $result");
      setState(() => _loading = false);

      _showMessage('Creation validé ! Connecte toi sur ton compte.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RestaurantLoginScreen()),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Une erreur est survenue. Réessaie.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: _green),
        ),
        title: Text(
          'Devenir restaurateur',
          style: TextStyle(
            color: _green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_green, const Color(0xFF245B49)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Ton restaurant mérite\nd’être sur Foodly.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Crée ton espace, choisis tes couleurs et indique où se trouve ton établissement.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildSection(
                title: 'Ton restaurant',
                subtitle: 'Présente ton établissement',
                icon: Icons.restaurant_rounded,
                children: [
                  _buildField(
                    controller: _restaurantController,
                    label: 'Nom du restaurant',
                    hint: 'Ex. : Chez Awa',
                    icon: Icons.store_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom du restaurant est obligatoire.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildRestaurantTypeField(),

                  const SizedBox(height: 16),

                  _buildAddressSection(),

                  const SizedBox(height: 22),

                  _buildLogoPicker(),

                  const SizedBox(height: 22),

                  _buildCoverPicker(),

                  const SizedBox(height: 24),

                  _buildColorSection(),
                  SizedBox(height: 16),
                  TextFormField(
                    cursorColor: _orange,
                    maxLines: 5,
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: _orange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _orange),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildSection(
                title: 'Tes informations',
                subtitle: 'Pour gérer ton espace restaurateur',
                icon: Icons.person_outline_rounded,
                children: [
                  _buildField(
                    controller: _ownerController,
                    label: 'Nom complet du responsable',
                    icon: Icons.badge_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Saisis le nom du responsable.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    controller: _phoneController,
                    label: 'Téléphone',
                    hint: 'Ex. : 77 123 45 67',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le téléphone est obligatoire.';
                      }
                      if (value.trim().length < 8) {
                        return 'Vérifie le numéro de téléphone.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    controller: _phoneCommercialController,
                    label: 'Téléphone Commercial',
                    hint: 'Ex. : 77 123 45 67 ou 33 890 98 98',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le téléphone  est obligatoire.';
                      }
                      if (value.trim().length < 8) {
                        return 'Vérifie le numéro de téléphone.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    controller: _emailController,
                    label: 'Adresse e-mail',
                    hint: 'contact@restaurant.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'L’e-mail est obligatoire.';
                      }
                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(value.trim())) {
                        return 'Saisis une adresse e-mail valide.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    hint: '8 caractères minimum',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _green,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Crée un mot de passe.';
                      }
                      if (value.length < 8) {
                        return '8 caractères minimum.';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 26),

              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: _loading ? null : _registerRestaurant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _orange.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Créer mon espace restaurant',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  'Configure ensuite ton offre Foodly et commence à gérer ton restaurant.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
