import 'package:flutter/foundation.dart';

/// Configuración de entorno del cliente.
class Constantes {
  const Constantes._();

  /// URL base de la API.
  ///
  /// Se puede fijar al compilar sin tocar el código:
  /// `flutter run --dart-define=API_URL=http://192.168.1.20:8080`
  ///
  /// Por defecto se elige según la plataforma, porque `localhost` significa
  /// cosas distintas en el emulador de Android y en el navegador.
  static String get urlBase {
    const definida = String.fromEnvironment('API_URL');
    if (definida.isNotEmpty) return definida;

    // El emulador de Android alcanza la máquina anfitriona por 10.0.2.2.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  /// Nombre de la institución que se muestra en el login.
  static const String nombreInstitucion = 'UniConnect';

  /// Roles tal como los devuelve la API (tabla `roles`).
  static const String rolEstudiante = 'Estudiante';
  static const String rolProfesor = 'Profesor';
  static const String rolAdministrativo = 'Administrativo';
}
