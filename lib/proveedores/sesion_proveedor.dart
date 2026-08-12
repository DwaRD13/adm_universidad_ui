import 'package:flutter/foundation.dart';

import '../modelos/usuario.dart';
import '../nucleo/api_cliente.dart';
import '../nucleo/excepciones.dart';
import '../nucleo/sesion.dart';
import '../servicios/auth_servicio.dart';

/// Estado de la sesión: quién ha iniciado sesión y con qué token.
///
/// Es la fuente de verdad para el router: mientras [comprobando] es true se
/// muestra la pantalla de arranque; después se redirige según haya usuario o no.
class SesionProveedor extends ChangeNotifier {
  SesionProveedor({
    required this._api,
    required this._auth,
    AlmacenSesion? almacen,
  }) : _almacen = almacen ?? AlmacenSesion() {
    // Cuando cualquier petición recibe 401, la sesión se cierra en un solo sitio.
    _api.alExpirarSesion = () => cerrarSesion(porExpiracion: true);
  }

  final ApiCliente _api;
  final AuthServicio _auth;
  final AlmacenSesion _almacen;

  Usuario? _usuario;
  bool _comprobando = true;
  bool _procesando = false;
  String? _error;

  /// Se pone a true cuando la sesión caduca sola, para avisar al usuario.
  bool _expirada = false;

  Usuario? get usuario => _usuario;
  bool get autenticado => _usuario != null;
  bool get comprobando => _comprobando;
  bool get procesando => _procesando;
  String? get error => _error;
  bool get expirada => _expirada;

  /// Expuesto para que los servicios de cada módulo (Profesor, Estudiante) puedan
  /// crear su instancia sin depender de un Provider<ApiCliente> aparte.
  ApiCliente get api => _api;

  /// Restaura la sesión guardada al arrancar la aplicación.
  Future<void> restaurar() async {
    final token = await _almacen.leerToken();
    if (token == null) {
      _comprobando = false;
      notifyListeners();
      return;
    }

    _api.token = token;
    // Se usa el usuario guardado para pintar de inmediato y se revalida contra
    // la API; si el token ya no sirve, el 401 cierra la sesión solo.
    _usuario = await _almacen.leerUsuario();

    try {
      _usuario = await _auth.yo();
      await _almacen.guardar(token, _usuario!);
    } on ErrorApi {
      _api.token = null;
      _usuario = null;
      await _almacen.limpiar();
    }

    _comprobando = false;
    notifyListeners();
  }

  Future<bool> iniciarSesion(String email, String password) async {
    _procesando = true;
    _error = null;
    _expirada = false;
    notifyListeners();

    try {
      final resultado = await _auth.iniciarSesion(email, password);
      _api.token = resultado.token;
      _usuario = resultado.usuario;
      await _almacen.guardar(resultado.token, resultado.usuario);
      return true;
    } on ErrorApi catch (e) {
      _error = e.mensaje;
      return false;
    } catch (_) {
      _error = 'Ocurrió un error inesperado. Inténtalo de nuevo.';
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  Future<void> cerrarSesion({bool porExpiracion = false}) async {
    _api.token = null;
    _usuario = null;
    _expirada = porExpiracion;
    _error = null;
    await _almacen.limpiar();
    notifyListeners();
  }

  /// Refresca los datos del usuario tras editar el perfil.
  void actualizarUsuario(Usuario usuario) {
    _usuario = usuario;
    notifyListeners();
    _almacen.leerToken().then((token) {
      if (token != null) _almacen.guardar(token, usuario);
    });
  }

  void limpiarError() {
    if (_error == null && !_expirada) return;
    _error = null;
    _expirada = false;
    notifyListeners();
  }
}