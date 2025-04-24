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
  final TextEditingController _searchController = TextEditingController(); // Controlador del TextField de búsqueda
  final NumberFormat numberFormat = NumberFormat('#,##0.00', 'en_US'); // Formato de número para mostrar precios
  bool _isSnackBarShown = false; // Controla si el SnackBar ya se ha mostrado
  Timer? _debounceTimer; // Temporizador para controlar el tiempo del SnackBar

  @override
  void dispose() {
    _searchController.dispose(); // Libera el controlador de texto
    _debounceTimer?.cancel(); // Cancela el temporizador si está activo
    ScaffoldMessenger.of(context).clearSnackBars(); // Limpia cualquier SnackBar activo
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const webBreakpoint = 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
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
                fillColor: Colors.grey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
        ),
        actions: screenWidth <= webBreakpoint
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
                              context.read<CryptoBloc>().add(ChangeSortCriteria(value));
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
                            state.showFavorites ? Icons.favorite : Icons.format_list_bulleted,
                            color: Colors.white,
                          ),
                          tooltip: state.showFavorites ? 'Ver todas' : 'Ver favoritas',
                          onPressed: () => context.read<CryptoBloc>().add(ToggleFavoritesView()),
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
                          state.isWebSocketConnected ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        tooltip: state.isWebSocketConnected ? 'Detener actualizaciones' : 'Reanudar actualizaciones',
                        onPressed: () {
                          if (state.isWebSocketConnected) {
                            context.read<CryptoBloc>().add(DisconnectWebSocket());
                          } else {
                            context.read<CryptoBloc>().add(ConnectWebSocket());
                          }
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ]
            : [],
      ),
      body: BlocBuilder<CryptoBloc, CryptoState>(
        builder: (context, state) {
          if (state is CryptoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CryptoLoaded) {
            return Column(
              children: [
                if (screenWidth > webBreakpoint)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              child: Text('Ordenar por Precio', style: TextStyle(color: Colors.white)),
                            ),
                            DropdownMenuItem(
                              value: 'cmcRank',
                              child: Text('Ordenar por Ranking', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              context.read<CryptoBloc>().add(ChangeSortCriteria(value));
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        if (!widget.isGuest)
                          ElevatedButton.icon(
                            onPressed: () => context.read<CryptoBloc>().add(ToggleFavoritesView()),
                            icon: Icon(
                              state.showFavorites ? Icons.favorite : Icons.format_list_bulleted,
                              color: Colors.white,
                            ),
                            label: Text(
                              state.showFavorites ? 'Ver Todas' : 'Ver Favoritas',
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (state.isWebSocketConnected) {
                              context.read<CryptoBloc>().add(DisconnectWebSocket());
                            } else {
                              context.read<CryptoBloc>().add(ConnectWebSocket());
                            }
                          },
                          icon: Icon(
                            state.isWebSocketConnected ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          label: Text(
                            state.isWebSocketConnected ? 'Pausar' : 'Reanudar',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: () => context.read<CryptoBloc>().add(LoadCryptos()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCryptoList(List<CryptoDetail> cryptos, CryptoLoaded state) {
    final filtered = cryptos
        .where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .where((c) => state.showFavorites ? state.favoriteSymbols.contains(c.symbol) : true)
        .toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron criptomonedas',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    const gridBreakpoint = 700;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: screenWidth >= gridBreakpoint
              ? SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth < 900 ? 2 : 3,
                    childAspectRatio: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildCryptoCard(filtered[i], state, isGrid: true),
                    childCount: filtered.length,
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildCryptoCard(filtered[i], state, isGrid: false),
                    childCount: filtered.length,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCryptoCard(CryptoDetail detail, CryptoLoaded state, {required bool isGrid}) {
    final isFav = state.favoriteSymbols.contains(detail.symbol);

    return Card(
      key: ValueKey(detail.id), // Clave única para memoización
      color: Colors.grey[900],
      child: InkWell(
        onTap: () {
          if (widget.isGuest) {
            if (!_isSnackBarShown) {
              _isSnackBarShown = true;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Para ver más detalles, inicia sesión')),
              );
              _debounceTimer?.cancel();
              _debounceTimer = Timer(const Duration(seconds: 5), () {
                setState(() => _isSnackBarShown = false);
              });
            }
          } else {
            _showCryptoDetailDialog(context, detail);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isGrid ? _buildGridCardContent(detail, state, isFav) : _buildListCardContent(detail, state, isFav),
        ),
      ),
    );
  }

  Widget _buildGridCardContent(CryptoDetail detail, CryptoLoaded state, bool isFav) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final imageSize = cardWidth * 0.08;
        final fontSizeName = cardWidth * 0.05;
        final fontSizePrice = cardWidth * 0.04;
        final fontSizeChange = cardWidth * 0.035;
        final iconSize = cardWidth * 0.06;

        return Row(
          children: [
            SizedBox(
              width: imageSize,
              height: imageSize,
              child: Image.network(
                detail.logoUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.error, color: Colors.red, size: imageSize),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      detail.name,
                      style: TextStyle(color: Colors.white, fontSize: fontSizeName),
                    ),
                  ),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 350),
                    style: TextStyle(
                      color: state.priceColors[detail.symbol] ?? Colors.white70,
                      fontSize: fontSizePrice,
                    ),
                    child: Text('\$${numberFormat.format(detail.priceUsd)} USD'),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '24h: ${detail.percentChange24h.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: detail.percentChange24h >= 0 ? Colors.green : Colors.red,
                        fontSize: fontSizeChange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!widget.isGuest)
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.white70,
                  size: iconSize,
                ),
                onPressed: () => context.read<CryptoBloc>().add(ToggleFavoriteSymbol(detail.symbol)),
              ),
          ],
        );
      },
    );
  }

  Widget _buildListCardContent(CryptoDetail detail, CryptoLoaded state, bool isFav) {
    return ListTile(
      leading: Image.network(
        detail.logoUrl,
        width: 32,
        height: 32,
        errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.red),
      ),
      title: Text(detail.name, style: const TextStyle(color: Colors.white)),
      subtitle: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 350),
        style: TextStyle(color: state.priceColors[detail.symbol] ?? Colors.white70),
        child: Text('\$${numberFormat.format(detail.priceUsd)} USD'),
      ),
      trailing: widget.isGuest
          ? null
          : IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : Colors.white70,
              ),
              onPressed: () => context.read<CryptoBloc>().add(ToggleFavoriteSymbol(detail.symbol)),
            ),
    );
  }

  void _showCryptoDetailDialog(BuildContext context, CryptoDetail detail) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Image.network(
              detail.logoUrl,
              width: 32,
              height: 32,
              errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.red),
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
              Text('Símbolo: ${detail.symbol}', style: const TextStyle(color: Colors.white70)),
              Text('Ranking: #${detail.cmcRank}', style: const TextStyle(color: Colors.white70)),
              Text('Precio: \$${numberFormat.format(detail.priceUsd)} USD', style: const TextStyle(color: Colors.white70)),
              Text('Volumen 24h: \$${numberFormat.format(detail.volumeUsd24Hr)} USD', style: const TextStyle(color: Colors.white70)),
              Text(
                'Cambio 24h: ${detail.percentChange24h.toStringAsFixed(2)}%',
                style: TextStyle(color: detail.percentChange24h >= 0 ? Colors.green : Colors.red),
              ),
              Text(
                'Cambio 7d: ${detail.percentChange7d.toStringAsFixed(2)}%',
                style: TextStyle(color: detail.percentChange7d >= 0 ? Colors.green : Colors.red),
              ),
              Text('Capitalización de mercado: \$${numberFormat.format(detail.marketCapUsd)} USD', style: const TextStyle(color: Colors.white70)),
              Text('Suministro circulante: ${numberFormat.format(detail.circulatingSupply)} ${detail.symbol}', style: const TextStyle(color: Colors.white70)),
              if (detail.totalSupply != null)
                Text('Suministro total: ${numberFormat.format(detail.totalSupply!)} ${detail.symbol}', style: const TextStyle(color: Colors.white70)),
              if (detail.maxSupply != null)
                Text('Suministro máximo: ${numberFormat.format(detail.maxSupply!)} ${detail.symbol}', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}