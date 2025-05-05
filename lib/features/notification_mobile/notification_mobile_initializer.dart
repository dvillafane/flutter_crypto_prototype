import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import '../../../core/services/noti_service.dart';
import '../../../core/services/token_service.dart';

Future<void> initializeMobileNotifications() async {
  await initializeNotifications();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void setupMobileNotificationHandlers() {
  obtenerYEnviarTokenFCM();
  obtenerYEnviarFID();
  listenTokenRefresh();
}
