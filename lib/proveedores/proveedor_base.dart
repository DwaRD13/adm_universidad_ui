import 'package:flutter/foundation.dart';

import '../nucleo/excepciones.dart';

/// Contrato común de todos los proveedores de módulo.
///
/// Las nueve pantallas del estudiante se comportan igual gracias a este trío:
/// mientras [cargando] se muestra el esqueleto, si hay [error] se muestra el
/// reintento, y si no hay datos se muestra el estado vacío ilustrado.
abstract class ProveedorBase extends ChangeNotifier {
  bool _cargando = false;
  String? _error;

  /// Ya se cargó al menos una vez: evita mostrar el esqueleto en cada refresco.
  bool _cargadoAlgunaVez = false;

  bool get cargando => _cargando;
  String? get error => _error;
  bool get cargadoAlgunaVez => _cargadoAlgunaVez;

  /// Envuelve una petición aplicando el ciclo cargando -> datos/error.
  ///
  /// [silencioso] evita el estado de carga cuando el usuario hace "deslizar para
  /// refrescar", que ya tiene su propio indicador.
  @protected
  Future<bool> ejecutar(
    Future<void> Function() accion, {
    bool silencioso = false,
  }) async {
    if (!silencioso) {
      _cargando = true;
      _error = null;
      notifyListeners();
    }

    try {
      await accion();
      _error = null;
      _cargadoAlgunaVez = true;
      return true;
    } on ErrorApi catch (e) {
      _error = e.mensaje;
      return false;
    } catch (_) {
      _error = 'Ocurrió un error inesperado. Inténtalo de nuevo.';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Limpia el mensaje de error tras mostrarlo, para que no reaparezca.
  void limpiarError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// Carga inicial del módulo. Cada proveedor decide qué pide.
  Future<void> cargar();
}
