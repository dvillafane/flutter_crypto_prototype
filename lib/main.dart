import 'package:flutter/foundation.dart' show kIsWeb; // Importación para verificar si estamos en la web
import 'package:firebase_core/firebase_core.dart'; // Inicialización de Firebase
import 'package:flutter/material.dart'; // Paquete básico para aplicaciones Flutter
import 'package:flutter/services.dart'; // Paquete para controlar las configuraciones del sistema
import 'package:flutter_crypto_prototype/firebase_options.dart'; // Opciones de Firebase específicas para cada plataforma
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Paquete para cargar variables de entorno
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:firebase_messaging/firebase_messaging.dart'; // Firebase Messaging para notificaciones push
import 'core/services/noti_service.dart'; // Servicio para manejar notificaciones
import 'core/services/token_service.dart'; // Servicio para manejar tokens de Firebase
import 'features/auth/login/view/login_screen.dart'; // Pantalla de login
import 'features/home/view/home_screen.dart'; // Pantalla principal de la app

// Método principal de la app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que los widgets están inicializados

  try {
    // Cargar archivo .env para acceder a las variables de entorno
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error al cargar el archivo .env: $e"); // Manejo de errores al cargar .env
  }

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    // Inicializar notificaciones solo en plataformas móviles
    await initializeNotifications();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Configuración de orientación solo en plataformas móviles (evitar la rotación en la web)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(const MyApp()); // Iniciar la aplicación
}

// Widget principal de la aplicación
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // GlobalKey para mostrar mensajes de notificación (SnackBars) globalmente
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // Configuración de Firebase y notificaciones solo en plataformas móviles
      obtenerYEnviarTokenFCM();
      obtenerYEnviarFID();
      listenTokenRefresh();
    } else {
      // Configurar Firebase Messaging para la web
      setupWebMessaging();
      // Configurar la recepción de notificaciones en primer plano en la web
      setupForegroundMessages();
    }
  }

  // Método para configurar el manejo de mensajes en la web
  void setupWebMessaging() async {
    final messaging = FirebaseMessaging.instance;
    // Solicitar permisos para recibir notificaciones
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    // Obtener el token FCM para la web usando la clave VAPID
    String? token = await messaging.getToken(
      vapidKey:
          dotenv.env['VAPID_KEY'] ?? '', // Obtener la clave VAPID desde el archivo .env
    );
    if (token != null) {
      debugPrint('Web FCM Token: $token'); // Mostrar el token en consola
      await enviarTokenAFirestore(token); // Enviar el token a Firestore
    } else {
      debugPrint('No se pudo obtener el token FCM para la web.');
    }
    // Escuchar renovaciones del token FCM
    messaging.onTokenRefresh
        .listen((newToken) async {
          debugPrint('Web FCM Token renovado: $newToken');
          await enviarTokenAFirestore(newToken); // Enviar el nuevo token a Firestore
        })
        .onError((error) {
          debugPrint('Error al renovar el token FCM: $error');
        });
  }

  // Método para manejar notificaciones en primer plano en la web
  void setupForegroundMessages() {
    FirebaseMessaging.onMessage
        .listen((RemoteMessage message) {
          debugPrint(
            'Notificación en primer plano recibida: ${message.notification?.title}',
          );
          if (message.notification != null) {
            // Mostrar un SnackBar con el contenido de la notificación
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(
                  '${message.notification?.title}: ${message.notification?.body}',
                ),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Cerrar',
                  onPressed: () {
                    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        })
        .onError((error) {
          debugPrint('Error al recibir notificación en primer plano: $error');
        });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const webBreakpoint = 600; // Definir el punto de ruptura para la versión web

    return MaterialApp(
      title: 'Cyptos 2.0 Demo', // Título de la aplicación
      // Asignar el GlobalKey al ScaffoldMessenger
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: ThemeData(
        brightness: Brightness.dark, // Configurar el tema oscuro
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: screenWidth > webBreakpoint ? 16 : 14,
          ),
          bodySmall: TextStyle(
            color: Colors.white70,
            fontSize: screenWidth > webBreakpoint ? 14 : 12,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.grey[900],
          elevation: 4,
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth > webBreakpoint ? 8 : 4,
            vertical: screenWidth > webBreakpoint ? 6 : 3,
          ),
        ),
        dialogTheme: const DialogTheme(
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
          contentTextStyle: TextStyle(color: Colors.white70),
        ),
        useMaterial3: true,
      ),
      home: const AuthCheck(), // Pantalla inicial que verifica si el usuario está autenticado
    );
  }
}

// Widget que verifica si el usuario está autenticado y muestra la pantalla correspondiente
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Escucha cambios en el estado de autenticación
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // Muestra un indicador de carga mientras espera
          );
        }
        return snapshot.hasData ? const HomeScreen() : const LoginPage(); // Muestra HomeScreen si el usuario está autenticado, de lo contrario muestra LoginPage
      },
    );
  }
}
