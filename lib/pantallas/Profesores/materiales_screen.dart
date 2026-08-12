import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../modelos/profesor/material_profesor.dart';
import '../../modelos/profesor/seccion_profesor.dart';
import '../../nucleo/excepciones.dart';
import '../../proveedores/sesion_proveedor.dart';
import '../../servicios/profesor_servicio.dart';
import 'widgets_profesor.dart';

class MaterialesProfesorScreen extends StatefulWidget {
  const MaterialesProfesorScreen({super.key});

  @override
  State<MaterialesProfesorScreen> createState() => _MaterialesProfesorScreenState();
}

class _MaterialesProfesorScreenState extends State<MaterialesProfesorScreen> {
  late final ProfesorServicio _servicio;
  bool _cargando = true;
  String? _error;
  List<MaterialProfesor> _materiales = [];
  List<SeccionProfesor> _secciones = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cargando && _materiales.isEmpty && _error == null) {
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
      final resultados = await Future.wait([_servicio.materiales(), _servicio.secciones()]);
      if (mounted) {
        setState(() {
          _materiales = resultados[0] as List<MaterialProfesor>;
          _secciones = resultados[1] as List<SeccionProfesor>;
        });
      }
    } on ErrorApi catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudieron cargar los materiales.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrirCrear() async {
    if (_secciones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes secciones disponibles.')),
      );
      return;
    }
    final cambio = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormularioMaterial(servicio: _servicio, secciones: _secciones),
    );
    if (cambio == true) _cargar();
  }

  Future<void> _abrirEditar(MaterialProfesor material) async {
    final cambio = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormularioMaterial(
          servicio: _servicio, secciones: _secciones, materialExistente: material),
    );
    if (cambio == true) _cargar();
  }

  Future<void> _eliminar(MaterialProfesor material) async {
    final confirmado = await confirmarEliminacion(
      context,
      titulo: 'Eliminar material',
      mensaje: '¿Eliminar "${material.titulo}"? Esta acción no se puede deshacer.',
    );
    if (!confirmado) return;
    try {
      await _servicio.eliminarMaterial(material.id);
      _cargar();
    } on ErrorApi catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
    }
  }

  IconData _iconoPara(String? tipo) {
    switch (tipo?.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf_rounded;
      case 'VIDEO':
        return Icons.video_library_rounded;
      case 'ENLACE':
        return Icons.link_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colores.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profesor'),
        ),
        title: const Text('Materiales de Clase'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? VistaErrorProfesor(mensaje: _error!, alReintentar: _cargar)
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                    children: [
                      EncabezadoGradiente(
                        icono: Icons.folder_rounded,
                        titulo: '${_materiales.length} recursos publicados',
                        subtitulo: 'Comparte documentos y enlaces con tus estudiantes',
                      ),
                      const SizedBox(height: 24),
                      Text('Recursos recientes',
                          style: textos.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (_materiales.isEmpty)
                        const TarjetaVacia(
                          icono: Icons.folder_open_rounded,
                          mensaje: 'Aún no has subido ningún material.',
                        )
                      else
                        ..._materiales.map(
                          (m) => TarjetaListTile(
                            margenInferior: 10,
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colores.primaryContainer,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(_iconoPara(m.tipoArchivo),
                                    color: colores.onPrimaryContainer),
                              ),
                              title: Text(m.titulo,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text('${m.materia}\n${m.tipoArchivo ?? 'Archivo'}'),
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Abrir',
                                    icon: const Icon(Icons.open_in_new_rounded),
                                    onPressed: () async {
                                      final uri = Uri.tryParse(m.urlArchivo);
                                      if (uri != null) await launchUrl(uri);
                                    },
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert_rounded, color: colores.onSurfaceVariant),
                                    onSelected: (valor) =>
                                        valor == 'editar' ? _abrirEditar(m) : _eliminar(m),
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
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCrear,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Subir material'),
      ),
    );
  }
}

class _FormularioMaterial extends StatefulWidget {
  const _FormularioMaterial({
    required this.servicio,
    required this.secciones,
    this.materialExistente,
  });

  final ProfesorServicio servicio;
  final List<SeccionProfesor> secciones;
  final MaterialProfesor? materialExistente;

  @override
  State<_FormularioMaterial> createState() => _FormularioMaterialState();
}

class _FormularioMaterialState extends State<_FormularioMaterial> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _urlCtrl;
  int? _seccionId;
  String _tipo = 'Enlace';
  bool _guardando = false;
  String? _error;

  bool get _editando => widget.materialExistente != null;

  @override
  void initState() {
    super.initState();
    final material = widget.materialExistente;
    _tituloCtrl = TextEditingController(text: material?.titulo ?? '');
    _descripcionCtrl = TextEditingController(text: material?.descripcion ?? '');
    _urlCtrl = TextEditingController(text: material?.urlArchivo ?? '');
    _seccionId = material?.seccionId;
    _tipo = material?.tipoArchivo ?? 'Enlace';
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _seccionId == null) {
      setState(() => _error = 'Completa la sección y la URL del recurso.');
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      if (_editando) {
        await widget.servicio.actualizarMaterial(
          materialId: widget.materialExistente!.id,
          seccionId: _seccionId!,
          titulo: _tituloCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
          tipoArchivo: _tipo,
          urlArchivo: _urlCtrl.text.trim(),
        );
      } else {
        await widget.servicio.crearMaterial(
          seccionId: _seccionId!,
          titulo: _tituloCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
          tipoArchivo: _tipo,
          urlArchivo: _urlCtrl.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on ErrorApi catch (e) {
      setState(() => _error = e.mensaje);
    } catch (_) {
      setState(() => _error = 'No se pudo guardar el material.');
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
            Text(_editando ? 'Editar material' : 'Agregar material',
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
              maxLines: 2,
              decoration:
                  const InputDecoration(labelText: 'Descripción (opcional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
              items: const ['PDF', 'Video', 'Enlace']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _tipo = v ?? 'Enlace'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _urlCtrl,
              decoration: const InputDecoration(
                labelText: 'URL del recurso',
                hintText: 'https://...',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Pega el enlace del recurso.' : null,
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
                    : Text(_editando ? 'Guardar cambios' : 'Guardar material'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}