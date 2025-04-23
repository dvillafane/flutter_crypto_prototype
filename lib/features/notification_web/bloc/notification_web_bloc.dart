import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'notification_web_event.dart';
import 'notification_web_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<NotificationReceived>(_onNotificationReceived);
    on<NotificationErrorOccurred>(_onNotificationErrorOccurred);

    // Configura el listener para notificaciones en primer plano en la web
    _setupForegroundMessages();
  }

  void _setupForegroundMessages() {
    FirebaseMessaging.onMessage
        .listen((RemoteMessage message) {
          if (kDebugMode) {
            print(
              'Notificación en primer plano recibida: ${message.notification?.title}',
            );
          }
          add(NotificationReceived(message));
        })
        .onError((error) {
          if (kDebugMode) {
            print('Error al recibir notificación en primer plano: $error');
          }
          add(
            NotificationErrorOccurred(error.toString()),
          ); // Agrega el evento en lugar de emitir directamente
        });
  }

  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationReceivedState(event.message));
  }

  void _onNotificationErrorOccurred(
    NotificationErrorOccurred event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationError(event.error));
  }
}
