import '../modelos/academico.dart';
import '../servicios/estudiante_servicio.dart';
import 'proveedor_base.dart';

class AsistenciaProveedor extends ProveedorBase {
  AsistenciaProveedor(this._servicio);

  final EstudianteServicio _servicio;

  Asistencia? _datos;

  Asistencia? get datos => _datos;
  bool get vacio => _datos == null || _datos!.vacio;

  @override
  Future<void> cargar({bool silencioso = false}) => ejecutar(
    () async => _datos = await _servicio.asistencias(),
    silencioso: silencioso,
  );
}
