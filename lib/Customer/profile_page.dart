import 'package:flutter/material.dart';
import 'package:foodly/Customer/register_restaurant.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfilePage({super.key, required this.onLogout});

  static const Color orange = Color(0xFFF56624);
  static const Color green = Color(0xFF173D32);
  static const Color cream = Color(0xFFFAF8F3);

  void _openRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RestaurantRegistrationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mon profil',
                style: TextStyle(
                  color: green,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Gérez votre compte Foodly',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 25),

              // Carte du profil
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        color: orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: orange,
                        size: 35,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenue sur Foodly',
                            style: TextStyle(
                              color: green,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Votre espace personnel',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              // Devenir restaurateur
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(21),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [green, Color(0xFF285849)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                    const SizedBox(height: 17),
                    const Text(
                      'Vous avez un restaurant ?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Rejoignez Foodly, présentez vos plats à de nouveaux clients et développez votre activité grâce à votre espace professionnel.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 19),
                    _benefit(Icons.visibility_outlined, 'Gagnez en visibilité'),
                    const SizedBox(height: 10),
                    _benefit(
                      Icons.receipt_long_outlined,
                      'Gérez vos commandes',
                    ),
                    const SizedBox(height: 10),
                    _benefit(
                      Icons.trending_up_rounded,
                      'Développez vos ventes',
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _openRegistration(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Devenir restaurateur',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 19),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // const Text(
              //   'Mon espace',
              //   style: TextStyle(
              //     color: green,
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const SizedBox(height: 12),

              // _menuTile(
              //   icon: Icons.receipt_long_rounded,
              //   title: 'Mes commandes',
              //   subtitle: 'Retrouvez vos commandes',
              //   onTap: () => _showInfo(context, 'Mes commandes'),
              // ),
              // _menuTile(
              //   icon: Icons.location_on_outlined,
              //   title: 'Mes adresses',
              //   subtitle: 'Gérez vos adresses de livraison',
              //   onTap: () => _showInfo(context, 'Mes adresses'),
              // ),
              // _menuTile(
              //   icon: Icons.favorite_border_rounded,
              //   title: 'Mes favoris',
              //   subtitle: 'Vos restaurants préférés',
              //   onTap: () => _showInfo(context, 'Mes favoris'),
              // ),
              // _menuTile(
              //   icon: Icons.help_outline_rounded,
              //   title: 'Aide et assistance',
              //   subtitle: 'Besoin d’aide ?',
              //   onTap: () => _showInfo(context, 'Aide et assistance'),
              // ),

              // const SizedBox(height: 22),
              const SizedBox(height: 24),

              _menuTile(
                icon: Icons.login_rounded,
                title: 'J\'ai déjà un compte',
                subtitle: 'Se Connecter',
                iconColor: Colors.green,
                onTap: onLogout,
              ),

              // const SizedBox(height: 18),
              // const Center(
              //   child: Text(
              //     'FOODLY • La bonne cuisine, près de vous',
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       color: Colors.black38,
              //       fontSize: 11,
              //       letterSpacing: 0.3,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _benefit(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFB18C), size: 19),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = green,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: green,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 11),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.black38,
        ),
      ),
    );
  }

  static void _showInfo(BuildContext context, String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$section : cette fonctionnalité sera connectée ensuite.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
