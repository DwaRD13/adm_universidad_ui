import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../modelos/profesor/conversacion.dart';
import '../../modelos/profesor/mensaje.dart';
import '../../modelos/usuario.dart';
import '../../nucleo/excepciones.dart';
import '../../proveedores/sesion_proveedor.dart';
import '../../servicios/profesor_servicio.dart';
import 'widgets_profesor.dart';

class MensajesProfesorScreen extends StatefulWidget {
  const MensajesProfesorScreen({super.key});

  @override
  State<MensajesProfesorScreen> createState() => _MensajesProfesorScreenState();
}

class _MensajesProfesorScreenState extends State<MensajesProfesorScreen> {
  late final ProfesorServicio _servicio;
  bool _cargando = true;
  String? _error;
  List<Conversacion> _conversaciones = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cargando && _conversaciones.isEmpty && _error == null) {
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
      final conversaciones = await _servicio.conversaciones();
      if (mounted) setState(() => _conversaciones = conversaciones);
    } on ErrorApi catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudieron cargar los mensajes.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrirHilo(int otroId, String nombre) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _HiloScreen(servicio: _servicio, otroId: otroId, nombre: nombre),
      ),
    );
    _cargar();
  }

  Future<void> _nuevoMensaje() async {
    List<Usuario> contactos;
    try {
      contactos = await _servicio.contactos();
    } on ErrorApi catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
      return;
    }

    if (!mounted) return;
    if (contactos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes estudiantes disponibles para contactar.')),
      );
      return;
    }

    final elegido = await showModalBottomSheet<Usuario>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: contactos
            .map((u) => ListTile(
                  leading: CircleAvatar(child: Text(u.nombres.isNotEmpty ? u.nombres[0] : '?')),
                  title: Text(u.nombreCompleto),
                  onTap: () => Navigator.pop(context, u),
                ))
            .toList(),
      ),
    );

    if (elegido != null && mounted) {
      _abrirHilo(elegido.id, elegido.nombreCompleto);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final noLeidos = _conversaciones.fold<int>(0, (s, c) => s + c.sinLeer);

    return Scaffold(
      backgroundColor: colores.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profesor'),
        ),
        title: const Text('Mensajes'),
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
                        icono: Icons.chat_bubble_rounded,
                        titulo: '$noLeidos mensajes sin leer',
                        subtitulo: '${_conversaciones.length} conversaciones activas',
                      ),
                      const SizedBox(height: 24),
                      Text('Bandeja de entrada',
                          style: textos.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (_conversaciones.isEmpty)
                        const TarjetaVacia(
                          icono: Icons.forum_outlined,
                          mensaje: 'Aún no tienes conversaciones.',
                        )
                      else
                        ..._conversaciones.map(
                          (c) => TarjetaListTile(
                            colorFondo:
                                c.sinLeer > 0 ? colores.primaryContainer.withOpacity(0.35) : null,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: colores.primaryContainer,
                                child: Text(c.nombre.isNotEmpty ? c.nombre[0] : '?',
                                    style: TextStyle(
                                        color: colores.onPrimaryContainer, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(c.nombre,
                                  style: TextStyle(
                                      fontWeight: c.sinLeer > 0 ? FontWeight.bold : FontWeight.w500)),
                              subtitle: Text(c.ultimoMensaje ?? '',
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              trailing: c.sinLeer > 0
                                  ? Container(
                                      width: 9,
                                      height: 9,
                                      decoration:
                                          BoxDecoration(color: colores.primary, shape: BoxShape.circle),
                                    )
                                  : null,
                              onTap: () => _abrirHilo(c.usuarioId, c.nombre),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoMensaje,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Nuevo mensaje'),
      ),
    );
  }
}

class _HiloScreen extends StatefulWidget {
  const _HiloScreen({required this.servicio, required this.otroId, required this.nombre});
  final ProfesorServicio servicio;
  final int otroId;
  final String nombre;

  @override
  State<_HiloScreen> createState() => _HiloScreenState();
}

class _HiloScreenState extends State<_HiloScreen> {
  final _mensajeCtrl = TextEditingController();
  bool _cargando = true;
  bool _enviando = false;
  List<Mensaje> _mensajes = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _mensajeCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final mensajes = await widget.servicio.hilo(widget.otroId);
      if (mounted) setState(() => _mensajes = mensajes);
    } on ErrorApi catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _enviar() async {
    final texto = _mensajeCtrl.text.trim();
    if (texto.isEmpty) return;
    setState(() => _enviando = true);
    try {
      await widget.servicio.enviarMensaje(destinatarioId: widget.otroId, cuerpo: texto);
      _mensajeCtrl.clear();
      await _cargar();
    } on ErrorApi catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.nombre)),
      body: Column(
        children: [
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _mensajes.isEmpty
                    ? const Center(child: Text('Aún no hay mensajes. Escribe el primero.'))
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: _mensajes.length,
                        itemBuilder: (_, i) {
                          final m = _mensajes[_mensajes.length - 1 - i];
                          return Align(
                            alignment: m.esMio ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: m.esMio ? colores.primary : colores.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                m.cuerpo,
                                style: TextStyle(color: m.esMio ? colores.onPrimary : null),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mensajeCtrl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _enviando ? null : _enviar,
                    icon: _enviando
                        ? const SizedBox(
                            height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}