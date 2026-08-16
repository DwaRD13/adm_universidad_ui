import '../modelos/profesor/estudiante_asistencia_profesor.dart';
import '../modelos/profesor/registro_asistencia_profesor.dart';
import '../servicios/profesor_servicio.dart';
import 'proveedor_base.dart';

class AsistenciaDetalleProfesorProveedor
    extends ProveedorBase {
  AsistenciaDetalleProfesorProveedor(
    this._servicio,
    this.seccionId,
  );

  final ProfesorServicio _servicio;
  final int seccionId;

  DateTime fechaSeleccionada =
    DateTime.now();

  List<EstudianteAsistenciaProfesor> _estudiantes =
      const [];

  final Map<int, RegistroAsistenciaProfesor>
      registros = {};

  List<EstudianteAsistenciaProfesor>
      get estudiantes => _estudiantes;

  bool get vacio => _estudiantes.isEmpty;

  @override
  Future<void> cargar({
    bool silencioso = false,
  }) =>
      ejecutar(() async {
        _estudiantes =
          await _servicio.estudiantesDeSeccion(
        seccionId,
        fechaSeleccionada,
      );

registros.clear();

for (final estudiante in _estudiantes) {
  registros[estudiante.inscripcionId] =
      RegistroAsistenciaProfesor(
    inscripcionId: estudiante.inscripcionId,
    estado: estudiante.estado,
    observaciones: estudiante.observaciones,
  );
}
      }, silencioso: silencioso);

  void actualizarEstado(
    int inscripcionId,
    String estado,
  ) {
    registros[inscripcionId]?.estado = estado;

    notifyListeners();
  }

  Future<void> cambiarFecha(
    DateTime fecha,
  ) async {
    fechaSeleccionada = fecha;

    await cargar(
      silencioso: true,
    );

    notifyListeners();
  }

  Future<void> guardar() =>
    _servicio.registrarAsistencia(
      seccionId: seccionId,
      fecha: fechaSeleccionada,
      registros: registros.values.toList(),
    );
}