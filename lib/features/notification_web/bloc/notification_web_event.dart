import 'package:equatable/equatable.dart'; // Importa el paquete Equatable para facilitar la comparación de objetos.
import 'package:firebase_messaging/firebase_messaging.dart'; // Importa el paquete FirebaseMessaging para trabajar con notificaciones push.

abstract class NotificationEvent extends Equatable {
  // Clase base abstracta para los eventos de notificación. Extiende Equatable para facilitar la comparación de objetos.
  const NotificationEvent();
  
  @override
  List<Object?> get props => [];
  // Equatable se asegura de que los objetos de este tipo se puedan comparar correctamente.
}

class NotificationReceived extends NotificationEvent {
  final RemoteMessage message; // El mensaje de la notificación recibido de Firebase.
  
  const NotificationReceived(this.message); // Constructor que recibe un RemoteMessage.
  
  @override
  List<Object?> get props => [message]; // Compara los objetos basándose en el mensaje.
}

class NotificationErrorOccurred extends NotificationEvent {
  final String error; // El mensaje de error recibido si algo falla al recibir una notificación.
  
  const NotificationErrorOccurred(this.error); // Constructor que recibe el mensaje de error.
  
  @override
  List<Object?> get props => [error]; // Compara los objetos basándose en el error.
}
