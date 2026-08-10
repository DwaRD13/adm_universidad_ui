/// Error de la API ya traducido a algo que se le puede enseñar al usuario.
///
/// El backend devuelve siempre `{ mensaje, codigo, campos }` en español, así que
/// [mensaje] se muestra tal cual sin necesidad de reinterpretarlo aquí.
class ErrorApi implements Exception {
  const ErrorApi(this.mensaje, {this.codigo = 0, this.campos = const {}});

  final String mensaje;
  final int codigo;

  /// Errores de validación por campo, para pintarlos bajo cada input.
  final Map<String, String> campos;

  /// La sesión caducó o el token ya no vale: hay que volver al login.
  bool get sesionInvalida => codigo == 401;

  /// El rol del usuario no puede usar este recurso.
  bool get sinPermiso => codigo == 403;

  @override
  String toString() => mensaje;
}

/// No se pudo contactar con el servidor (sin red, backend apagado, timeout).
class ErrorConexion extends ErrorApi {
  const ErrorConexion()
    : super(
        'No pudimos conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.',
      );
}
