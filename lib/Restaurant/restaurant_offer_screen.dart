import 'package:flutter/material.dart';
import 'package:foodly/Customer/food_detail_screen.dart';
import 'package:foodly/Restaurant/restaurant_dashbord_screen.dart';

class RestaurantOffersScreen extends StatefulWidget {
  const RestaurantOffersScreen({super.key});

  @override
  State<RestaurantOffersScreen> createState() => _RestaurantOffersScreenState();
}

class _RestaurantOffersScreenState extends State<RestaurantOffersScreen> {
  String _selectedOffer = 'pro';

  final List<_RestaurantOffer> _offers = [
    _RestaurantOffer(
      id: 'starter',
      name: 'Starter',
      subtitle: 'Pour démarrer',
      price: 5000,
      period: 'mois',
      icon: Icons.rocket_launch_outlined,
      features: [
        'Jusqu’à 15 produits',
        'Gestion des commandes',
        'Profil restaurant',
        'Statistiques de base',
      ],
    ),
    _RestaurantOffer(
      id: 'pro',
      name: 'Pro',
      subtitle: 'Pour développer ton activité',
      price: 10000,
      period: 'mois',
      icon: Icons.trending_up,
      recommended: true,
      features: [
        'Produits illimités',
        'Gestion des commandes',
        'Statistiques avancées',
        'Mise en avant standard',
        'Assistance prioritaire',
      ],
    ),
    _RestaurantOffer(
      id: 'premium',
      name: 'Premium',
      subtitle: 'Pour aller plus loin',
      price: 20000,
      period: 'mois',
      icon: Icons.workspace_premium_outlined,
      features: [
        'Produits illimités',
        'Mise en avant renforcée',
        'Statistiques avancées',
        'Priorité dans les résultats',
        'Assistance dédiée',
      ],
    ),
  ];

  void _continue() {
    final offer = _offers.firstWhere((item) => item.id == _selectedOffer);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantDashboardScreen(selectedOffer: offer.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: foodlyBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: foodlyGreen,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Foodly Business',
                          style: TextStyle(
                            color: foodlyGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: foodlyGreen,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'ESPACE RESTAURATEUR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Fais grandir ton restaurant avec Foodly.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Choisis la formule adaptée à ton activité '
                          'et commence à recevoir des commandes.',
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.greenAccent,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Menu numérique et gestion des commandes',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Choisis ton offre',
                    style: TextStyle(
                      color: foodlyGreen,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sélectionne la formule qui te convient.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 18),
                  ..._offers.map(_offerCard),
                  const SizedBox(height: 8),
                  const Text(
                    'Tarifs indicatifs en FCFA. Les abonnements et '
                    'les paiements devront être configurés avant '
                    'une mise en production.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFECEAE4))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: foodlyOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Continuer avec ${_offers.firstWhere((o) => o.id == _selectedOffer).name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _offerCard(_RestaurantOffer offer) {
    final selected = _selectedOffer == offer.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedOffer = offer.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? foodlyOrange : const Color(0xFFECEAE4),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (offer.recommended)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: foodlyOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'RECOMMANDÉ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: foodlyGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(offer.icon, color: foodlyGreen, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.name,
                        style: const TextStyle(
                          color: foodlyGreen,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        offer.subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: offer.id,
                  groupValue: _selectedOffer,
                  activeColor: foodlyOrange,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedOffer = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${offer.price.toString()} FCFA',
                  style: const TextStyle(
                    color: foodlyGreen,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 4, left: 5),
                  child: Text('/ mois', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFECEAE4)),
            const SizedBox(height: 8),
            ...offer.features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: foodlyOrange,
                      size: 19,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          color: foodlyGreen,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantOffer {
  final String id;
  final String name;
  final String subtitle;
  final int price;
  final String period;
  final IconData icon;
  final bool recommended;
  final List<String> features;

  const _RestaurantOffer({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.period,
    required this.icon,
    required this.features,
    this.recommended = false,
  });
}
