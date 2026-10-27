import 'package:flutter/material.dart';
import 'package:foodly/Customer/customer_page.dart';
import 'package:foodly/Customer/food_detail_screen.dart';
import 'package:foodly/Restaurant/restaurant_dashbord_screen.dart';
import 'package:foodly/Restaurant/restaurant_offer_screen.dart';
import 'package:foodly/service/auth_service.dart';

class RestaurantLoginScreen extends StatefulWidget {
  const RestaurantLoginScreen({super.key});

  @override
  State<RestaurantLoginScreen> createState() => _RestaurantLoginScreenState();
}

class _RestaurantLoginScreenState extends State<RestaurantLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulation temporaire de l'authentification.
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    try {
      var data = {
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
      };
      var result = await AuthService().signIn(data);
      print("result $result");
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RestaurantOffersScreen()),
      );
    } catch (error) {
      print("error $error");
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Une erreur est survenue. Réessaie.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: foodlyBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: foodlyGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Espace restaurateur',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    color: foodlyGreen,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Connecte-toi pour gérer ton restaurant, '
                  'tes commandes et ton menu.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Adresse e-mail',
                  style: TextStyle(
                    color: foodlyGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _decoration(
                    hint: 'restaurant@exemple.com',
                    icon: Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Entre ton adresse e-mail.';
                    }

                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value.trim())) {
                      return 'Adresse e-mail invalide.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 22),
                const Text(
                  'Mot de passe',
                  style: TextStyle(
                    color: foodlyGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration:
                      _decoration(
                        hint: 'Ton mot de passe',
                        icon: Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Entre ton mot de passe.';
                    }

                    if (value.length < 6) {
                      return '6 caractères minimum.';
                    }

                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'La récupération du mot de passe '
                            'sera disponible avec le backend.',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(color: foodlyOrange),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: foodlyOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CustomerHomeScreen(),
                      ),
                    );
                  },
                  child: Center(
                    child: Text(
                      'Foodly • retour sur les plats',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
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
    );
  }
}
