import '../modelos/usuario.dart';
import '../nucleo/excepciones.dart';
import '../servicios/estudiante_servicio.dart';
import 'proveedor_base.dart';

class PerfilProveedor extends ProveedorBase {
  PerfilProveedor(this._servicio);

  final EstudianteServicio _servicio;

  Usuario? _usuario;
  bool _guardando = false;

  Usuario? get usuario => _usuario;
  bool get guardando => _guardando;

  @override
  Future<void> cargar({bool silencioso = false}) => ejecutar(
    () async => _usuario = await _servicio.perfil(),
    silencioso: silencioso,
  );

  /// Devuelve null si se guardó, o el mensaje de error.
  Future<String?> guardar({
    String? telefono,
    String? passwordActual,
    String? passwordNueva,
  }) async {
    _guardando = true;
    notifyListeners();

    try {
      _usuario = await _servicio.actualizarPerfil(
        telefono: telefono,
        passwordActual: passwordActual,
        passwordNueva: passwordNueva,
      );
      return null;
    } on ErrorApi catch (e) {
      return e.mensaje;
    } catch (_) {
      return 'No se pudieron guardar los cambios. Inténtalo de nuevo.';
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }
}
