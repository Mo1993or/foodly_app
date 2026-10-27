// 3. CHOIX DU PROFIL

import 'package:flutter/material.dart';
import 'package:foodly/Auth/login_screen.dart';
import 'package:foodly/Customer/customer_page.dart';
import 'package:foodly/main.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: FoodlyApp.orange,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Bienvenue sur Foodly !',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: FoodlyApp.green,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Comment souhaitez-vous utiliser notre plateforme ?',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 35),
                _RoleCard(
                  icon: Icons.shopping_bag_rounded,
                  title: 'Je suis client',
                  description:
                      'Découvrez les restaurants et commandez sans inscription.',
                  color: FoodlyApp.orange,
                  label: 'Continuer sans compte',
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const CustomerHomeScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _RoleCard(
                  icon: Icons.storefront_rounded,
                  title: 'Je suis restaurateur',
                  description: 'Gérez votre menu, vos commandes et vos ventes.',
                  color: FoodlyApp.green,
                  label: 'Accéder à mon espace',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RestaurantLoginScreen(),
                      ),
                    );
                  },
                ),
                // const Spacer(),
                // Center(
                //   child: Text(
                //     'Le goût à portée de main.',
                //     style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFECEAE5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(icon, color: color, size: 29),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded, color: color),
                ],
              ),
              const SizedBox(height: 17),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: FoodlyApp.green,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF777777),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
