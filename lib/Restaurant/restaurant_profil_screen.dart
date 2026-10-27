import 'package:flutter/material.dart';
import 'package:foodly/Customer/food_detail_screen.dart';
import 'package:foodly/Restaurant/retaurant_data.dart'
    hide foodlyGreen, foodlyBackground, foodlyOrange;

class RestaurantProfileScreen extends StatefulWidget {
  const RestaurantProfileScreen({super.key});

  @override
  State<RestaurantProfileScreen> createState() =>
      _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState extends State<RestaurantProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _descriptionController;

  bool _isOpen = true;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: restaurantData.name);
    _addressController = TextEditingController(text: restaurantData.address);
    _phoneController = TextEditingController(text: restaurantData.phone);
    _emailController = TextEditingController(text: restaurantData.email);
    _descriptionController = TextEditingController(
      text: restaurantData.description,
    );

    _isOpen = restaurantData.isOpen;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    restaurantData.updateRestaurant(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      description: _descriptionController.text.trim(),
      isOpen: _isOpen,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil du restaurant mis à jour.'),
        backgroundColor: foodlyGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: foodlyBackground,
      appBar: AppBar(
        backgroundColor: foodlyBackground,
        title: const Text(
          'Mon restaurant',
          style: TextStyle(color: foodlyGreen, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: foodlyGreen,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _nameController.text.isEmpty
                        ? 'Mon restaurant'
                        : _nameController.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _isOpen ? 'Ouvert aux commandes' : 'Fermé',
                    style: TextStyle(
                      color: _isOpen ? Colors.greenAccent : Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Informations générales',
              style: TextStyle(
                fontSize: 19,
                color: foodlyGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _field(
              controller: _nameController,
              label: 'Nom du restaurant',
              icon: Icons.storefront_outlined,
              validator: _required,
              onChanged: (_) => setState(() {}),
            ),
            _field(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description_outlined,
              maxLines: 3,
              validator: _required,
            ),
            _field(
              controller: _addressController,
              label: 'Adresse',
              icon: Icons.location_on_outlined,
              validator: _required,
            ),
            _field(
              controller: _phoneController,
              label: 'Téléphone',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _required,
            ),
            _field(
              controller: _emailController,
              label: 'Adresse e-mail',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L’e-mail est obligatoire.';
                }
                if (!RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                ).hasMatch(value.trim())) {
                  return 'Adresse e-mail invalide.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Restaurant ouvert',
                  style: TextStyle(
                    color: foodlyGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _isOpen
                      ? 'Tu peux recevoir des commandes.'
                      : 'Les clients ne doivent pas commander.',
                ),
                value: _isOpen,
                activeThumbColor: foodlyOrange,
                onChanged: (value) {
                  setState(() => _isOpen = value);
                },
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Enregistrer les modifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: foodlyOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire.';
    }
    return null;
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: foodlyOrange),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFECEAE4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: foodlyOrange),
          ),
        ),
      ),
    );
  }
}
