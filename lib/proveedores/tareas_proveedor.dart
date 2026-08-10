import '../modelos/aula.dart';
import '../nucleo/excepciones.dart';
import '../servicios/archivo_servicio.dart';
import '../servicios/estudiante_servicio.dart';
import 'proveedor_base.dart';

class TareasProveedor extends ProveedorBase {
  TareasProveedor(this._servicio, this._archivos);

  final EstudianteServicio _servicio;
  final ArchivoServicio _archivos;

  List<Tarea> _tareas = const [];

  /// Id de la tarea que se está entregando, para bloquear su botón.
  int? _tareaEnProceso;

  List<Tarea> get tareas => _tareas;
  int? get tareaEnProceso => _tareaEnProceso;
  bool get vacio => _tareas.isEmpty;

  List<Tarea> get pendientes =>
      _tareas.where((t) => t.estado == EstadoTarea.pendiente).toList();

  List<Tarea> get entregadas => _tareas
      .where(
        (t) =>
            t.estado == EstadoTarea.entregada ||
            t.estado == EstadoTarea.calificada,
      )
      .toList();

  List<Tarea> get vencidas =>
      _tareas.where((t) => t.estado == EstadoTarea.vencida).toList();

  @override
  Future<void> cargar({bool silencioso = false}) => ejecutar(
    () async => _tareas = await _servicio.tareas(),
    silencioso: silencioso,
  );

  /// Sube el archivo y registra la entrega. Devuelve null si todo fue bien.
  Future<String?> entregarArchivo(
    int tareaId,
    List<int> bytes,
    String nombreArchivo,
  ) async {
    return _entregar(tareaId, () async {
      final url = await _archivos.subir(bytes, nombreArchivo);
      await _servicio.entregarTarea(tareaId, url);
    });
  }

  /// Entrega pegando un enlace externo en lugar de subir un archivo.
  Future<String?> entregarEnlace(int tareaId, String enlace) async {
    return _entregar(
      tareaId,
      () => _servicio.entregarTarea(tareaId, enlace.trim()),
    );
  }

  Future<String?> _entregar(int tareaId, Future<void> Function() accion) async {
    _tareaEnProceso = tareaId;
    notifyListeners();
    try {
      await accion();
      await cargar(silencioso: true);
      return null;
    } on ErrorApi catch (e) {
      return e.mensaje;
    } catch (_) {
      return 'No se pudo enviar la entrega. Inténtalo de nuevo.';
    } finally {
      _tareaEnProceso = null;
      notifyListeners();
    }
  }
}
