import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crypto_prototype/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/auth/login/view/login_screen.dart';
import 'features/home/view/home_screen.dart';
import 'core/notification/notification_web/notification_web_initializer.dart';
import 'core/notification/notification_mobile/notification_mobile_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error al cargar el archivo .env: $e");
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    await initializeMobileNotifications();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      setupMobileNotificationHandlers();
    } else {
      setupWebMessaging(_scaffoldMessengerKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const webBreakpoint = 600;

    return MaterialApp(
      title: 'Cyptos 2.0 Demo',
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
