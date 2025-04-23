// Importaciones necesarias para el manejo de BLoC, comparación de objetos, autenticación y base de datos
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Referencias a los archivos de eventos y estados del BLoC
part 'register_event.dart';
part 'register_state.dart';

// BLoC encargado de manejar el registro de usuarios
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final FirebaseAuth _auth;               // Instancia de autenticación
  final FirebaseFirestore _firestore;    // Instancia de Firestore

  // Constructor que permite inyectar instancias personalizadas (útil para pruebas)
  RegisterBloc({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(RegisterInitial()) {
    // Se escucha el evento RegisterSubmitted
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  // Función que maneja el evento de registro
  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    final email = event.email.trim();       // Elimina espacios innecesarios
    final password = event.password;
    final name = event.name.trim();

    // Validación: contraseña muy corta
    if (password.length < 6) {
      emit(const RegisterFailure('La contraseña debe tener al menos 6 caracteres'));
      return;
    }

    // Validación: nombre vacío
    if (name.isEmpty) {
      emit(const RegisterFailure('El nombre es obligatorio'));
      return;
    }

    emit(RegisterLoading()); // Emite estado de carga mientras se realiza el proceso

    try {
      // Intenta crear un nuevo usuario con email y contraseña
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        // Si el usuario se creó, guarda su nombre y correo en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
        });

        // Envía un correo de verificación
        await user.sendEmailVerification();

        // Emite éxito si todo salió bien
        emit(RegisterSuccess());
      }
    } on FirebaseAuthException catch (e) {
      // Captura errores específicos de Firebase Auth
      String errorMsg = 'Error en el registro';
      switch (e.code) {
        case 'email-already-in-use':
          errorMsg = 'El correo electrónico ya está en uso';
          break;
        case 'invalid-email':
          errorMsg = 'Formato de email inválido';
          break;
        case 'weak-password':
          errorMsg = 'Contraseña débil';
          break;
        default:
          errorMsg = 'Error en el registro';
      }
      emit(RegisterFailure(errorMsg));
    } catch (e) {
      // Maneja cualquier otro error desconocido
      emit(RegisterFailure('Error desconocido: ${e.toString()}'));
    }
  }
}
