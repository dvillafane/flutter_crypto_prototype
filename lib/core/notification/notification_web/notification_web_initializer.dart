// Importa la biblioteca de Firebase Messaging para manejar notificaciones push
import 'package:firebase_messaging/firebase_messaging.dart';

// Importa Flutter Material para el uso de widgets y elementos visuales
import 'package:flutter/material.dart';

// Importa dotenv para acceder a variables de entorno (como la VAPID_KEY)
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Importa el servicio personalizado que maneja el almacenamiento/envío del token FCM a Firestore
import '../../services/token_service.dart';

// Función que configura la mensajería web con Firebase Cloud Messaging
Future<void> setupWebMessaging(GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) async {
  // Obtiene la instancia de FirebaseMessaging
  final messaging = FirebaseMessaging.instance;

  // Solicita permisos para mostrar alertas, íconos de badge y sonidos
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  // Obtiene el token FCM utilizando la VAPID key desde las variables de entorno
  String? token = await messaging.getToken(vapidKey: dotenv.env['VAPID_KEY'] ?? '');

  // Si se obtuvo el token correctamente, se imprime y se envía a Firestore
  if (token != null) {
    debugPrint('Web FCM Token: $token');
    await enviarTokenAFirestore(token);
  } else {
    // Si no se pudo obtener el token, se imprime un mensaje de error
    debugPrint('No se pudo obtener el token FCM para la web.');
  }

  // Escucha cambios en el token (por ejemplo, cuando se renueva)
  messaging.onTokenRefresh.listen((newToken) async {
    debugPrint('Web FCM Token renovado: $newToken');
    await enviarTokenAFirestore(newToken); // Envía el nuevo token a Firestore
  }).onError((error) {
    debugPrint('Error al renovar el token FCM: $error');
  });

  // Escucha notificaciones entrantes cuando la app está en primer plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Notificación en primer plano recibida: ${message.notification?.title}');
    
    // Si la notificación contiene datos válidos, se muestra un SnackBar con el contenido
    if (message.notification != null) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('${message.notification?.title}: ${message.notification?.body}'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Cerrar',
            onPressed: () {
              // Permite cerrar el SnackBar manualmente
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
