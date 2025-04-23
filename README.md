# flutter_crypto_prototype

Esta aplicación Flutter es una interfaz que interactúa con una API y WebSocket de Binance, obtiene y muestra información sobre criptomonedas en orden descendente con su logo, nombres y precios actualizados en tiempo real. También permite buscar criptos por nombre y ahora incluye soporte para notificaciones push tanto en dispositivos móviles como en la web.

## Características

- **Listado de Criptos** 🏆: Muestra una lista de criptomonedas con logo, nombres y precios actualizados en tiempo real.
- **Búsqueda y Filtros** 🎯: Permite buscar criptos por nombre.
- **Interfaz Interactiva** 🎨: Utiliza tarjetas que muestran logo, nombres y precios con un cambio de color cuando el precio varía.
- **Notificaciones Push** 📩: Soporte para notificaciones push en primer plano y en segundo plano usando Firebase Cloud Messaging.
- **Arquitectura BLoC** 🛠️: Implementa el patrón BLoC para manejar el estado, incluyendo la gestión de notificaciones.
- **Soporte Multiplataforma** 🌐: Funciona tanto en dispositivos móviles (Android) como en navegadores web.

## Requerimientos

- [Flutter](https://docs.flutter.dev/get-started/install) (versión 3.x o superior recomendada).
- [Android Studio](https://developer.android.com/studio/install?hl=es-419#windows) (para depurar y compilar en Android).
- [Git para Windows](https://gitforwindows.org/) para administrar el código fuente.
- [Visual Studio Code](https://code.visualstudio.com/docs/setup/windows) (editor recomendado para Flutter, junto con la extensión [Flutter para VS Code](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)).
- [Firebase](https://firebase.google.com/?hl=es-419) para usar Cloud Firestore y Firebase Cloud Messaging.
- Cuenta de [CoinMarketCap](https://coinmarketcap.com/api/) para usar su API.
- Emulador o dispositivo Android para probar la aplicación en móvil.
- Un navegador moderno (como Chrome) para probar la aplicación en web.

## Instalacion

Siga los pasos a continuación para configurar y ejecutar la aplicación en su entorno local.

### 1. Clonar el repositorio
Abra su terminal favorito y ejecute:
```sh
git git@github.com:dvillafane/flutter_crypto_prototype.git
```

### 2. Navegar al directorio del proyecto
Una vez clonado el repositorio, ingrese al directorio del proyecto:
```sh
cd flutter_crypto_prototype
```

### 3. Instalar las dependencias
Dentro del directorio del proyecto, ejecute:
```sh
flutter pub get
```

### 4. Crear una Cuenta/Proyecto en Firebase
Si aún no tienes una cuenta en Firebase:

  - Ve a Firebase Console.

  - Inicia sesión con tu cuenta de Google

  - Haz clic en "Crear un proyecto".

  - Ingresa un nombre, espera a que se cree el proyecto y haz clic en Continuar.

  - Habilita Cloud Firestore para almacenamiento de datos.

  - Habilita Firebase Cloud Messaging para notificaciones push.
    - Ve a "Cloud Messaging" en el menú de Firebase.
    - Genera un par de claves para la web (clave VAPID) si planeas probar en navegadores.
    - Descarga el archivo google-services.json (para Android) y colócalo en android/app/.

### 5. Configurar el Archivo .env
  - Crea un archivo .env en la raíz del proyecto.
  - Agrega las siguientes claves:
    - COINMARKETCAP_API_KEY=tu_clave_de_api_de_coinmarketcap
    - VAPID_KEY=tu_clave_vapid_de_firebase

### 6. Configurar el emulador de Android
Si aún no tiene un emulador configurado:

  - Abra Android Studio.

  - Vaya a Virtual Device Manager.
  
  - Configure un nuevo emulador Android siguiendo las instrucciones en pantalla.

### 7. Ejecutar la aplicación
En un emulador o dispositivo Android:
```sh
flutter run
```
En un navegador web (como Chrome):
```sh
flutter run -d chrome
```