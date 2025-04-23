// Indica que este archivo es parte del archivo principal 'login_bloc.dart'
part of 'login_bloc.dart';

// Clase abstracta base para todos los eventos del LoginBloc
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  // Permite comparar eventos basados en sus propiedades, útil para evitar renders innecesarios
  @override
  List<Object> get props => [];
}

// Evento que se dispara cuando el usuario intenta iniciar sesión con email y contraseña
class LoginSubmitted extends LoginEvent {
  final String email;     // Correo electrónico ingresado por el usuario
  final String password;  // Contraseña ingresada por el usuario

  // Constructor que recibe email y contraseña
  const LoginSubmitted({required this.email, required this.password});

  // Define que la igualdad de este evento depende del email y la contraseña
  @override
  List<Object> get props => [email, password];
}

// Evento que se dispara cuando el usuario intenta iniciar sesión con Google
class LoginGoogleSubmitted extends LoginEvent {
  // Constructor constante sin parámetros, ya que no se requiere info adicional
  const LoginGoogleSubmitted();
}
