import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:foodly/Customer/customer_order_store.dart';
import 'package:foodly/Customer/panier_page.dart';
import 'package:foodly/Onboarding/splash_screen.dart';
import 'package:foodly/Utils/theme.dart';
import 'package:foodly/service/notification_service.dart';

/// Gestion des notifications lorsque l'application est en arrière-plan
/// ou complètement fermée.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint('Notification reçue en arrière-plan : ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  await Firebase.initializeApp();
  await NotificationService.instance.initialize();

  // Enregistrement du gestionnaire des notifications en arrière-plan
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Affichage des notifications lorsque l'application est ouverte
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Chargement des données locales
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
