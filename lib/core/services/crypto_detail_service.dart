import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import '../models/crypto_detail.dart';

class CryptoDetailService {
  // Instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // URL base de la API de CoinMarketCap (usada en móvil)
  final String coinMarketCapBaseUrl = 'https://pro-api.coinmarketcap.com';
  // URL base del servidor proxy (usada en web)
  final String proxyBaseUrl = 'http://localhost:3000/api';
  final String apiKey =
      dotenv.env['CMC_API_KEY'] ?? ''; // Asegúrate de manejar bien la clave

  CryptoDetailService() {
    if (apiKey.isEmpty) {
      throw Exception(
        'CMC_API_KEY no está definida en las variables de entorno.',
      );
    }
  }

  /// Método para obtener las 100 criptomonedas principales desde CoinMarketCap
  Future<List<CryptoDetail>> fetchTop100CryptoDetails() async {
    final listingsData = await _fetchRawTop100CryptoData();
    final cryptoDetails = listingsData.map(_cryptoFromJson).toList();

    await Future.wait(cryptoDetails.map(_saveCryptoDetailToFirestore));

    return cryptoDetails;
  }

  /// Obtiene los datos crudos desde la API de CoinMarketCap
  Future<List<Map<String, dynamic>>> _fetchRawTop100CryptoData() async {
    final headers = {'X-CMC_PRO_API_KEY': apiKey};

    // Determina la URL base según la plataforma (web o móvil)
    final baseUrl = kIsWeb ? proxyBaseUrl : coinMarketCapBaseUrl;
    // Construye la URL con parámetros para obtener el top 100
    final listingsUrl = Uri.parse(
      '$baseUrl/v1/cryptocurrency/listings/latest?start=1&limit=100&convert=USD',
    );

    // Solicitud GET a la API (o al proxy en el caso de web)
    final response = await http.get(listingsUrl, headers: headers);
    if (kDebugMode) {
      print('URL solicitada: $listingsUrl');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    // Si la solicitud fue exitosa (código 200)
    if (response.statusCode == 200) {
      // Decodifica el cuerpo de la respuesta
      final listingsData = json.decode(response.body)['data'];
      if (listingsData == null) {
        throw Exception('Datos no encontrados en la respuesta de la API');
      }
      return List<Map<String, dynamic>>.from(listingsData);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  /// Convierte un Map a un modelo CryptoDetail
  CryptoDetail _cryptoFromJson(Map<String, dynamic> coinData) {
    final symbol = coinData['symbol'].toString().toUpperCase();
    final quote = coinData['quote']['USD'];

    return CryptoDetail(
      id: coinData['id'].toString(),
      name: coinData['name'] ?? symbol,
      symbol: symbol,
      cmcRank: coinData['cmc_rank'] ?? 0,
      priceUsd: (quote['price'] as num?)?.toDouble() ?? 0,
      volumeUsd24Hr: (quote['volume_24h'] as num?)?.toDouble() ?? 0,
      percentChange24h: (quote['percent_change_24h'] as num?)?.toDouble() ?? 0,
      percentChange7d: (quote['percent_change_7d'] as num?)?.toDouble() ?? 0,
      marketCapUsd: (quote['market_cap'] as num?)?.toDouble() ?? 0,
      circulatingSupply:
          (coinData['circulating_supply'] as num?)?.toDouble() ?? 0,
      totalSupply: (coinData['total_supply'] as num?)?.toDouble(),
      maxSupply: (coinData['max_supply'] as num?)?.toDouble(),
      logoUrl:
          'https://s2.coinmarketcap.com/static/img/coins/64x64/${coinData["id"]}.png',
    );
  }

  /// Guarda en Firestore el detalle de una criptomoneda
  Future<void> _saveCryptoDetailToFirestore(CryptoDetail cryptoDetail) async {
    final docRef = _firestore
        .collection('crypto_details')
        .doc(cryptoDetail.symbol);
    await docRef.set({
      'id': cryptoDetail.id,
      'name': cryptoDetail.name,
      'symbol': cryptoDetail.symbol,
      'cmcRank': cryptoDetail.cmcRank,
      'priceUsd': cryptoDetail.priceUsd,
      'volumeUsd24Hr': cryptoDetail.volumeUsd24Hr,
      'percentChange24h': cryptoDetail.percentChange24h,
      'percentChange7d': cryptoDetail.percentChange7d,
      'marketCapUsd': cryptoDetail.marketCapUsd,
      'circulatingSupply': cryptoDetail.circulatingSupply,
      'totalSupply': cryptoDetail.totalSupply,
      'maxSupply': cryptoDetail.maxSupply,
      'logoUrl': cryptoDetail.logoUrl,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Método para obtener criptomonedas almacenadas en caché (Firestore)
  Future<List<CryptoDetail>> getCachedCryptoDetails() async {
    try {
      final snapshot = await _firestore.collection('crypto_details').get();
      final List<CryptoDetail> cachedDetails = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;

        // Verifica si el timestamp es menor a 720 minutos (12 horas)
        if (timestamp != null &&
            DateTime.now().difference(timestamp.toDate()).inMinutes < 720) {
          cachedDetails.add(CryptoDetail.fromFirestore(data));
        }
      }
      return cachedDetails.take(100).toList();
    } catch (e) {
      throw Exception('Error al obtener datos en caché: $e');
    }
  }
}
