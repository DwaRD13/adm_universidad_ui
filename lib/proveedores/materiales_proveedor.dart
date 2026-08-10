import '../modelos/aula.dart';
import '../servicios/estudiante_servicio.dart';
import 'proveedor_base.dart';

class MaterialesProveedor extends ProveedorBase {
  MaterialesProveedor(this._servicio);

  final EstudianteServicio _servicio;

  List<Material> _materiales = const [];

  List<Material> get materiales => _materiales;
  bool get vacio => _materiales.isEmpty;

  /// Materiales agrupados por materia, que es como se navegan en la pantalla.
  Map<String, List<Material>> get porMateria {
    final mapa = <String, List<Material>>{};
    for (final material in _materiales) {
      mapa.putIfAbsent(material.materia, () => []).add(material);
    }
    return mapa;
  }

  @override
  Future<void> cargar({bool silencioso = false}) => ejecutar(
    () async => _materiales = await _servicio.materiales(),
    silencioso: silencioso,
  );
}
