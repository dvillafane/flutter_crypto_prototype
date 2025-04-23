// Importaciones necesarias para Bloc, comparación de objetos, Firebase Auth, Google Sign-In y Firestore
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Inclusión de archivos que contienen los eventos y estados del LoginBloc
part 'login_event.dart';
part 'login_state.dart';

// Bloc para manejar la lógica de inicio de sesión
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth; // Instancia de FirebaseAuth para autenticación
  final FirebaseFirestore _firestore; // Instancia de Firestore para guardar usuarios

  // Constructor que permite inyectar FirebaseAuth y Firestore o usar los predeterminados
  LoginBloc({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(LoginInitial()) {
    // Escucha eventos de inicio de sesión con email/contraseña
    on<LoginSubmitted>(_onLoginSubmitted);
    // Escucha eventos de inicio de sesión con Google
    on<LoginGoogleSubmitted>(_onLoginGoogleSubmitted);
  }

  // Maneja el evento de login con email y contraseña
  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final email = event.email.trim(); // Elimina espacios en el email
    final password = event.password;
    emit(LoginLoading()); // Emite estado de carga

    try {
      // Intenta iniciar sesión con email y contraseña
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        // Verifica si el email fue confirmado
        if (user.emailVerified) {
          emit(LoginSuccess()); // Inicio exitoso
        } else {
          emit(const LoginFailure("Por favor verifica tu correo electrónico"));
        }
      }
    } on FirebaseAuthException catch (e) {
      // Manejo de errores específicos de Firebase
      String errorMsg;
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'Usuario no encontrado';
          break;
        case 'wrong-password':
          errorMsg = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          errorMsg = 'Formato de email inválido';
          break;
        case 'user-disabled':
          errorMsg = 'Cuenta deshabilitada';
          break;
        case 'too-many-requests':
          errorMsg = 'Demasiados intentos. Intenta más tarde';
          break;
        default:
          errorMsg = 'Error de autenticación';
      }
      emit(LoginFailure(errorMsg));
    } catch (e) {
      // Cualquier otro error no manejado
      emit(LoginFailure('Error desconocido: ${e.toString()}'));
    }
  }

  // Maneja el evento de login con cuenta de Google
  Future<void> _onLoginGoogleSubmitted(
    LoginGoogleSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading()); // Emite estado de carga

    try {
      // Crea una instancia de GoogleSignIn con los permisos básicos
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Inicia el flujo de inicio de sesión
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Si el usuario cancela el inicio de sesión
      if (googleUser == null) {
        emit(const LoginFailure('Inicio de sesión con Google cancelado'));
        return;
      }

      // Obtiene las credenciales de autenticación
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crea una credencial válida para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Inicia sesión con Firebase usando las credenciales de Google
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final name = googleUser.displayName ?? 'Usuario de Google';

        // Verifica si el usuario ya existe en Firestore
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        // Si no existe, lo crea con nombre y email
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'name': name,
            'email': user.email,
          });
        }

        emit(LoginSuccess()); // Inicio exitoso
      }
    } on FirebaseAuthException catch (e) {
      // Error relacionado con Firebase Auth
      emit(LoginFailure('Error en autenticación con Google: ${e.message}'));
    } catch (e) {
      // Cualquier otro error
      emit(LoginFailure('Error desconocido: ${e.toString()}'));
    }
  }
}
