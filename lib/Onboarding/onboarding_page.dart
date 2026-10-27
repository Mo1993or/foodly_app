// 2. ONBOARDING

import 'package:flutter/material.dart';
import 'package:foodly/Customer/customer_page.dart';
import 'package:foodly/Onboarding/role_page.dart';
import 'package:foodly/main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      icon: Icons.location_on_rounded,
      title: 'Les meilleurs restaurants, près de vous',
      description:
          'Découvrez les restaurants autour de vous et trouvez '
          'facilement votre prochaine adresse préférée.',
      background: Color(0xFFFFE9D9),
      iconColor: Color(0xFFF56624),
      tags: ['Découverte', 'Proximité'],
    ),
    _OnboardingData(
      icon: Icons.lunch_dining_rounded,
      title: 'Vos plats préférés, en quelques clics',
      description:
          'Parcourez les menus, choisissez vos plats et '
          'passez commande simplement, sans créer de compte.',
      background: Color(0xFFE5EFE7),
      iconColor: Color(0xFF173D32),
      tags: ['Menus', 'Commande facile'],
    ),
    _OnboardingData(
      icon: Icons.storefront_rounded,
      title: 'Votre restaurant a aussi sa place',
      description:
          'Vous êtes restaurateur ? Rejoignez Foodly pour '
          'publier vos plats, recevoir des commandes et suivre vos ventes.',
      background: Color(0xFFFFE9D9),
      iconColor: Color(0xFFF56624),
      tags: ['Visibilité', 'Gestion des ventes'],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 8),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text(
                    'Passer',
                    style: TextStyle(
                      color: FoodlyApp.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(data: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final selected = index == _currentPage;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 7,
                        width: selected ? 25 : 7,
                        decoration: BoxDecoration(
                          color: selected
                              ? FoodlyApp.orange
                              : const Color(0xFFD8D8D8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FoodlyApp.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastPage ? 'Commencer' : 'Suivant',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color background;
  final Color iconColor;
  final List<String> tags;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.background,
    required this.iconColor,
    required this.tags,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final illustrationHeight = (constraints.maxHeight * 0.43).clamp(
          220.0,
          340.0,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              SizedBox(
                height: illustrationHeight,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 235,
                      height: 235,
                      decoration: BoxDecoration(
                        color: data.background,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Positioned(
                      top: 30,
                      right: 28,
                      child: _bubble(Icons.star_rounded, 40),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 24,
                      child: _bubble(Icons.favorite_rounded, 35),
                    ),
                    Container(
                      width: 155,
                      height: 175,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Icon(data.icon, color: data.iconColor, size: 90),
                    ),
                    Positioned(
                      right: 35,
                      bottom: 43,
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: data.iconColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 27,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                  color: FoodlyApp.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.65,
                  color: Color(0xFF777777),
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: data.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: data.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: data.iconColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bubble(IconData icon, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: data.background, shape: BoxShape.circle),
      child: Icon(icon, color: data.iconColor, size: size * 0.55),
    );
  }
}
