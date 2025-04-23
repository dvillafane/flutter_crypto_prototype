// Importación de la librería equatable para facilitar la comparación de objetos en estados
import 'package:equatable/equatable.dart';

// Clase base para los estados del perfil del usuario, extiende de Equatable para que los estados puedan ser comparados
abstract class ProfileState extends Equatable {
  const ProfileState();

  // Sobrescribe el getter 'props' para la comparación de objetos (los estados)
  @override
  List<Object> get props => [];
}

// Estado inicial del perfil, cuando no se ha cargado nada aún
class ProfileInitial extends ProfileState {}

// Estado cuando se está cargando el perfil del usuario
class ProfileLoading extends ProfileState {}

// Estado que representa un perfil cargado exitosamente
class ProfileLoaded extends ProfileState {
  // Propiedades del perfil cargado
  final String name;
  final String email;
  final String? photoUrl;  // URL de la foto del perfil (puede ser nula)
  final bool isEmailVerified;  // Indica si el correo está verificado

  // Constructor que inicializa las propiedades necesarias para el estado
  const ProfileLoaded({
    required this.name,
    required this.email,
    this.photoUrl,
    required this.isEmailVerified,
  });

  // Sobrescribe 'props' para que el estado se compare correctamente
  @override
  List<Object> get props => [name, email, photoUrl ?? '', isEmailVerified];
}

// Estado de error, cuando ocurre un problema al cargar el perfil
class ProfileError extends ProfileState {
  // Mensaje de error asociado al estado
  final String message;

  // Constructor para inicializar el mensaje de error
  const ProfileError(this.message);

  // Sobrescribe 'props' para que el estado se compare correctamente
  @override
  List<Object> get props => [message];
}
