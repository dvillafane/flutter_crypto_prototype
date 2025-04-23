import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_crypto_prototype/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/noti_service.dart';
import 'core/services/token_service.dart';
import 'features/auth/login/view/login_screen.dart';
import 'features/home/view/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error al cargar el archivo .env: $e");
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    // Inicializar notificaciones solo en plataformas móviles
    await initializeNotifications();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Configurar orientación solo en plataformas móviles
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Agregar un GlobalKey para el ScaffoldMessenger
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // Configurar notificaciones y tokens solo en plataformas móviles
      obtenerYEnviarTokenFCM();
      obtenerYEnviarFID();
      listenTokenRefresh();
      setupNotificationListeners();
    } else {
      // Configurar Firebase Messaging para la web
      setupWebMessaging();
      // Agregar listener para notificaciones en primer plano en la web
      setupForegroundMessages();
    }
  }

  void setupWebMessaging() async {
    final messaging = FirebaseMessaging.instance;
    // Solicitar permisos para notificaciones en la web
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    // Obtener y enviar token en la web con VAPID key
    String? token = await messaging.getToken(
      vapidKey:
          dotenv.env['VAPID_KEY'] ?? '', // Carga la clave VAPID desde .env
    );
    if (token != null) {
      debugPrint('Web FCM Token: $token');
      await enviarTokenAFirestore(token);
    } else {
      debugPrint('No se pudo obtener el token FCM para la web.');
    }
    // Escuchar renovaciones de token
    messaging.onTokenRefresh
        .listen((newToken) async {
          debugPrint('Web FCM Token renovado: $newToken');
          await enviarTokenAFirestore(newToken);
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
            // Usar el GlobalKey para mostrar el SnackBar
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
    const webBreakpoint = 600;

    return MaterialApp(
      title: 'Cyptos 2.0 Demo',
      // Asignar el GlobalKey al ScaffoldMessenger
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: ThemeData(
        brightness: Brightness.dark,
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
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.hasData ? const HomeScreen() : const LoginPage();
      },
    );
  }
}
