// Importación de las dependencias necesarias para el BLoC, Firebase Authentication y Firestore
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_event.dart';
import 'profile_state.dart';

// Clase que define el BLoC para manejar eventos relacionados con el perfil del usuario
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  // Instancias de FirebaseAuth y FirebaseFirestore para interactuar con Firebase
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Constructor de la clase que recibe las instancias de FirebaseAuth y FirebaseFirestore
  // Si no se pasan, se usan las instancias predeterminadas
  ProfileBloc({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(ProfileInitial()) {
    // Definición de los eventos que manejará el BLoC
    on<LoadProfile>(_onLoadProfile);
    on<SendVerificationEmail>(_onSendVerificationEmail);
    on<SendPasswordResetEmail>(_onSendPasswordResetEmail);
    on<DeleteAccount>(_onDeleteAccount);
  }

  // Manejo del evento para cargar el perfil del usuario
  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    // Emitir el estado de carga
    emit(ProfileLoading());
    try {
      // Obtener el usuario actual desde FirebaseAuth
      final user = _auth.currentUser;
      if (user == null) {
        // Si no hay un usuario autenticado, emitir un error
        emit(const ProfileError('No hay usuario autenticado'));
        return;
      }
      
      // Obtener la información del usuario desde Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        // Si no se encuentra la información del usuario, emitir un error
        emit(const ProfileError('No se encontró información del usuario'));
        return;
      }
      
      // Obtener los datos del documento
      final data = doc.data() as Map<String, dynamic>;
      final name = data['name'] ?? 'Sin nombre'; // Nombre del usuario (si no existe, 'Sin nombre')
      final email = user.email ?? 'Sin email';  // Correo del usuario (si no existe, 'Sin email')
      final photoUrl = user.photoURL;            // URL de la foto de perfil
      final isEmailVerified = user.emailVerified; // Estado de verificación del correo electrónico

      // Emitir el estado con la información del perfil cargado
      emit(ProfileLoaded(
        name: name,
        email: email,
        photoUrl: photoUrl,
        isEmailVerified: isEmailVerified,
      ));
    } catch (e) {
      // Si ocurre un error al cargar el perfil, emitir un error
      emit(ProfileError('Error al cargar el perfil: $e'));
    }
  }

  // Manejo del evento para enviar un correo de verificación
  Future<void> _onSendVerificationEmail(SendVerificationEmail event, Emitter<ProfileState> emit) async {
    try {
      // Obtener el usuario actual
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        // Si el usuario no está verificado, enviar un correo de verificación
        await user.sendEmailVerification();
      }
    } catch (e) {
      // Si ocurre un error, emitir un error
      emit(ProfileError('Error al enviar email de verificación: $e'));
    }
  }

  // Manejo del evento para enviar un correo de restablecimiento de contraseña
  Future<void> _onSendPasswordResetEmail(SendPasswordResetEmail event, Emitter<ProfileState> emit) async {
    try {
      // Obtener el usuario actual
      final user = _auth.currentUser;
      if (user != null) {
        // Si el usuario está autenticado, enviar un correo para restablecer la contraseña
        await _auth.sendPasswordResetEmail(email: user.email!);
      }
    } catch (e) {
      // Si ocurre un error, emitir un error
      emit(ProfileError('Error al enviar email de restablecimiento: $e'));
    }
  }

  // Manejo del evento para eliminar la cuenta del usuario
  Future<void> _onDeleteAccount(DeleteAccount event, Emitter<ProfileState> emit) async {
    try {
      // Obtener el usuario actual
      final user = _auth.currentUser;
      if (user != null) {
        // Eliminar el documento del usuario en Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        // Eliminar la cuenta del usuario en Firebase Authentication
        await user.delete();
      }
    } catch (e) {
      // Si ocurre un error, emitir un error
      emit(ProfileError('Error al eliminar la cuenta: $e'));
    }
  }
}
