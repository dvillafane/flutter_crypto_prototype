// Este archivo forma parte del archivo principal 'register_bloc.dart'
part of 'register_bloc.dart';

// Clase abstracta base para todos los estados del proceso de registro
abstract class RegisterState extends Equatable {
  const RegisterState();

  // Define las propiedades que se usarán para comparar estados
  @override
  List<Object> get props => [];
}

// Estado inicial del formulario de registro, antes de cualquier acción
class RegisterInitial extends RegisterState {}

// Estado que indica que el proceso de registro está en curso
class RegisterLoading extends RegisterState {}

// Estado que indica que el registro fue exitoso
class RegisterSuccess extends RegisterState {}

// Estado que representa un fallo en el registro con un mensaje de error
class RegisterFailure extends RegisterState {
  final String error; // Mensaje de error a mostrar al usuario

  // Constructor que recibe el mensaje de error
  const RegisterFailure(this.error);

  // Se considera el error como propiedad para la comparación de estados
  @override
  List<Object> get props => [error];
}
