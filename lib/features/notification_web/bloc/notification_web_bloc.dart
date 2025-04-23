import 'package:bloc/bloc.dart'; // Importa el paquete BLoC para manejar el estado.
import 'package:firebase_messaging/firebase_messaging.dart'; // Importa el paquete para manejar las notificaciones push de Firebase.
import 'package:flutter/foundation.dart' show kDebugMode; // Importa una constante para verificar si estamos en modo de depuración.
import 'notification_web_event.dart'; // Importa los eventos definidos para la gestión de notificaciones.
import 'notification_web_state.dart'; // Importa los estados definidos para la gestión de notificaciones.

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  // Constructor del BLoC, inicializa con el estado inicial NotificationInitial.
  NotificationBloc() : super(NotificationInitial()) {
    // Registra los eventos y sus manejadores
    on<NotificationReceived>(_onNotificationReceived);
    on<NotificationErrorOccurred>(_onNotificationErrorOccurred);

    // Configura el listener para las notificaciones en primer plano en la web.
    _setupForegroundMessages();
  }

  // Método privado que configura el listener de notificaciones en primer plano.
  void _setupForegroundMessages() {
    // FirebaseMessaging.onMessage escucha las notificaciones cuando la app está en primer plano.
    FirebaseMessaging.onMessage
        .listen((RemoteMessage message) {
          // Si estamos en modo de depuración, muestra un mensaje en la consola con la notificación recibida.
          if (kDebugMode) {
            print(
              'Notificación en primer plano recibida: ${message.notification?.title}', // Muestra el título de la notificación.
            );
          }
          // Añade un evento NotificationReceived con el mensaje recibido.
          add(NotificationReceived(message));
        })
        // En caso de error al recibir la notificación.
        .onError((error) {
          // Si estamos en modo de depuración, muestra el error en la consola.
          if (kDebugMode) {
            print('Error al recibir notificación en primer plano: $error');
          }
          // Añade un evento NotificationErrorOccurred con el error recibido.
          add(
            NotificationErrorOccurred(error.toString()),
          );
        });
  }

  // Método para manejar el evento NotificationReceived.
  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    // Emite el estado NotificationReceivedState con el mensaje recibido.
    emit(NotificationReceivedState(event.message));
  }

  // Método para manejar el evento NotificationErrorOccurred.
  void _onNotificationErrorOccurred(
    NotificationErrorOccurred event,
    Emitter<NotificationState> emit,
  ) {
    // Emite el estado NotificationError con el error ocurrido.
    emit(NotificationError(event.error));
  }
}
