import '../modelos/academico.dart';
import '../servicios/estudiante_servicio.dart';
import 'proveedor_base.dart';

class CalificacionesProveedor extends ProveedorBase {
  CalificacionesProveedor(this._servicio);

  final EstudianteServicio _servicio;

  Calificaciones? _datos;

  Calificaciones? get datos => _datos;
  bool get vacio => _datos == null || _datos!.vacio;

  /// Notas agrupadas por periodo académico, del más reciente al más antiguo.
  Map<String, List<Calificacion>> get porPeriodo {
    final mapa = <String, List<Calificacion>>{};
    for (final nota in _datos?.calificaciones ?? const <Calificacion>[]) {
      mapa.putIfAbsent(nota.periodo, () => []).add(nota);
    }
    return mapa;
  }

  @override
  Future<void> cargar({bool silencioso = false}) => ejecutar(
    () async => _datos = await _servicio.calificaciones(),
    silencioso: silencioso,
  );
}
