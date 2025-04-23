// Indica que este archivo forma parte del archivo principal 'forgot_password_bloc.dart'
part of 'forgot_password_bloc.dart';

// Clase abstracta que representa un estado genérico del ForgotPasswordBloc
abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  // Permite comparar estados por sus propiedades, útil para optimizar redibujos en la UI
  @override
  List<Object> get props => [];
}

// Estado inicial: cuando aún no se ha hecho ninguna acción de recuperación
class ForgotPasswordInitial extends ForgotPasswordState {}

// Estado que indica que se está procesando la solicitud (por ejemplo, mostrando un loading spinner)
class ForgotPasswordLoading extends ForgotPasswordState {}

// Estado que indica que la recuperación fue exitosa, con un mensaje para mostrar al usuario
class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;

  // Constructor que recibe un mensaje de éxito
  const ForgotPasswordSuccess(this.message);

  // Permite comparar instancias basándose en el mensaje
  @override
  List<Object> get props => [message];
}

// Estado que indica que ocurrió un error durante el proceso de recuperación
class ForgotPasswordFailure extends ForgotPasswordState {
  final String error;

  // Constructor que recibe el mensaje de error
  const ForgotPasswordFailure(this.error);

  // Permite comparar instancias basándose en el mensaje de error
  @override
  List<Object> get props => [error];
}
