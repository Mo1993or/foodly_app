import 'package:flutter/material.dart';
import 'package:foodly/Customer/food_detail_screen.dart';
import 'package:foodly/Restaurant/restaurant_dashbord_screen.dart';
import 'package:foodly/Utils/network.dart';
import 'package:foodly/model/offer_model.dart';
import 'package:foodly/model/restaurant_model.dart';
import 'package:foodly/service/restaurant_service.dart';
import 'package:foodly/widget/shimers.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantOffersScreen extends StatefulWidget {
  final RestaurantModel? restaurant;
  const RestaurantOffersScreen({super.key, required this.restaurant});

  @override
  State<RestaurantOffersScreen> createState() => _RestaurantOffersScreenState();
}

class _RestaurantOffersScreenState extends State<RestaurantOffersScreen> {
  String _selectedOffer = 'pro';
  String _name = 'pro';

  List<OfferModel> listOffers = [];
  bool isLoading = false;
  Future<void> _fetchOffers() async {
    try {
      if (!mounted) return;

      setState(() {
        isLoading = true;
      });

      final value = await RestaurantService().fetchOffer();

      if (!mounted) return;

      final activeOffer =
          widget.restaurant?.activeOffer.trim().toLowerCase() ?? '';

      // Recherche de l'offre actuellement active du restaurant.
      final matchingOffer = value.where(
        (offer) => offer.name.trim().toLowerCase() == activeOffer,
      );

      // Si aucune offre active ne correspond, sélectionner Pro par défaut.
      final defaultOffer = value.where(
        (offer) => offer.name.trim().toLowerCase() == 'pro',
      );

      setState(() {
        listOffers = value;

        if (matchingOffer.isNotEmpty) {
          _selectedOffer = matchingOffer.first.name;
        } else if (defaultOffer.isNotEmpty) {
          _selectedOffer = defaultOffer.first.name;
        } else if (value.isNotEmpty) {
          _selectedOffer = value.first.name;
        }

        isLoading = false;
      });
    } catch (err) {
      debugPrint('Erreur chargement offres : $err');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _selectedOffer =
        widget.restaurant?.activeOffer.trim().toLowerCase() ?? 'pro';

    _fetchOffers();

    debugPrint(
      'Offre active du restaurant : ${widget.restaurant?.activeOffer}',
    );
  }

  bool _isLoading = false;
  _launchPayment() async {
    var url = apiUrlPayment;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _continue() async {
    final offer = listOffers.firstWhere((item) => item.id != "");
    if (_selectedOffer == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez choisir un offre"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() {
        _isLoading = true;
      });
      final offer = listOffers.firstWhere(
        (item) => item.name == _selectedOffer,
      );
      try {
        var data = {
          "restaurantId": widget.restaurant?.id ?? "",
          "offerId": offer.id,
        };
        var result = await RestaurantService().subscriptionOffer(data);

        print("result $result");
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantDashboardScreen(
              selectedOffer: offer.name,
              restaurant: widget.restaurant,
              statusPayment: result['subscription']["status"].toString(),
            ),
          ),
        );
        await _launchPayment();
      } catch (err) {
        setState(() {
          _isLoading = false;
        });
        print("err $err");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: foodlyBackground,
      body: SafeArea(
        child: (isLoading)
            ? const RestaurantShimmer(itemCount: 4)
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      children: [
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: foodlyGreen,
                                  size: 22,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
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
                        ...listOffers.map(_offerCard),
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
                        child: _isLoading
                            ? const SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Continuer',
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

  Widget _offerCard(OfferModel offer) {
    final selected = _selectedOffer == offer.name;

    return GestureDetector(
      onTap: () => setState(() => _selectedOffer = offer.name),
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
            if (offer.isPopular)
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
                  child: Icon(Icons.local_offer, color: foodlyGreen, size: 26),
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
                        offer.name,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: offer.name,
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
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                offer.description,
                style: const TextStyle(color: foodlyGreen, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
