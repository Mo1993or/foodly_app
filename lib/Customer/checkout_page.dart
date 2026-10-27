import 'package:flutter/material.dart';
import 'package:foodly/Customer/customer_order_store.dart';
import 'package:foodly/Customer/panier_page.dart';

const Color foodlyOrange = Color(0xFFF56624);
const Color foodlyGreen = Color(0xFF173D32);
const Color foodlyBackground = Color(0xFFFAF8F3);

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // TODO : envoyer la commande à ton backend.
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final orderMap = foodlyCart.toOrderMap(
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      notes: _notesController.text.trim(),
    );

    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    clientOrdersStore.addOrder(
      ClientOrder(
        id: orderId,
        customerName: orderMap['customerName'] as String,
        phone: orderMap['phone'] as String,
        address: orderMap['address'] as String,
        notes: orderMap['notes'] as String? ?? '',
        items: List<Map<String, dynamic>>.from(orderMap['items']),
        totalPrice: orderMap['totalPrice'] as int,
        createdAt: DateTime.now(),
      ),
    );

    foodlyCart.clear();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(
          customerName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(
          customerName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: foodlyBackground,
      appBar: AppBar(
        title: const Text(
          'Finaliser ma commande',
          style: TextStyle(color: foodlyGreen, fontWeight: FontWeight.bold),
        ),
        backgroundColor: foodlyBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: foodlyGreen),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Tes coordonnées',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: foodlyGreen,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pas besoin de créer un compte pour commander.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            _buildLabel('Nom complet'),
            _buildField(
              controller: _nameController,
              hint: 'Ex. : Mamadou Diallo',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Entre ton nom complet';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildLabel('Téléphone'),
            _buildField(
              controller: _phoneController,
              hint: 'Ex. : 77 123 45 67',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().length < 8) {
                  return 'Entre un numéro de téléphone valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildLabel('Adresse de livraison'),
            _buildField(
              controller: _addressController,
              hint: 'Quartier, rue, repère...',
              icon: Icons.location_on_outlined,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Entre ton adresse de livraison';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildLabel('Instructions supplémentaires (facultatif)'),
            _buildField(
              controller: _notesController,
              hint: 'Ex. : appeler en arrivant',
              icon: Icons.edit_note_outlined,
              maxLines: 3,
              validator: (_) => null,
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: foodlyOrange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vérifie ton numéro et ton adresse avant de confirmer ta commande.',
                      style: TextStyle(color: foodlyGreen, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: foodlyOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Confirmer ma commande',
                        style: TextStyle(
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, color: foodlyGreen),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: foodlyGreen),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        errorMaxLines: 2,
      ),
    );
  }
}

class OrderConfirmationScreen extends StatelessWidget {
  final String customerName;
  final String phone;

  const OrderConfirmationScreen({
    super.key,
    required this.customerName,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: foodlyBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: foodlyGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: foodlyGreen,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Merci pour ta commande !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foodlyGreen,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bonjour $customerName, ta commande a été préparée.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Téléphone : $phone',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Attention : cette démonstration ne transmet pas encore la commande au restaurant.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: foodlyOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Retour à l’accueil'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
