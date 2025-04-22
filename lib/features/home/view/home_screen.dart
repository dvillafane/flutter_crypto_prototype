import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../crypto/bloc/crypto_bloc.dart';
import '../../../core/services/crypto_detail_service.dart';
import '../../../core/services/websocket_prices_service.dart';
import '../../crypto/view/crypto_detail_list_screen.dart';
import '../../profile/view/profile_screen.dart';

// Define un widget con estado llamado HomeScreen
class HomeScreen extends StatefulWidget {
  // Recibe un parámetro opcional que indica si el usuario es invitado
  final bool isGuest;
  const HomeScreen({super.key, this.isGuest = false});

  @override
  HomeScreenState createState() => HomeScreenState();
}

// Clase de estado para HomeScreen
class HomeScreenState extends State<HomeScreen> {
  // Índice del ítem seleccionado en el BottomNavigationBar
  int _selectedIndex = 0;
  // Lista de pantallas que se mostrarán al cambiar de índice
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Inicializa las pantallas con CryptoDetailListScreen y ProfileScreen
    _screens = [
      CryptoDetailListScreen(isGuest: widget.isGuest),
      ProfileScreen(isGuest: widget.isGuest),
    ];
  }

  // Método para actualizar el índice seleccionado
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const webBreakpoint = 600;

    return BlocProvider(
      create:
          (context) => CryptoBloc(
            // Si el usuario es invitado, se le asigna un ID genérico "guest"
            userId:
                widget.isGuest
                    ? 'guest'
                    : FirebaseAuth.instance.currentUser!.uid,
            // Se inyecta el servicio de detalles de criptomonedas
            cryptoService: CryptoDetailService(),
            // Se inyecta el servicio de precios en tiempo real
            pricesService: WebSocketPricesService(),
          ),
      child:
          screenWidth > webBreakpoint
              ? Scaffold(
                body: Row(
                  children: [
                    // Barra lateral para web
                    NavigationRail(
                      backgroundColor: Colors.black,
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _onItemTapped,
                      labelType: NavigationRailLabelType.all,
                      selectedLabelTextStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      unselectedLabelTextStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home, color: Colors.grey),
                          selectedIcon: Icon(Icons.home, color: Colors.white),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.person, color: Colors.grey),
                          selectedIcon: Icon(Icons.person, color: Colors.white),
                          label: Text('Perfil'),
                        ),
                      ],
                    ),
                    Expanded(child: _screens[_selectedIndex]),
                  ],
                ),
              )
              : Scaffold(
                body: _screens[_selectedIndex],
                bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: Colors.black,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.grey,
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Perfil',
                    ),
                  ],
                ),
              ),
    );
  }
}
