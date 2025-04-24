import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'websocket/websocket_factory.dart'; // ✅ Import condicional

class WebSocketPricesService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  final StreamController<Map<String, double>> _pricesController =
      StreamController.broadcast();

  Stream<Map<String, double>> get pricesStream => _pricesController.stream;

  void connect() {
    if (_isConnected || _channel != null) return;

    _channel = createWebSocketChannel('wss://stream.binance.com:9443/ws/!ticker@arr');

    _isConnected = true;
    debugPrint('WebSocket conectado');

    _channel!.stream.listen(
      (message) {
        debugPrint('Datos recibidos del WebSocket: $message');

        final List<dynamic> tickers = json.decode(message);
        final Map<String, double> parsedData = {};

        for (var ticker in tickers) {
          final String symbol = ticker['s'].toString().toLowerCase();
          final double price = double.tryParse(ticker['c'].toString()) ?? 0;
          parsedData[symbol] = price;
        }

        if (!_pricesController.isClosed) {
          _pricesController.add(parsedData);
        }
      },
      onError: (error) {
        debugPrint('WebSocket error: $error');
        disconnect();
      },
      onDone: () {
        debugPrint('WebSocket cerrado por el servidor');
        disconnect();
      },
      cancelOnError: true,
    );
  }

  void disconnect() {
    if (_isConnected) {
      _channel?.sink.close();
      _channel = null;
      _isConnected = false;
      debugPrint('WebSocket desconectado');
    }
  }

  void dispose() {
    disconnect();
    _pricesController.close();
    debugPrint('WebSocketPricesService disposed');
  }
}
