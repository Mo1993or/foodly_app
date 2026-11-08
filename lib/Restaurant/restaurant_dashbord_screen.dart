import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:foodly/Restaurant/restaurant_offer_screen.dart';
import 'package:foodly/Restaurant/restaurant_profil_screen.dart';
import 'package:foodly/Restaurant/retaurant_data.dart';
import 'package:foodly/Utils/network.dart';
import 'package:foodly/model/offer_model.dart';
import 'package:foodly/model/restaurant_model.dart';
import 'package:foodly/service/restaurant_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'restaurant_orders_screen.dart';
import 'restaurant_menu_screen.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  final String selectedOffer;
  final RestaurantModel? restaurant;
  final String statusPayment;

  // Alerte de paiement
  final bool showPaymentAlert;
  final VoidCallback? onPayNow;

  const RestaurantDashboardScreen({
    super.key,
    this.selectedOffer = 'Pro',
    required this.restaurant,
    this.showPaymentAlert = false,
    this.onPayNow,
    required this.statusPayment,
  });

  @override
  State<RestaurantDashboardScreen> createState() =>
      _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  static const Color orange = Color(0xFFF56624);
  static const Color green = Color(0xFF173D32);
  static const Color background = Color(0xFFFAF8F3);

  int _selectedIndex = 0;

  List<SubscriptionModel> listSub = [];
  String statusPayment = "";

  Future<void> _fetchHistorySubscriptios() async {
    try {
      final value = await RestaurantService().historyMyOffer(
        widget.restaurant?.id ?? "",
      );

      if (!mounted) return;

      setState(() {
        listSub = value;

        // Évite une erreur si aucun abonnement n'existe.
        if (widget.statusPayment.isNotEmpty) {
          statusPayment = widget.statusPayment;
        } else {
          statusPayment = listSub.isNotEmpty
              ? listSub.last.status.toLowerCase()
              : "";
        }
      });

      debugPrint("statusPayment $statusPayment");
    } catch (err) {
      debugPrint("Erreur historique abonnement : $err");
    }
  }

  @override
  void initState() {
    super.initState();

    restaurantData.addListener(_refresh);
    _fetchHistorySubscriptios();

    debugPrint("restaurant ${widget.restaurant}");
  }

  @override
  void dispose() {
    restaurantData.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // ============================================================
  // STATUTS ABONNEMENT
  // ============================================================

  bool get _isPaymentPending {
    return statusPayment == "pending_payment" ||
        statusPayment == "pending_verification";
  }

  bool get _isRejected {
    return statusPayment == "rejected";
  }

  bool get _isExpired {
    return statusPayment == "expired";
  }

  // ============================================================
  // NAVIGATION VERS LES OFFRES
  // ============================================================

  void _openOffers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantOffersScreen(restaurant: widget.restaurant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _buildHome(),
      RestaurantOrdersScreen(restaurant: widget.restaurant),
      RestaurantMenuScreen(restaurant: widget.restaurant),
      RestaurantProfileScreen(restaurant: widget.restaurant),
    ];

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    final orders = restaurantData.orders;
    final dishes = restaurantData.dishes;

    final pending = orders.where((o) => o.status == 'En attente').length;

    final active = orders.where((o) {
      return ['Acceptée', 'En préparation', 'Prête'].contains(o.status);
    }).length;

    final completedOrders = orders.where((o) {
      return ['Terminée', 'Livrée'].contains(o.status);
    }).toList();

    final completed = completedOrders.length;

    final revenue = completedOrders.fold<int>(
      0,
      (sum, order) => sum + order.total,
    );

    final averageBasket = orders.isEmpty
        ? 0
        : orders.fold<int>(0, (sum, order) => sum + order.total) ~/
              orders.length;

    final availableDishes = dishes.where((dish) => dish.isAvailable).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 18),

          // Affichage automatique selon le statut de l'abonnement.
          if (_isPaymentPending)
            _buildPaymentAlert()
          else if (_isRejected)
            _buildRejectedAlert()
          else if (_isExpired)
            _buildExpiredAlert()
          else
            _buildWelcomeCard(),

          const SizedBox(height: 26),

          _sectionTitle(
            'Vue d’ensemble',
            'Les indicateurs clés de votre restaurant',
          ),

          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              _statCard(
                'Commandes reçues',
                '${orders.length}',
                'Toutes les commandes',
                Icons.receipt_long_rounded,
                orange,
              ),
              _statCard(
                'En attente',
                '$pending',
                'À traiter',
                Icons.hourglass_top_rounded,
                const Color(0xFFE7A33E),
              ),
              _statCard(
                'En cours',
                '$active',
                'À préparer ou livrer',
                Icons.restaurant_rounded,
                const Color(0xFF4285F4),
              ),
              _statCard(
                'Terminées',
                '$completed',
                'Commandes finalisées',
                Icons.check_circle_rounded,
                const Color(0xFF2E8B57),
              ),
              _statCard(
                'Plats disponibles',
                '$availableDishes/${dishes.length}',
                'Plats actifs au menu',
                Icons.fastfood_rounded,
                green,
              ),
              _statCard(
                'Panier moyen',
                '${formatCfa(averageBasket)} F',
                'Par commande',
                Icons.shopping_bag_rounded,
                const Color(0xFF8B5CF6),
              ),
            ],
          ),

          const SizedBox(height: 26),
          _buildRevenueChart(revenue),

          const SizedBox(height: 26),
          _buildOrderStatus(pending, active, completed),

          const SizedBox(height: 26),
          _buildRecentOrders(),

          const SizedBox(height: 26),
          _buildMenuSummary(availableDishes, dishes.length),

          const SizedBox(height: 20),
          _buildRestaurantStatus(),
        ],
      ),
    );
  }

  // ============================================================
  // ALERTE ABONNEMENT / PAIEMENT
  // ============================================================

  Future<void> _launchPayment() async {
    var url = apiUrlPayment;

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final String cleanNumber = phoneNumber.replaceAll(' ', '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw Exception('Could not launch phone dialer for $cleanNumber');
    }
  }

  Future<void> openWavePayment(BuildContext context) async {
    const paymentUrl = 'https://pay.wave.com/m/M_sn_snCiyi6_rFbh/c/sn/';

    final uri = Uri.parse(paymentUrl);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        final fallbackLaunched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );

        if (!fallbackLaunched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d’ouvrir le paiement Wave.'),
            ),
          );
        }
      }
    } on PlatformException catch (e) {
      debugPrint('Erreur ouverture Wave : ${e.message}');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir Wave. Vérifiez votre navigateur.'),
        ),
      );
    } catch (e) {
      debugPrint('Erreur paiement : $e');
    }
  }

  // ============================================================
  // ALERTE : PAIEMENT EN ATTENTE
  // ============================================================

  Widget _buildPaymentAlert() {
    final isVerification = statusPayment == "pending_verification";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5EC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: orange.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: orange.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Offre ${widget.selectedOffer}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isVerification
                      ? Icons.hourglass_top_rounded
                      : Icons.notifications_active_rounded,
                  color: orange,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'ACTION REQUISE',
                            style: TextStyle(
                              color: orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5D2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isVerification ? 'Vérification' : 'En attente',
                            style: const TextStyle(
                              color: Color(0xFFB94A13),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isVerification
                          ? 'Votre paiement est en cours de vérification'
                          : 'Votre offre est en attente de paiement',
                      style: const TextStyle(
                        color: green,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            isVerification
                ? 'Votre paiement a été signalé. Notre équipe procède actuellement à sa vérification pour activer votre abonnement.'
                : 'Finalisez le paiement de votre abonnement pour permettre sa vérification et son activation par notre équipe. Si vous n’avez pas encore effectué le paiement, cliquez sur ce bouton.',
            style: const TextStyle(
              color: Color(0xFF75685F),
              fontSize: 12,
              height: 1.55,
            ),
          ),

          if (!isVerification) ...[
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await openWavePayment(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment_rounded, size: 19),
                    SizedBox(width: 9),
                    Text(
                      'Payer maintenant',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 7),
                    Icon(Icons.arrow_forward_rounded, size: 17),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          !isVerification
              ? const Text(
                  'Si c’est déjà fait, appelez ce numéro pour valider votre offre : +221 77 312 31 89',
                  style: TextStyle(
                    color: Color(0xFF75685F),
                    fontSize: 12,
                    height: 1.55,
                  ),
                )
              : Container(),

          const SizedBox(height: 13),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await _makePhoneCall("+221773123189");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call, size: 19),
                  SizedBox(width: 9),
                  Text(
                    'Appelez maintenant',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 7),
                  Icon(Icons.arrow_forward_rounded, size: 17),
                ],
              ),
            ),
          ),

          const SizedBox(height: 11),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF9A887C),
                size: 13,
              ),
              SizedBox(width: 5),
              Text(
                'Paiement sécurisé avec Wave Business',
                style: TextStyle(
                  color: Color(0xFF9A887C),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ALERTE : OFFRE REJETÉE
  // ============================================================

  Widget _buildRejectedAlert() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3C5B9)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Offre ${widget.selectedOffer}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE0D7),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFD94B2B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DEMANDE REJETÉE',
                      style: TextStyle(
                        color: Color(0xFFD94B2B),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Votre offre a été rejetée',
                      style: TextStyle(
                        color: green,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Text(
            'Votre précédente demande d’abonnement n’a pas été acceptée par notre équipe. Vous pouvez sélectionner une nouvelle offre et effectuer une nouvelle demande.',
            style: TextStyle(
              color: Color(0xFF79534B),
              fontSize: 12,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 17),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openOffers,
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_rounded, size: 19),
                  SizedBox(width: 9),
                  Text(
                    'Choisir votre offre',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 7),
                  Icon(Icons.arrow_forward_rounded, size: 17),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ALERTE : OFFRE EXPIRÉE
  // ============================================================

  Widget _buildExpiredAlert() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF2D99C)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Offre ${widget.selectedOffer}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDC2),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFFB77916),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ABONNEMENT EXPIRÉ',
                      style: TextStyle(
                        color: Color(0xFFB77916),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Votre offre est arrivée à expiration',
                      style: TextStyle(
                        color: green,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Text(
            'Votre période d’abonnement est terminée. Pour continuer à profiter des fonctionnalités de Foodly Business et recevoir de nouvelles commandes, renouvelez votre abonnement.',
            style: TextStyle(
              color: Color(0xFF806B48),
              fontSize: 12,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 17),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openOffers,
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.autorenew_rounded, size: 20),
                  SizedBox(width: 9),
                  Text(
                    'Renouveler mon offre',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 7),
                  Icon(Icons.arrow_forward_rounded, size: 17),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: green,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.restaurant, color: Colors.white, size: 27),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FOODLY BUSINESS',
                style: TextStyle(
                  color: orange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                restaurantData.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: green,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _selectedIndex = 3),
          icon: const Icon(Icons.settings_outlined, color: green),
        ),
      ],
    );
  }

  // ============================================================
  // CARTE DE BIENVENUE
  // ============================================================

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [green, Color(0xFF285849)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Offre ${widget.selectedOffer}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Bienvenue dans votre espace !',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 7),
          const Text(
            'Développez votre restaurant.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Gérez vos commandes, vos plats et vos performances au même endroit.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _selectedIndex = 2),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter un plat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => setState(() => _selectedIndex = 1),
                icon: const Icon(Icons.receipt_long_rounded),
                color: Colors.white,
                tooltip: 'Voir les commandes',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INDICATEURS
  // ============================================================

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: green,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: green,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: green,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHIFFRE D'AFFAIRES
  // ============================================================

  Widget _buildRevenueChart(int revenue) {
    final values = <double>[12000, 18500, 15000, 24000, 21000, 32000, 27500];

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chiffre d’affaires',
            style: TextStyle(
              color: green,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Évolution sur les 7 derniers jours',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 18),
          Text(
            '${formatCfa(revenue)} FCFA',
            style: const TextStyle(
              color: green,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Total des commandes terminées',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 190,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxValue * 1.25,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 4,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: maxValue / 4,
                      getTitlesWidget: (value, meta) => Text(
                        '${(value / 1000).round()}k',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Lun',
                          'Mar',
                          'Mer',
                          'Jeu',
                          'Ven',
                          'Sam',
                          'Dim',
                        ];

                        final index = value.toInt();

                        if (index < 0 || index >= days.length) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[index],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((spot) {
                      return LineTooltipItem(
                        '${formatCfa(spot.y.toInt())} FCFA',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      values.length,
                      (index) => FlSpot(index.toDouble(), values[index]),
                    ),
                    isCurved: true,
                    color: orange,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: orange.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RÉPARTITION DES COMMANDES
  // ============================================================

  Widget _buildOrderStatus(int pending, int active, int completed) {
    final total = pending + active + completed;
    final denominator = total == 0 ? 1 : total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition des commandes',
            style: TextStyle(
              color: green,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Suivez l’état de vos commandes',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),
          _statusBar(
            'En attente',
            pending,
            pending / denominator,
            const Color(0xFFE7A33E),
          ),
          const SizedBox(height: 17),
          _statusBar(
            'En cours',
            active,
            active / denominator,
            const Color(0xFF4285F4),
          ),
          const SizedBox(height: 17),
          _statusBar(
            'Terminées',
            completed,
            completed / denominator,
            const Color(0xFF2E8B57),
          ),
        ],
      ),
    );
  }

  Widget _statusBar(String title, int count, double progress, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: green, fontSize: 12),
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(
                color: green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFFF0F0F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // COMMANDES RÉCENTES
  // ============================================================

  Widget _buildRecentOrders() {
    final orders = restaurantData.orders.reversed.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Commandes récentes',
                style: TextStyle(
                  color: green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _selectedIndex = 1),
              child: const Text(
                'Tout voir',
                style: TextStyle(color: orange, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (orders.isEmpty)
          _emptyCard('Aucune commande pour le moment.')
        else
          ...orders.map((order) {
            final statusColor = _statusColor(order.status);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: orange.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.id,
                          style: const TextStyle(
                            color: green,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.customerName,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${formatCfa(order.total)} F',
                    style: const TextStyle(
                      color: green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Terminée':
      case 'Livrée':
        return const Color(0xFF2E8B57);
      case 'En attente':
        return const Color(0xFFE7A33E);
      case 'Refusée':
        return Colors.red;
      case 'Prête':
        return Colors.teal;
      default:
        return const Color(0xFF4285F4);
    }
  }

  // ============================================================
  // MENU
  // ============================================================

  Widget _buildMenuSummary(int available, int total) {
    final ratio = total == 0 ? 0.0 : available / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Votre menu',
            style: TextStyle(
              color: green,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$available plats disponibles sur $total',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 9,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: const AlwaysStoppedAnimation<Color>(orange),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _selectedIndex = 2),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Gérer mon menu'),
              style: OutlinedButton.styleFrom(
                foregroundColor: green,
                side: const BorderSide(color: green),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUT DU RESTAURANT
  // ============================================================

  Widget _buildRestaurantStatus() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          Icon(
            restaurantData.isOpen
                ? Icons.check_circle_rounded
                : Icons.pause_circle_filled_rounded,
            color: restaurantData.isOpen ? Colors.green : Colors.red,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statut du restaurant',
                  style: TextStyle(
                    color: green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  restaurantData.isOpen
                      ? 'Votre restaurant est ouvert'
                      : 'Votre restaurant est fermé',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: restaurantData.isOpen,
            activeThumbColor: orange,
            onChanged: (value) {
              restaurantData.updateRestaurant(
                isOpen: value,
                name: '',
                address: '',
                phone: '',
                email: '',
                description: '',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }
}
