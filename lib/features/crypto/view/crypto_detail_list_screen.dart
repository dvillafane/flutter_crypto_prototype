import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_crypto_prototype/features/crypto/bloc/crypto_event.dart';
import 'package:flutter_crypto_prototype/features/crypto/bloc/crypto_state.dart';
import 'package:intl/intl.dart';
import '../bloc/crypto_bloc.dart';
import '../../../core/models/crypto_detail.dart';

class CryptoDetailListScreen extends StatefulWidget {
  final bool isGuest; // Indica si el usuario es invitado
  const CryptoDetailListScreen({super.key, this.isGuest = false});

  @override
  CryptoDetailListScreenState createState() => CryptoDetailListScreenState();
}

class CryptoDetailListScreenState extends State<CryptoDetailListScreen> {
  String searchQuery = ""; // Consulta de búsqueda actual
  final TextEditingController _searchController =
      TextEditingController(); // Controlador del TextField de búsqueda
  final numberFormat = NumberFormat(
    '#,##0.00',
    'en_US',
  ); // Formato de número para mostrar precios
  bool _isSnackBarShown = false; // Controla si el SnackBar ya se ha mostrado
  Timer? _debounceTimer; // Temporizador para controlar el tiempo del SnackBar

  @override
  void dispose() {
    _searchController.dispose(); // Libera el controlador de texto
    _debounceTimer?.cancel(); // Cancela el temporizador si está activo
    ScaffoldMessenger.of(
      context,
    ).clearSnackBars(); // Limpia cualquier SnackBar activo
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const webBreakpoint = 600;

    return Scaffold(
      appBar: AppBar(
        // AppBar superior
        backgroundColor: Colors.black, // Fondo negro
        title: const Text(
          'CRYPTOS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        titleSpacing: 16,
        bottom: PreferredSize(
          // Campo de búsqueda en la parte inferior del AppBar
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Buscar criptomoneda...",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged:
                  (value) => setState(
                    () => searchQuery = value,
                  ), // Actualiza el valor de búsqueda
            ),
          ),
        ),
        actions:
            screenWidth <= webBreakpoint
                ? [
                  BlocBuilder<CryptoBloc, CryptoState>(
                    builder: (context, state) {
                      if (state is CryptoLoaded) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: DropdownButton<String>(
                            value: state.sortCriteria,
                            dropdownColor: Colors.grey[900],
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                value: 'priceUsd',
                                child: Text(
                                  'Precio',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'cmcRank',
                                child: Text(
                                  'Ranking',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                context.read<CryptoBloc>().add(
                                  ChangeSortCriteria(value),
                                );
                              }
                            },
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  if (!widget.isGuest)
                    BlocBuilder<CryptoBloc, CryptoState>(
                      builder: (context, state) {
                        if (state is CryptoLoaded) {
                          return IconButton(
                            icon: Icon(
                              state.showFavorites
                                  ? Icons.favorite
                                  : Icons.format_list_bulleted,
                              color: Colors.white,
                            ),
                            tooltip:
                                state.showFavorites
                                    ? 'Ver todas'
                                    : 'Ver favoritas',
                            onPressed:
                                () => context.read<CryptoBloc>().add(
                                  ToggleFavoritesView(),
                                ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  BlocBuilder<CryptoBloc, CryptoState>(
                    builder: (context, state) {
                      if (state is CryptoLoaded) {
                        return IconButton(
                          icon: Icon(
                            state.isWebSocketConnected
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          tooltip:
                              state.isWebSocketConnected
                                  ? 'Detener actualizaciones'
                                  : 'Reanudar actualizaciones',
                          onPressed: () {
                            if (state.isWebSocketConnected) {
                              context.read<CryptoBloc>().add(
                                DisconnectWebSocket(),
                              );
                            } else {
                              context.read<CryptoBloc>().add(
                                ConnectWebSocket(),
                              );
                            }
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ]
                : [], // En web, los filtros estarán en el cuerpo
      ),
      body: BlocBuilder<CryptoBloc, CryptoState>(
        // Cuerpo de la pantalla
        builder: (context, state) {
          if (state is CryptoLoading) {
            return const Center(child: CircularProgressIndicator()); // Cargando
          } else if (state is CryptoLoaded) {
            return Column(
              children: [
                if (screenWidth > webBreakpoint) // Filtros en web
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        DropdownButton<String>(
                          value: state.sortCriteria,
                          dropdownColor: Colors.grey[900],
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: 'priceUsd',
                              child: Text(
                                'Ordenar por Precio',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'cmcRank',
                              child: Text(
                                'Ordenar por Ranking',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              context.read<CryptoBloc>().add(
                                ChangeSortCriteria(value),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        if (!widget.isGuest)
                          ElevatedButton.icon(
                            onPressed:
                                () => context.read<CryptoBloc>().add(
                                  ToggleFavoritesView(),
                                ),
                            icon: Icon(
                              state.showFavorites
                                  ? Icons.favorite
                                  : Icons.format_list_bulleted,
                              color: Colors.white,
                            ),
                            label: Text(
                              state.showFavorites
                                  ? 'Ver Todas'
                                  : 'Ver Favoritas',
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (state.isWebSocketConnected) {
                              context.read<CryptoBloc>().add(
                                DisconnectWebSocket(),
                              );
                            } else {
                              context.read<CryptoBloc>().add(
                                ConnectWebSocket(),
                              );
                            }
                          },
                          icon: Icon(
                            state.isWebSocketConnected
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          label: Text(
                            state.isWebSocketConnected ? 'Pausar' : 'Reanudar',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (state.isUpdating) const LinearProgressIndicator(),
                Expanded(child: _buildCryptoList(state.cryptos, state)),
              ],
            );
          } else if (state is CryptoError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ), // Muestra error
                  ElevatedButton(
                    onPressed:
                        () => context.read<CryptoBloc>().add(
                          LoadCryptos(),
                        ), // Botón para reintentar
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink(); // Pantalla vacía por defecto
        },
      ),
    );
  }

  Widget _buildCryptoList(List<CryptoDetail> cryptos, CryptoLoaded state) {
    var iterable = cryptos.where(
      (c) => c.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      ), // Filtrado por búsqueda
    );

    if (state.showFavorites) {
      iterable = iterable.where(
        (c) => state.favoriteSymbols.contains(c.symbol),
      ); // Filtra favoritas
    }

    final filtered = iterable.toList();
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          state.showFavorites
              ? 'No tienes favoritas aún'
              : 'No se encontró ninguna',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    // Obtener el ancho de la pantalla para decidir el diseño
    final screenWidth = MediaQuery.of(context).size.width;
// Punto de corte para considerar una pantalla "web"
    const gridBreakpoint = 700; // Nuevo punto de corte para usar GridView

    // Si el ancho es mayor o igual a gridBreakpoint, usamos GridView; si no, ListView (móvil)
    if (screenWidth >= gridBreakpoint) {
      // Calcula el número de columnas dinámicamente según el ancho de pantalla
      final crossAxisCount =
          screenWidth < 900
              ? 2 // 2 columnas si <900px
              : 3; // Máximo 3 columnas si >=900px

      return GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              crossAxisCount, // Número de columnas dinámico, máximo 3
          childAspectRatio: 3, // Relación ancho/alto de cada tarjeta
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final detail = filtered[i];
          final isFav = state.favoriteSymbols.contains(detail.symbol);
          return Card(
            color: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Obtiene el ancho disponible de la tarjeta
                  final cardWidth = constraints.maxWidth;

                  // Ajusta dinámicamente los tamaños según el ancho de la tarjeta
                  final imageSize =
                      cardWidth * 0.08; // Tamaño de la imagen (8% del ancho)
                  final fontSizeName =
                      cardWidth * 0.05; // Tamaño del nombre (5% del ancho)
                  final fontSizePrice =
                      cardWidth * 0.04; // Tamaño del precio (4% del ancho)
                  final fontSizeChange =
                      cardWidth * 0.035; // Tamaño del cambio (3.5% del ancho)
                  final iconSize =
                      cardWidth *
                      0.06; // Tamaño del ícono de favoritos (6% del ancho)

                  return Row(
                    children: [
                      // Imagen del logo (responsiva)
                      SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: Image.network(
                          detail.logoUrl,
                          fit:
                              BoxFit
                                  .contain, // Ajusta la imagen para que no se desborde
                          errorBuilder:
                              (_, __, ___) => Icon(
                                Icons.error,
                                color: Colors.red,
                                size: imageSize,
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Información de la criptomoneda
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Nombre de la criptomoneda
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                detail.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSizeName,
                                ),
                              ),
                            ),
                            // Precio con animación de color
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 350),
                              style: TextStyle(
                                color:
                                    state.priceColors[detail.symbol] ??
                                    Colors.white70,
                                fontSize: fontSizePrice,
                              ),
                              child: Text(
                                '\$${numberFormat.format(detail.priceUsd)} USD',
                              ),
                            ),
                            // Cambio porcentual en 24h
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '24h: ${detail.percentChange24h.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color:
                                      detail.percentChange24h >= 0
                                          ? Colors.green
                                          : Colors.red,
                                  fontSize: fontSizeChange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Botón de favoritos (si no es usuario invitado)
                      if (!widget.isGuest)
                        IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.white70,
                            size: iconSize,
                          ),
                          onPressed:
                              () => context.read<CryptoBloc>().add(
                                ToggleFavoriteSymbol(detail.symbol),
                              ),
                        ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final detail = filtered[i];
          final isFav = state.favoriteSymbols.contains(detail.symbol);
          return Card(
            color: Colors.grey[900],
            child: ListTile(
              leading: Image.network(
                detail.logoUrl,
                width: 32,
                height: 32,
                errorBuilder:
                    (_, __, ___) => const Icon(Icons.error, color: Colors.red),
              ),
              title: Text(
                detail.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 350),
                style: TextStyle(
                  color: state.priceColors[detail.symbol] ?? Colors.white70,
                ),
                child: Text('\$${numberFormat.format(detail.priceUsd)} USD'),
              ),
              trailing:
                  widget.isGuest
                      ? null
                      : IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.white70,
                        ),
                        onPressed:
                            () => context.read<CryptoBloc>().add(
                              ToggleFavoriteSymbol(detail.symbol),
                            ),
                      ),
              onTap: () {
                if (widget.isGuest) {
                  if (!_isSnackBarShown) {
                    _isSnackBarShown = true;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Para ver más detalles, inicia sesión'),
                      ),
                    );
                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(const Duration(seconds: 5), () {
                      setState(() {
                        _isSnackBarShown = false;
                      });
                    });
                  }
                } else {
                  _showCryptoDetailDialog(context, detail);
                }
              },
            ),
          );
        },
      );
    }
  }

  void _showCryptoDetailDialog(BuildContext context, CryptoDetail detail) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            // Diálogo con detalles de la cripto
            backgroundColor: Colors.grey[900],
            title: Row(
              children: [
                Image.network(
                  detail.logoUrl,
                  width: 32,
                  height: 32,
                  errorBuilder:
                      (_, __, ___) =>
                          const Icon(Icons.error, color: Colors.red),
                ),
                const SizedBox(width: 8),
                Text(detail.name, style: const TextStyle(color: Colors.white)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Símbolo: ${detail.symbol}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Ranking: #${detail.cmcRank}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Precio: \$${numberFormat.format(detail.priceUsd)} USD',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Volumen 24h: \$${numberFormat.format(detail.volumeUsd24Hr)} USD',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Cambio 24h: ${detail.percentChange24h.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color:
                          detail.percentChange24h >= 0
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                  Text(
                    'Cambio 7d: ${detail.percentChange7d.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color:
                          detail.percentChange7d >= 0
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                  Text(
                    'Capitalización de mercado: \$${numberFormat.format(detail.marketCapUsd)} USD',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Suministro circulante: ${numberFormat.format(detail.circulatingSupply)} ${detail.symbol}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (detail.totalSupply != null)
                    Text(
                      'Suministro total: ${numberFormat.format(detail.totalSupply!)} ${detail.symbol}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  if (detail.maxSupply != null)
                    Text(
                      'Suministro máximo: ${numberFormat.format(detail.maxSupply!)} ${detail.symbol}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.of(context).pop(), // Cierra el diálogo
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
