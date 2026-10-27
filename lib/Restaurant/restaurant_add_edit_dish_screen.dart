import 'package:flutter/material.dart';
import 'package:foodly/Customer/food_detail_screen.dart';
import 'package:foodly/Restaurant/retaurant_data.dart'
    hide foodlyBackground, foodlyGreen, foodlyOrange;

class RestaurantAddEditDishScreen extends StatefulWidget {
  final RestaurantDish? dish;

  const RestaurantAddEditDishScreen({super.key, this.dish});

  @override
  State<RestaurantAddEditDishScreen> createState() =>
      _RestaurantAddEditDishScreenState();
}

class _RestaurantAddEditDishScreenState
    extends State<RestaurantAddEditDishScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;

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

  void _saveDish() {
    if (!_formKey.currentState!.validate()) return;

    final dish = RestaurantDish(
      id: widget.dish?.id ?? 'dish_${DateTime.now().microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      category: _category,
      imageUrl: _imageController.text.trim(),
      isAvailable: _isAvailable,
    );

    if (_isEditing) {
      restaurantData.updateDish(dish);
    } else {
      restaurantData.addDish(dish);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: foodlyBackground,
      appBar: AppBar(
        backgroundColor: foodlyBackground,
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
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: foodlyOrange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: foodlyOrange,
                size: 48,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pour le moment, indique une URL d’image. '
              'L’envoi réel d’une photo sera ajouté avec le stockage backend.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 22),
            _label('Nom du plat'),
            TextFormField(
              controller: _nameController,
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
              decoration: _decoration('Choisir une catégorie'),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 18),
            _label('URL de l’image (facultatif)'),
            TextFormField(
              controller: _imageController,
              keyboardType: TextInputType.url,
              decoration: _decoration('https://exemple.com/plat.jpg'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Plat disponible'),
              subtitle: const Text('Les clients peuvent commander ce plat.'),
              value: _isAvailable,
              activeThumbColor: foodlyOrange,
              onChanged: (value) => setState(() => _isAvailable = value),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _saveDish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: foodlyOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
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
        borderSide: const BorderSide(color: foodlyOrange),
      ),
    );
  }
}
