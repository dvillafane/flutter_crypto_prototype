// Carga las variables de entorno desde el archivo .env
require('dotenv').config();

// Importa los módulos necesarios para el servidor proxy
const express = require('express');
const axios = require('axios');
const cors = require('cors');

// Crea una instancia de la aplicación Express
const app = express();
// Define el puerto en el que el servidor escuchará las solicitudes
const port = 3000;

// Obtiene la clave API desde las variables de entorno (definida en el archivo .env)
const apiKey = process.env.CMC_API_KEY;

// Habilita CORS para todas las rutas del servidor
app.use(cors());

// Middleware para analizar las solicitudes con cuerpo JSON
app.use(express.json());

// Define un endpoint para reenviar solicitudes a CoinMarketCap
app.get('/api/cryptocurrency/listings/latest', async (req, res) => {
    try {
        // Verifica si la clave API está disponible
        if (!apiKey) {
            return res.status(500).json({ error: 'Clave API no encontrada en las variables de entorno' });
        }

        // Realiza una solicitud GET a la API de CoinMarketCap usando axios
        const response = await axios.get(
            'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest',
            {
                params: req.query, // Pasa los parámetros de consulta recibidos
                headers: {
                    'X-CMC_PRO_API_KEY': apiKey, // Usa la clave API del archivo .env
                    Accept: 'application/json',
                },
            }
        );

        // Devuelve los datos obtenidos de CoinMarketCap como respuesta al cliente
        res.json(response.data);
    } catch (error) {
        // Si hay un error, lo registra y devuelve un error al cliente
        console.error('Error al obtener datos de CoinMarketCap:', error.message);
        res.status(500).json({ error: 'Fallo al obtener datos de CoinMarketCap' });
    }
});

// Inicia el servidor y lo hace escuchar en el puerto especificado
app.listen(port, () => {
    console.log(`Servidor proxy corriendo en http://localhost:${port}`);
});