import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodly/Customer/customer_order_store.dart';
import 'package:foodly/Customer/panier_page.dart';
import 'package:foodly/Onboarding/splash_screen.dart';
import 'package:foodly/Utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await clientOrdersStore.loadOrders();
  await foodlyCart.loadCart();

  runApp(const FoodlyApp());
}

class FoodlyApp extends StatelessWidget {
  const FoodlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thiop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          primary: orange,
          secondary: green,
          surface: background,
        ),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}
