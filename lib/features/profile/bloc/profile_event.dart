// Importación de la librería equatable para facilitar la comparación de objetos en eventos
import 'package:equatable/equatable.dart';

// Clase base para los eventos del perfil del usuario, extiende de Equatable para que los eventos puedan ser comparados
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  // Sobrescribe el getter 'props' para la comparación de objetos (los eventos)
  @override
  List<Object> get props => [];
}

// Evento para cargar el perfil del usuario
class LoadProfile extends ProfileEvent {}

// Evento para enviar un correo de verificación al usuario
class SendVerificationEmail extends ProfileEvent {}

// Evento para enviar un correo de restablecimiento de contraseña al usuario
class SendPasswordResetEmail extends ProfileEvent {}

// Evento para eliminar la cuenta del usuario
class DeleteAccount extends ProfileEvent {}
