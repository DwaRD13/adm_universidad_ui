import '../modelos/academico.dart';
import '../servicios/estudiante_servicio.dart';
import 'proveedor_base.dart';

class HorarioProveedor extends ProveedorBase {
  HorarioProveedor(this._servicio);

  final EstudianteServicio _servicio;

  List<ClaseHorario> _clases = const [];

  List<ClaseHorario> get clases => _clases;
  bool get vacio => _clases.isEmpty;

  /// Clases de un día concreto ('Lu', 'Ma'...), ya ordenadas por hora de inicio.
  List<ClaseHorario> delDia(String dia) =>
      _clases.where((c) => c.dias.contains(dia)).toList();

  /// Días de la semana en los que el estudiante tiene alguna clase.
  List<String> get diasConClase {
    const orden = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa'];
    return orden.where((d) => _clases.any((c) => c.dias.contains(d))).toList();
  }

  int get totalCreditos => _clases.fold(0, (suma, c) => suma + c.creditos);

  @override
  Future<void> cargar({bool silencioso = false}) => ejecutar(
    () async => _clases = await _servicio.horario(),
    silencioso: silencioso,
  );
}
