import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/services/token_service.dart';


Future<void> setupWebMessaging(GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) async {
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(alert: true, badge: true, sound: true);
  String? token = await messaging.getToken(vapidKey: dotenv.env['VAPID_KEY'] ?? '');

  if (token != null) {
    debugPrint('Web FCM Token: $token');
    await enviarTokenAFirestore(token);
  } else {
    debugPrint('No se pudo obtener el token FCM para la web.');
  }

  messaging.onTokenRefresh.listen((newToken) async {
    debugPrint('Web FCM Token renovado: $newToken');
    await enviarTokenAFirestore(newToken);
  }).onError((error) {
    debugPrint('Error al renovar el token FCM: $error');
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Notificación en primer plano recibida: ${message.notification?.title}');
    if (message.notification != null) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('${message.notification?.title}: ${message.notification?.body}'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Cerrar',
            onPressed: () {
              scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }).onError((error) {
    debugPrint('Error al recibir notificación en primer plano: $error');
  });
}
