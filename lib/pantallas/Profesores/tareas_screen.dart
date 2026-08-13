import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../modelos/profesor/entrega_profesor.dart';
import '../../modelos/profesor/seccion_profesor.dart';
import '../../modelos/profesor/tarea_profesor.dart';
import '../../nucleo/excepciones.dart';
import '../../proveedores/sesion_proveedor.dart';
import '../../servicios/profesor_servicio.dart';
import 'widgets_profesor.dart';

class TareasProfesorScreen extends StatefulWidget {
  const TareasProfesorScreen({super.key});

  @override
  State<TareasProfesorScreen> createState() => _TareasProfesorScreenState();
}

class _TareasProfesorScreenState extends State<TareasProfesorScreen> {
  late final ProfesorServicio _servicio;
  bool _cargando = true;
  String? _error;
  List<TareaProfesor> _tareas = [];
  List<SeccionProfesor> _secciones = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cargando && _tareas.isEmpty && _error == null) {
      _servicio = ProfesorServicio(context.read<SesionProveedor>().api);
      _cargar();
    }
  }

  Future<void> _cargar() async {
    if (!mounted) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final resultados = await Future.wait([_servicio.tareas(), _servicio.secciones()]);
      if (mounted) {
        setState(() {
          _tareas = resultados[0] as List<TareaProfesor>;
          _secciones = resultados[1] as List<SeccionProfesor>;
        });
      }
    } on ErrorApi catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudieron cargar las tareas.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrirCrear() async {
    if (_secciones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes secciones disponibles para asignar una tarea.')),
      );
      return;
    }
    final cambio = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormularioTarea(servicio: _servicio, secciones: _secciones),
    );
    if (cambio == true) _cargar();
  }

  Future<void> _abrirEditar(TareaProfesor tarea) async {
    final cambio = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          _FormularioTarea(servicio: _servicio, secciones: _secciones, tareaExistente: tarea),
    );
    if (cambio == true) _cargar();
  }

  Future<void> _eliminar(TareaProfesor tarea) async {
    final confirmado = await confirmarEliminacion(
      context,
      titulo: 'Eliminar tarea',
      mensaje: '¿Eliminar "${tarea.titulo}"? También se borrarán las entregas asociadas.',
    );
    if (!confirmado) return;
    try {
      await _servicio.eliminarTarea(tarea.id);
      _cargar();
    } on ErrorApi catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
    }
  }

  Future<void> _abrirEntregas(TareaProfesor tarea) async {
    final cambio = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EntregasTarea(servicio: _servicio, tarea: tarea),
    );
    if (cambio == true) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final pendientesTotal =
        _tareas.fold<int>(0, (s, t) => s + (t.totalEstudiantes - t.entregadas));

    return Scaffold(
      backgroundColor: colores.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profesor'),
        ),
        title: const Text('Tareas'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? VistaErrorProfesor(mensaje: _error!, alReintentar: _cargar)
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: [
                      EncabezadoGradiente(
                        icono: Icons.assignment_rounded,
                        titulo: '$pendientesTotal entregas pendientes',
                        subtitulo: '${_tareas.length} tareas activas en tus secciones',
                      ),
                      const SizedBox(height: 24),
                      Text('Tus tareas',
                          style: textos.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (_tareas.isEmpty)
                        const TarjetaVacia(
                          icono: Icons.assignment_outlined,
                          mensaje: 'Aún no has asignado ninguna tarea.',
                        )
                      else
                        ..._tareas.map(
                          (t) => _TarjetaTarea(
                            tarea: t,
                            onTap: () => _abrirEntregas(t),
                            onEditar: () => _abrirEditar(t),
                            onEliminar: () => _eliminar(t),
                          ),
                        ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCrear,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva tarea'),
      ),
    );
  }
}

class _TarjetaTarea extends StatelessWidget {
  const _TarjetaTarea({
    required this.tarea,
    required this.onTap,
    required this.onEditar,
    required this.onEliminar,
  });

  final TareaProfesor tarea;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final proporcion =
        tarea.totalEstudiantes == 0 ? 0.0 : tarea.entregadas / tarea.totalEstudiantes;
    final formato = DateFormat("d 'de' MMMM, h:mm a", 'es');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colores.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tarea.titulo,
                            style: textos.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 3),
                        Text(tarea.materia,
                            style: textos.bodySmall?.copyWith(color: colores.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (tarea.pendientesPorCalificar > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colores.errorContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${tarea.pendientesPorCalificar} por calificar',
                          style: textos.labelSmall?.copyWith(
                              color: colores.onErrorContainer, fontWeight: FontWeight.bold)),
                    ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: colores.onSurfaceVariant),
                    onSelected: (valor) => valor == 'editar' ? onEditar() : onEliminar(),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'editar',
                        child: ListTile(
                          leading: Icon(Icons.edit_rounded),
                          title: Text('Editar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'eliminar',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline_rounded),
                          title: Text('Eliminar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: proporcion,
                  minHeight: 6,
                  backgroundColor: colores.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(colores.primary),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_rounded, size: 15, color: colores.onSurfaceVariant),
                      const SizedBox(width: 5),
                      Text('Entrega: ${formato.format(tarea.fechaEntrega)}',
                          style: textos.bodySmall?.copyWith(color: colores.onSurfaceVariant)),
                    ],
                  ),
                  Text('${tarea.entregadas}/${tarea.totalEstudiantes} entregadas',
                      style: textos.labelSmall
                          ?.copyWith(color: colores.onSurfaceVariant, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formulario de creación/edición. Si [tareaExistente] viene con valor, edita; si no, crea.
class _FormularioTarea extends StatefulWidget {
  const _FormularioTarea({
    required this.servicio,
    required this.secciones,
    this.tareaExistente,
  });

  final ProfesorServicio servicio;
  final List<SeccionProfesor> secciones;
  final TareaProfesor? tareaExistente;

  @override
  State<_FormularioTarea> createState() => _FormularioTareaState();
}

class _FormularioTareaState extends State<_FormularioTarea> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descripcionCtrl;
  int? _seccionId;
  DateTime? _fechaEntrega;
  bool _guardando = false;
  String? _error;

  bool get _editando => widget.tareaExistente != null;

  @override
  void initState() {
    super.initState();
    final tarea = widget.tareaExistente;
    _tituloCtrl = TextEditingController(text: tarea?.titulo ?? '');
    _descripcionCtrl = TextEditingController(text: tarea?.descripcion ?? '');
    _seccionId = tarea?.seccionId;
    _fechaEntrega = tarea?.fechaEntrega;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaEntrega ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha == null || !mounted) return;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaEntrega ?? DateTime.now()),
    );
    if (hora == null) return;
    setState(() {
      _fechaEntrega = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _seccionId == null || _fechaEntrega == null) {
      setState(() => _error = 'Completa la sección y la fecha de entrega.');
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      if (_editando) {
        await widget.servicio.actualizarTarea(
          tareaId: widget.tareaExistente!.id,
          seccionId: _seccionId!,
          titulo: _tituloCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
          fechaEntrega: _fechaEntrega!,
        );
      } else {
        await widget.servicio.crearTarea(
          seccionId: _seccionId!,
          titulo: _tituloCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
          fechaEntrega: _fechaEntrega!,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on ErrorApi catch (e) {
      setState(() => _error = e.mensaje);
    } catch (_) {
      setState(() => _error = 'No se pudo guardar la tarea.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_editando ? 'Editar tarea' : 'Nueva tarea',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              initialValue: _seccionId,
              decoration: const InputDecoration(labelText: 'Sección', border: OutlineInputBorder()),
              items: widget.secciones
                  .map((s) => DropdownMenuItem(
                        value: s.seccionId,
                        child: Text('${s.materia} (${s.periodo})', overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _seccionId = v),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe un título.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descripcionCtrl,
              maxLines: 3,
              decoration:
                  const InputDecoration(labelText: 'Descripción (opcional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _elegirFecha,
              icon: const Icon(Icons.event_rounded),
              label: Text(_fechaEntrega == null
                  ? 'Elegir fecha de entrega'
                  : DateFormat("d 'de' MMMM, h:mm a", 'es').format(_fechaEntrega!)),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_editando ? 'Guardar cambios' : 'Crear tarea'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntregasTarea extends StatefulWidget {
  const _EntregasTarea({required this.servicio, required this.tarea});
  final ProfesorServicio servicio;
  final TareaProfesor tarea;

  @override
  State<_EntregasTarea> createState() => _EntregasTareaState();
}

class _EntregasTareaState extends State<_EntregasTarea> {
  bool _cargando = true;
  List<EntregaProfesor> _entregas = [];
  bool _huboCambios = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final entregas = await widget.servicio.entregas(widget.tarea.id);
      if (mounted) setState(() => _entregas = entregas);
    } on ErrorApi catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _calificar(EntregaProfesor entrega) async {
    final controladorNota = TextEditingController(text: entrega.calificacion?.toString() ?? '');
    final controladorComentario = TextEditingController(text: entrega.comentariosProfesor ?? '');

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Calificar a ${entrega.estudianteNombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controladorNota,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Calificación (0-100)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controladorComentario,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Comentarios (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );

    if (confirmado != true) return;
    final nota = double.tryParse(controladorNota.text.trim());
    if (nota == null || nota < 0 || nota > 100) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Escribe una calificación válida (0-100).')));
      }
      return;
    }

    try {
      await widget.servicio.calificar(
        entregaId: entrega.id,
        calificacion: nota,
        comentarios: controladorComentario.text.trim().isEmpty ? null : controladorComentario.text.trim(),
      );
      _huboCambios = true;
      _cargar();
    } on ErrorApi catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final formato = DateFormat("d MMM, h:mm a", 'es');

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_, __) {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.tarea.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${widget.tarea.entregadas} de ${widget.tarea.totalEstudiantes} entregaron',
                  style: TextStyle(color: colores.onSurfaceVariant)),
              const SizedBox(height: 16),
              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _entregas.isEmpty
                        ? const Center(child: Text('Todavía nadie ha entregado.'))
                        : ListView.separated(
                            itemCount: _entregas.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (_, i) {
                              final e = _entregas[i];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(e.estudianteNombre,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Entregó: ${formato.format(e.fechaEnvio)}'),
                                trailing: e.calificada
                                    ? Chip(label: Text('${e.calificacion}'))
                                    : FilledButton.tonal(
                                        onPressed: () => _calificar(e),
                                        child: const Text('Calificar'),
                                      ),
                                onTap: e.calificada ? () => _calificar(e) : null,
                              );
                            },
                          ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, _huboCambios),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}