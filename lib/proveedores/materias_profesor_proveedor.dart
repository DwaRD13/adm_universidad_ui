import '../../modelos/profesor/materia_profesor.dart';
import '../../servicios/profesor_servicio.dart';
import 'proveedor_base.dart';

class MateriasProfesorProveedor extends ProveedorBase {
  MateriasProfesorProveedor(this._servicio);

  final ProfesorServicio _servicio;

  List<MateriaProfesor> _materias = const [];

  List<MateriaProfesor> get materias => _materias;

  bool get vacio => _materias.isEmpty;

  @override
  Future<void> cargar({bool silencioso = false}) => ejecutar(
        () async {
          _materias = await _servicio.materias();
        },
        silencioso: silencioso,
      );
}