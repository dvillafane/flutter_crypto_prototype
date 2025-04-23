// Este archivo forma parte del archivo principal 'register_bloc.dart'
part of 'register_bloc.dart';

// Clase abstracta base para todos los eventos relacionados al registro
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  // Permite comparar eventos según sus propiedades, útil para optimizar renderizados
  @override
  List<Object> get props => [];
}

// Evento que se dispara cuando el usuario envía el formulario de registro
class RegisterSubmitted extends RegisterEvent {
  final String email;     // Correo electrónico ingresado
  final String password;  // Contraseña ingresada
  final String name;      // Nombre del usuario

  // Constructor del evento que requiere email, contraseña y nombre
  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.name,
  });

  // Define que la comparación de este evento se hace en base a estas propiedades
  @override
  List<Object> get props => [email, password, name];
}
