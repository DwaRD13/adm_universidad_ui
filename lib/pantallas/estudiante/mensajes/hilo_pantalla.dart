import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/tema.dart';
import '../../../modelos/aula.dart';
import '../../../nucleo/formato.dart';
import '../../../proveedores/mensajes_proveedor.dart';
import '../../../widgets/comunes.dart';

/// Conversación con un profesor, en formato de chat.
class HiloPantalla extends StatefulWidget {
  const HiloPantalla({super.key, required this.usuarioId});

  final int usuarioId;

  @override
  State<HiloPantalla> createState() => _HiloPantallaState();
}

class _HiloPantallaState extends State<HiloPantalla> {
  final _mensaje = TextEditingController();
  final _scroll = ScrollController();

  /// Se guarda la referencia porque en dispose() ya no es seguro leer el
  /// proveedor desde el contexto.
  MensajesProveedor? _proveedor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<MensajesProveedor>().abrirHilo(widget.usuarioId);
      _irAlFinal();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _proveedor = context.read<MensajesProveedor>();
  }

  @override
  void dispose() {
    _mensaje.dispose();
    _scroll.dispose();
    // El proveedor es compartido: se limpia el hilo para no dejarlo abierto.
    _proveedor?.cerrarHilo();
    super.dispose();
  }

  void _irAlFinal() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _enviar() async {
    final texto = _mensaje.text.trim();
    if (texto.isEmpty) return;

    final proveedor = context.read<MensajesProveedor>();
    _mensaje.clear();

    final error = await proveedor.enviar(widget.usuarioId, texto);
    if (!mounted) return;

    if (error != null) {
      mostrarAviso(context, error, esError: true);
      // Se devuelve el texto al campo para que no se pierda lo escrito.
      _mensaje.text = texto;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _irAlFinal());
    }
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<MensajesProveedor>();
    final nombre = proveedor.nombreDe(widget.usuarioId);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            AvatarIniciales(nombre: nombre, radio: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textos.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: proveedor.cargandoHilo
                ? const Center(child: CircularProgressIndicator())
                : proveedor.hilo.isEmpty
                ? _HiloVacio(nombre: nombre)
                : ContenidoCentrado(
                    child: ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: proveedor.hilo.length,
                      itemBuilder: (context, indice) {
                        final mensaje = proveedor.hilo[indice];
                        final anterior = indice == 0
                            ? null
                            : proveedor.hilo[indice - 1];
                        return _Burbuja(
                          mensaje: mensaje,
                          mostrarFecha: _cambiaElDia(anterior, mensaje),
                        );
                      },
                    ),
                  ),
          ),
          ContenidoCentrado(
            child: _Redactor(
              controlador: _mensaje,
              enviando: proveedor.enviando,
              alEnviar: _enviar,
            ),
          ),
        ],
      ),
    );
  }

  /// Se muestra el separador de fecha cuando cambia el día respecto al anterior.
  bool _cambiaElDia(Mensaje? anterior, Mensaje actual) {
    if (actual.fechaEnvio == null) return false;
    if (anterior?.fechaEnvio == null) return true;
    final a = anterior!.fechaEnvio!;
    final b = actual.fechaEnvio!;
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }
}

class _Burbuja extends StatelessWidget {
  const _Burbuja({required this.mensaje, required this.mostrarFecha});

  final Mensaje mensaje;
  final bool mostrarFecha;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final propio = mensaje.propio;

    return Column(
      children: [
        if (mostrarFecha)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: colores.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                Formato.fechaLarga(mensaje.fechaEnvio),
                style: context.textos.labelSmall?.copyWith(
                  color: colores.onSurfaceVariant,
                ),
              ),
            ),
          ),
        Align(
          alignment: propio ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.76,
            ),
            decoration: BoxDecoration(
              color: propio ? colores.primary : colores.surfaceContainerHigh,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(propio ? 16 : 4),
                bottomRight: Radius.circular(propio ? 4 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: propio
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (mensaje.asunto != null && mensaje.asunto!.isNotEmpty) ...[
                  Text(
                    mensaje.asunto!,
                    style: context.textos.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: propio ? colores.onPrimary : colores.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  mensaje.cuerpo,
                  style: context.textos.bodyMedium?.copyWith(
                    color: propio ? colores.onPrimary : colores.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formato.hora(mensaje.fechaEnvio),
                  style: context.textos.labelSmall?.copyWith(
                    fontSize: 10,
                    color: propio
                        ? colores.onPrimary.withValues(alpha: 0.7)
                        : colores.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Redactor extends StatelessWidget {
  const _Redactor({
    required this.controlador,
    required this.enviando,
    required this.alEnviar,
  });

  final TextEditingController controlador;
  final bool enviando;
  final VoidCallback alEnviar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: context.colores.surfaceContainer,
          border: Border(
            top: BorderSide(
              color: context.colores.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controlador,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu mensaje…',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: enviando ? null : alEnviar,
              icon: enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, size: 20),
              tooltip: 'Enviar',
            ),
          ],
        ),
      ),
    );
  }
}

class _HiloVacio extends StatelessWidget {
  const _HiloVacio({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarIniciales(nombre: nombre, radio: 36),
            const SizedBox(height: 16),
            Text(
              'Inicia la conversación con $nombre',
              textAlign: TextAlign.center,
              style: context.textos.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Escribe tu mensaje abajo para enviar la primera consulta.',
              textAlign: TextAlign.center,
              style: context.textos.bodySmall?.copyWith(
                color: context.colores.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
