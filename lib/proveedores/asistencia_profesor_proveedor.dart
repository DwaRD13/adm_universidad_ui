import '../../modelos/profesor/asistencia_profesor.dart';
import '../../servicios/profesor_servicio.dart';
import 'proveedor_base.dart';

class AsistenciaProfesorProveedor extends ProveedorBase {
  AsistenciaProfesorProveedor(this._servicio);

  final ProfesorServicio _servicio;

  List<AsistenciaProfesor> _asistencias = const [];

  List<AsistenciaProfesor> get asistencias => _asistencias;

  bool get vacio => _asistencias.isEmpty;

  @override
  Future<void> cargar({bool silencioso = false}) => ejecutar(
        () async {
          _asistencias = await _servicio.asistencia();
        },
        silencioso: silencioso,
      );
}