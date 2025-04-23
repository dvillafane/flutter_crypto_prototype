// Indica que este archivo es parte del archivo principal 'login_bloc.dart'
part of 'login_bloc.dart';

// Clase abstracta base para todos los estados posibles del LoginBloc
abstract class LoginState extends Equatable {
  const LoginState();

  // Permite comparar estados según sus propiedades para evitar renders innecesarios
  @override
  List<Object> get props => [];
}

// Estado inicial del login, cuando no se ha realizado ninguna acción aún
class LoginInitial extends LoginState {}

// Estado que indica que se está procesando el inicio de sesión (puede mostrar un loader)
class LoginLoading extends LoginState {}

// Estado que indica que el inicio de sesión fue exitoso
class LoginSuccess extends LoginState {}

// Estado que indica que ocurrió un error en el login, con un mensaje descriptivo
class LoginFailure extends LoginState {
  final String error; // Mensaje de error

  // Constructor que recibe el mensaje de error
  const LoginFailure(this.error);

  // Define que la igualdad de este estado depende del mensaje de error
  @override
  List<Object> get props => [error];
}
