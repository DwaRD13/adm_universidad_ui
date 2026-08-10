import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/usuario.dart';

/// Guarda el token y el usuario en el dispositivo para que la sesión sobreviva
/// al cierre de la aplicación.
class AlmacenSesion {
  static const _claveToken = 'uniconnect_token';
  static const _claveUsuario = 'uniconnect_usuario';
  static const _claveTema = 'uniconnect_tema';

  Future<void> guardar(String token, Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveToken, token);
    await prefs.setString(_claveUsuario, jsonEncode(usuario.aJson()));
  }

  Future<String?> leerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_claveToken);
  }

  Future<Usuario?> leerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final crudo = prefs.getString(_claveUsuario);
    if (crudo == null) return null;
    try {
      return Usuario.desdeJson(jsonDecode(crudo) as Map<String, dynamic>);
    } catch (_) {
      // Si el formato guardado quedó obsoleto se descarta en lugar de romper el arranque.
      return null;
    }
  }

  Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveToken);
    await prefs.remove(_claveUsuario);
  }

  /// Preferencia de tema: 'claro', 'oscuro' o 'sistema'.
  Future<void> guardarTema(String modo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveTema, modo);
  }

  Future<String?> leerTema() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_claveTema);
  }
}
