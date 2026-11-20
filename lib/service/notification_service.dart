import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;

  bool _initialized = false;

  /// Initialise les notifications locales et Firebase.
  Future<void> initialize() async {
    print('Notification initié ');
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      onDidReceiveNotificationResponse: (response) {
        print('Notification cliquée : ${response.payload}');
      },
      settings: initializationSettings,
    );

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔔 Initialisation FCM...');

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        print('🔥 FCM ON MESSAGE DÉCLENCHÉ');

        _showForegroundNotification(message);
      },
      onError: (error) {
        print('❌ ERREUR FCM : $error');
      },
    );

    print('✅ Écoute FCM installée');

    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
      message,
    ) {
      print('Notification ouverte : ${message.data}');
    });

    _initialized = true;
  }

  /// Affiche une notification lorsque l'application est ouverte.

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    print('========== PUSH REÇU ==========');

    final title = message.notification?.title ?? 'Foodly';
    final body =
        message.notification?.body ?? 'Vous avez une nouvelle notification.';

    print('TITLE: $title');
    print('BODY: $body');
    print('DATA: ${message.data}');

    // Nombre actuel de notifications sur le badge.
    final currentBadge = await _localNotifications.getActiveNotifications();

    final newBadgeCount = currentBadge.length + 1;

    const androidDetails = AndroidNotificationDetails(
      'foodly_notifications',
      'Notifications Foodly',
      channelDescription: 'Notifications des commandes Foodly',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: newBadgeCount,
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: message.data.toString(),
    );

    print('Badge configuré : $newBadgeCount');
  }

  /// Demande l'autorisation et récupère le token FCM.
  Future<String?> getToken() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('Autorisation des notifications refusée.');
        return null;
      }

      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        print('Token FCM indisponible.');
        return null;
      }

      print('Token FCM récupéré : $token');

      return token;
    } catch (e) {
      print('Erreur récupération token FCM : $e');
      return null;
    }
  }

  /// Écoute les changements de token Firebase.
  void listenTokenRefresh(void Function(String token) onTokenRefresh) {
    _tokenSubscription?.cancel();

    _tokenSubscription = _messaging.onTokenRefresh.listen((token) {
      print('Nouveau token FCM : $token');
      onTokenRefresh(token);
    });
  }

  /// Vérifie si l'application a été ouverte depuis une notification.
  Future<RemoteMessage?> getInitialMessage() async {
    return _messaging.getInitialMessage();
  }

  /// Libère les abonnements.
  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();

    _tokenSubscription = null;
    _foregroundSubscription = null;
    _openedSubscription = null;
    _initialized = false;
  }
}
