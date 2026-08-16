import '../modelos/profesor/estudiante_calificacion_profesor.dart';
import '../modelos/profesor/registro_calificacion_profesor.dart';
import '../servicios/profesor_servicio.dart';
import 'proveedor_base.dart';

class CalificacionDetalleProfesorProveedor
    extends ProveedorBase {
  CalificacionDetalleProfesorProveedor(
    this._servicio,
    this.seccionId,
  );

  final ProfesorServicio _servicio;
  final int seccionId;

  List<EstudianteCalificacionProfesor>
      _estudiantes = const [];

  final Map<int, RegistroCalificacionProfesor>
      registros = {};

  List<EstudianteCalificacionProfesor>
      get estudiantes => _estudiantes;

  bool get vacio => _estudiantes.isEmpty;

  @override
  Future<void> cargar({
    bool silencioso = false,
  }) =>
      ejecutar(() async {
        _estudiantes =
            await _servicio
                .calificacionesSeccion(
          seccionId,
        );

        registros.clear();

        for (final estudiante
            in _estudiantes) {
          registros[estudiante.inscripcionId] =
              RegistroCalificacionProfesor(
            inscripcionId:
                estudiante.inscripcionId,
            nota: estudiante.nota
                    ?.toDouble(),
          );
        }
      }, silencioso: silencioso);

  void actualizarNota(
    int inscripcionId,
    double? nota,
  ) {
    registros[inscripcionId]?.nota = nota;

    notifyListeners();
  }

  Future<void> guardar() =>
      _servicio.registrarCalificaciones(
        seccionId: seccionId,
        registros:
            registros.values.toList(),
      );
}