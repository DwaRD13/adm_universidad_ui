import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../app/constantes.dart';
import 'excepciones.dart';

/// Cliente HTTP único de la aplicación.
///
/// Centraliza la URL base, la cabecera `Authorization`, la codificación JSON y la
/// traducción de errores, para que ningún servicio tenga que repetir esa fontanería.
class ApiCliente {
  ApiCliente({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  /// Token de la sesión activa. Lo actualiza [SesionProveedor] al entrar y salir.
  String? token;

  /// Se invoca cuando la API responde 401: permite al proveedor de sesión cerrar
  /// la sesión y devolver al usuario al login sin que cada pantalla lo gestione.
  void Function()? alExpirarSesion;

  static const Duration _tiempoLimite = Duration(seconds: 20);

  Future<dynamic> get(String ruta) =>
      _enviar(() => _cliente.get(_uri(ruta), headers: _cabeceras()));

  Future<dynamic> post(String ruta, [Object? cuerpo]) => _enviar(
    () => _cliente.post(
      _uri(ruta),
      headers: _cabeceras(conCuerpo: true),
      body: cuerpo == null ? null : jsonEncode(cuerpo),
    ),
  );

  Future<dynamic> put(String ruta, [Object? cuerpo]) => _enviar(
    () => _cliente.put(
      _uri(ruta),
      headers: _cabeceras(conCuerpo: true),
      body: cuerpo == null ? null : jsonEncode(cuerpo),
    ),
  );

  Future<dynamic> delete(String ruta) =>
      _enviar(() => _cliente.delete(_uri(ruta), headers: _cabeceras()));

  /// Sube un archivo por multipart y devuelve el cuerpo decodificado.
  Future<dynamic> subirArchivo(
    String ruta,
    List<int> bytes,
    String nombreArchivo,
  ) {
    return _enviar(() async {
      final peticion = http.MultipartRequest('POST', _uri(ruta))
        ..files.add(
          http.MultipartFile.fromBytes(
            'archivo',
            bytes,
            filename: nombreArchivo,
          ),
        );
      if (token != null) {
        peticion.headers['Authorization'] = 'Bearer $token';
      }
      final respuesta = await peticion.send();
      return http.Response.fromStream(respuesta);
    });
  }

  Uri _uri(String ruta) => Uri.parse('${Constantes.urlBase}$ruta');

  Map<String, String> _cabeceras({bool conCuerpo = false}) => {
    'Accept': 'application/json',
    if (conCuerpo) 'Content-Type': 'application/json; charset=utf-8',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<dynamic> _enviar(Future<http.Response> Function() peticion) async {
    final http.Response respuesta;
    try {
      respuesta = await peticion().timeout(_tiempoLimite);
    } on TimeoutException {
      throw const ErrorConexion();
    } on SocketException {
      throw const ErrorConexion();
    } on http.ClientException {
      throw const ErrorConexion();
    }

    // El backend responde siempre UTF-8; se decodifica explícitamente para que las
    // tildes y la eñe no lleguen corruptas.
    final texto = utf8.decode(respuesta.bodyBytes);
    final cuerpo = texto.isEmpty ? null : jsonDecode(texto);

    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
      return cuerpo;
    }

    if (respuesta.statusCode == 401) {
      alExpirarSesion?.call();
    }

    throw _errorDesde(cuerpo, respuesta.statusCode);
  }

  ErrorApi _errorDesde(dynamic cuerpo, int codigo) {
    if (cuerpo is Map<String, dynamic>) {
      final campos = <String, String>{};
      final crudos = cuerpo['campos'];
      if (crudos is Map) {
        crudos.forEach((clave, valor) => campos['$clave'] = '$valor');
      }
      return ErrorApi(
        (cuerpo['mensaje'] as String?) ?? _mensajePorDefecto(codigo),
        codigo: codigo,
        campos: campos,
      );
    }
    return ErrorApi(_mensajePorDefecto(codigo), codigo: codigo);
  }

  String _mensajePorDefecto(int codigo) => switch (codigo) {
    401 => 'Tu sesión expiró. Vuelve a iniciar sesión.',
    403 => 'No tienes permiso para realizar esta acción.',
    404 => 'No encontramos lo que buscabas.',
    >= 500 => 'El servidor tuvo un problema. Inténtalo más tarde.',
    _ => 'No se pudo completar la operación.',
  };
}
