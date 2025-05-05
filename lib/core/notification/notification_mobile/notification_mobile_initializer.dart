// Importa la librería de Firebase Messaging para manejo de notificaciones push
import 'package:firebase_messaging/firebase_messaging.dart';
// Importa funcionalidades del sistema como la orientación de pantalla
import 'package:flutter/services.dart';
// Importa un servicio personalizado para inicializar notificaciones locales
import '../../services/notification_service.dart';
// Importa servicios para manejar y enviar el token de FCM
import '../../../../core/services/token_service.dart';


// Función para inicializar notificaciones móviles (Android/iOS)
Future<void> initializeMobileNotifications() async {
  // Inicializa las notificaciones locales (por ejemplo, usando flutter_local_notifications)
  await initializeNotifications();

  // Registra un manejador para recibir notificaciones en segundo plano
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Establece que la app solo se puede usar en orientación vertical (restringe a portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}


// Configura los manejadores de notificaciones móviles
void setupMobileNotificationHandlers() {
  // Obtiene el token FCM actual y lo envía al backend o Firestore
  obtenerYEnviarTokenFCM();

  // Obtiene el Firebase Installation ID (FID) y lo envía al backend
  obtenerYEnviarFID();

  // Escucha cambios en el token FCM y actualiza el backend si es necesario
  listenTokenRefresh();
}
