// Indica que este archivo forma parte del archivo principal 'forgot_password_bloc.dart'
part of 'forgot_password_bloc.dart';

// Clase abstracta que representa un evento genérico del ForgotPasswordBloc
abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  // Permite comparar eventos basados en sus propiedades para evitar renders innecesarios
  @override
  List<Object> get props => [];
}

// Evento específico que se dispara cuando el usuario envía su correo para recuperar la contraseña
class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  // Propiedad que contiene el correo electrónico ingresado por el usuario
  final String email;

  // Constructor que requiere un correo electrónico
  const ForgotPasswordSubmitted({required this.email});

  // Permite que dos instancias del evento sean iguales si el email es igual
  @override
  List<Object> get props => [email];
}
