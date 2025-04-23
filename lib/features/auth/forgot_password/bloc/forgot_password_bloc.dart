// Importaciones necesarias para Bloc, comparación de objetos y autenticación con Firebase
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Inclusión de archivos que definen los eventos y estados para este BLoC
part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

// Declaración del BLoC para manejar la lógica de "Olvidé mi contraseña"
class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  // Constructor: define el estado inicial como ForgotPasswordInitial
  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    // Registra un manejador de eventos para cuando se envía el formulario de recuperación
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
  }

  // Función privada que maneja el evento ForgotPasswordSubmitted
  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    // Obtiene y limpia el correo ingresado por el usuario
    final email = event.email.trim();

    // Si el correo está vacío, emite un estado de error
    if (email.isEmpty) {
      emit(
        const ForgotPasswordFailure("Por favor ingresa un correo electrónico"),
      );
      return;
    }

    // Emite un estado de carga mientras se procesa la solicitud
    emit(ForgotPasswordLoading());

    try {
      // Intenta enviar el correo de recuperación mediante Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Si tiene éxito, emite un estado de éxito con un mensaje
      emit(
        const ForgotPasswordSuccess(
          "Se ha enviado un enlace de recuperación a tu correo",
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Captura errores específicos de FirebaseAuth
      String errorMsg;

      // Asigna un mensaje dependiendo del código de error recibido
      switch (e.code) {
        case 'invalid-email':
          errorMsg = 'El formato del email es inválido';
          break;
        case 'user-not-found':
          errorMsg = 'No se encontró un usuario con este email';
          break;
        default:
          errorMsg = 'Error al enviar el email de recuperación';
      }

      // Emite un estado de error con el mensaje correspondiente
      emit(ForgotPasswordFailure(errorMsg));
    } catch (e) {
      // Captura cualquier otro tipo de error y emite un mensaje genérico
      emit(ForgotPasswordFailure('Error desconocido: ${e.toString()}'));
    }
  }
}
