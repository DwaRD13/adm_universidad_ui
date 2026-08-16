import '../../modelos/profesor/calificacion_profesor.dart';
import '../../servicios/profesor_servicio.dart';
import 'proveedor_base.dart';

class CalificacionesProfesorProveedor extends ProveedorBase {
  CalificacionesProfesorProveedor(this._servicio);

  final ProfesorServicio _servicio;

  List<CalificacionProfesor> _calificaciones = const [];

  List<CalificacionProfesor> get calificaciones => _calificaciones;

  bool get vacio => _calificaciones.isEmpty;

  @override
  Future<void> cargar({bool silencioso = false}) => ejecutar(
        () async {
          _calificaciones = await _servicio.calificaciones();
        },
        silencioso: silencioso,
      );
}