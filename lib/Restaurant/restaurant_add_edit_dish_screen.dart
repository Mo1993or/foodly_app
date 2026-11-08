import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodly/Restaurant/restaurant_dashbord_screen.dart';
import 'package:foodly/model/dishes_model.dart';
import 'package:foodly/model/restaurant_model.dart';
import 'package:foodly/service/auth_service.dart';
import 'package:foodly/service/restaurant_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foodly/Customer/food_detail_screen.dart';
import 'package:foodly/Restaurant/retaurant_data.dart'
    hide foodlyBackground, foodlyGreen, foodlyOrange;

class RestaurantAddEditDishScreen extends StatefulWidget {
  final DishesModel? dish;
  final RestaurantModel? restaurant;
  const RestaurantAddEditDishScreen({super.key, this.dish, this.restaurant});

  @override
  State<RestaurantAddEditDishScreen> createState() =>
      _RestaurantAddEditDishScreenState();
}

class _RestaurantAddEditDishScreenState
    extends State<RestaurantAddEditDishScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;

  File? _selectedImage;
  bool _isPickingImage = false;
  bool _isSaving = false;

  String _category = 'Plats locaux';
  bool _isAvailable = true;

  final List<String> _categories = [
    'Plats locaux',
    'Fast-food',
    'Pizzas',
    'Burgers',
    'Desserts',
    'Boissons',
    'Autres',
  ];

  bool get _isEditing => widget.dish != null;

  @override
  void initState() {
    super.initState();

    final dish = widget.dish;

    _nameController = TextEditingController(text: dish?.name ?? '');
    _descriptionController = TextEditingController(
      text: dish?.description ?? '',
    );
    _priceController = TextEditingController(
      text: dish == null ? '' : dish.price.toString(),
    );
    _imageController = TextEditingController(text: dish?.imageUrl ?? '');

    if (dish != null) {
      _category = _categories.contains(dish.category)
          ? dish.category
          : 'Autres';
      _isAvailable = dish.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    setState(() => _isPickingImage = true);

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (!mounted) return;

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _uploadMedia(image.path, "plat");
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir la galerie. Réessaie.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  var imageUrl = "";
  _uploadMedia(data, String typeMedia) async {
    try {
      var result = await AuthService().uploadMedia(data);
      print("result $result");

      setState(() {
        imageUrl = result;
      });
    } catch (error) {
      print("erreur upload $error");
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
      _imageController.clear();
    });
  }

  Future<void> _saveDish() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    // Important : image_picker fournit un chemin local.
    // Pour un enregistrement permanent sur un autre appareil,
    // la photo devra être téléversée sur Cloudinary ou ton backend.
    // final imageUrl = _selectedImage != null
    //     ? _selectedImage!.path
    //     : _imageController.text.trim();

    print("resto ${widget.restaurant?.id}");
    var dish = {
      "restaurantId": widget.restaurant?.id,
      "name": _nameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "price": int.parse(_priceController.text.trim()),
      "category": _category,
      "imageUrl": imageUrl,
      "isAvailable": _isAvailable,
    };

    setState(() => _isSaving = true);

    try {
      // if (_isEditing) {
      //   restaurantData.updateDish(dish);
      // } else {
      //   restaurantData.addDish(dish);
      // }
      var result = await RestaurantService().registerDishes(dish);
      setState(() => _isSaving = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RestaurantDashboardScreen(
            selectedOffer: widget.restaurant?.activeOffer ?? "",
            restaurant: widget.restaurant,
            statusPayment: '',
          ),
        ),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('plat rajouté')));
    } catch (e) {
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d’enregistrer le plat : $e')),
      );
    }
  }

  Widget _buildImagePicker() {
    final hasSelectedImage = _selectedImage != null;
    final imageUrl = _imageController.text.trim();
    final hasNetworkImage =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: foodlyOrange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: foodlyOrange.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasSelectedImage
                ? Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _emptyImagePlaceholder();
                    },
                  )
                : hasNetworkImage
                ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _emptyImagePlaceholder();
                    },
                  )
                : _emptyImagePlaceholder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isPickingImage ? null : _pickImage,
                icon: _isPickingImage
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library_outlined),
                label: Text(
                  hasSelectedImage || hasNetworkImage
                      ? 'Changer la photo'
                      : 'Choisir dans la galerie',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: foodlyGreen,
                  side: const BorderSide(color: foodlyGreen),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            if (hasSelectedImage || hasNetworkImage) ...[
              const SizedBox(width: 10),
              IconButton(
                tooltip: 'Supprimer la photo',
                onPressed: _removeSelectedImage,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.08),
                  foregroundColor: Colors.red,
                ),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Formats conseillés : JPG, PNG ou WebP.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _emptyImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: foodlyOrange.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: foodlyOrange,
            size: 42,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Ajouter une photo du plat',
          style: TextStyle(
            color: foodlyGreen,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Appuie ici pour ouvrir ta galerie',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: foodlyBackground,
      appBar: AppBar(
        backgroundColor: foodlyBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: foodlyGreen),
        title: Text(
          _isEditing ? 'Modifier le plat' : 'Ajouter un plat',
          style: const TextStyle(
            color: foodlyGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildImagePicker(),
            const SizedBox(height: 26),

            _label('Nom du plat'),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: _decoration('Ex. : Thieboudienne'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Le nom du plat est obligatoire.'
                  : null,
            ),

            const SizedBox(height: 18),

            _label('Description'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: _decoration('Décris les ingrédients et le plat'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Ajoute une description.'
                  : null,
            ),

            const SizedBox(height: 18),

            _label('Prix en FCFA'),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: _decoration('Ex. : 2500'),
              validator: (value) {
                final price = int.tryParse(value?.trim() ?? '');

                if (price == null || price <= 0) {
                  return 'Entre un prix valide supérieur à zéro.';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            _label('Catégorie'),
            DropdownButtonFormField<String>(
              value: _category,
              isExpanded: true,
              decoration: _decoration('Choisir une catégorie'),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),

            const SizedBox(height: 18),

            _label('URL de l’image (facultatif)'),
            TextFormField(
              controller: _imageController,
              keyboardType: TextInputType.url,
              decoration: _decoration('https://exemple.com/plat.jpg'),
              onChanged: (_) => setState(() {
                // Actualise l’aperçu de l’URL saisie.
              }),
            ),

            const SizedBox(height: 12),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: foodlyOrange,
              title: const Text(
                'Plat disponible',
                style: TextStyle(
                  color: foodlyGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('Les clients peuvent commander ce plat.'),
              value: _isAvailable,
              onChanged: (value) {
                setState(() => _isAvailable = value);
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveDish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: foodlyOrange,
                  disabledBackgroundColor: foodlyOrange.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing
                            ? 'Enregistrer les modifications'
                            : 'Ajouter le plat',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: foodlyGreen, fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFECEAE4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: foodlyOrange, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
