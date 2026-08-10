import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/tema.dart';
import '../../../modelos/aula.dart';
import '../../../nucleo/formato.dart';
import '../../../proveedores/tareas_proveedor.dart';
import '../../../servicios/archivo_servicio.dart';
import '../../../widgets/comunes.dart';
import 'tareas_pantalla.dart';

/// Hoja de detalle de una tarea, con el enunciado, el estado de la entrega y
/// las acciones para entregarla (subiendo un archivo o pegando un enlace).
///
/// Recibe el id y no la tarea porque tras entregar el proveedor recarga la lista:
/// así el contenido se mantiene sincronizado sin cerrar la hoja.
class DetalleTarea extends StatelessWidget {
  const DetalleTarea({super.key, required this.tareaId});

  final int tareaId;

  Future<void> _entregarArchivo(BuildContext context) async {
    final proveedor = context.read<TareasProveedor>();

    final resultado = await FilePicker.platform.pickFiles(withData: true);
    if (resultado == null || resultado.files.isEmpty) return;

    final archivo = resultado.files.first;
    if (archivo.bytes == null) return;
    if (!context.mounted) return;

    final error = await proveedor.entregarArchivo(
      tareaId,
      archivo.bytes!,
      archivo.name,
    );
    if (!context.mounted) return;

    mostrarAviso(
      context,
      error ?? 'Entrega enviada correctamente.',
      esError: error != null,
    );
  }

  Future<void> _entregarEnlace(BuildContext context) async {
    final controlador = TextEditingController();

    final enlace = await showDialog<String>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Entregar con un enlace'),
        content: TextField(
          controller: controlador,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Enlace del documento',
            hintText: 'https://drive.google.com/...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogo, controlador.text.trim()),
            child: const Text('Entregar'),
          ),
        ],
      ),
    );

    controlador.dispose();
    if (enlace == null || enlace.isEmpty || !context.mounted) return;

    final error = await context.read<TareasProveedor>().entregarEnlace(
      tareaId,
      enlace,
    );
    if (!context.mounted) return;

    mostrarAviso(
      context,
      error ?? 'Entrega enviada correctamente.',
      esError: error != null,
    );
  }

  Future<void> _abrir(BuildContext context, String url) async {
    final uri = Uri.tryParse(ArchivoServicio.urlAbsoluta(url));
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        mostrarAviso(context, 'No se pudo abrir el archivo.', esError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<TareasProveedor>();
    final coincidencias = proveedor.tareas.where((t) => t.id == tareaId);
    final tarea = coincidencias.isEmpty ? null : coincidencias.first;

    if (tarea == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final procesando = proveedor.tareaEnProceso == tareaId;
    final (tono, icono) = TarjetaTarea.apariencia(tarea.estado);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.94,
      minChildSize: 0.45,
      builder: (context, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colores.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        tarea.titulo,
                        style: context.textos.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ChipEstado(
                      texto: tarea.estado.etiqueta,
                      tono: tono,
                      icono: icono,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${tarea.materia} · ${tarea.codigoMateria}',
                  style: context.textos.bodyMedium?.copyWith(
                    color: context.colores.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                _Bloque(
                  icono: Icons.event_rounded,
                  titulo: 'Fecha límite',
                  contenido: Formato.fechaHora(tarea.fechaEntrega),
                  destacado: Formato.tiempoRestante(tarea.fechaEntrega),
                ),

                if (tarea.descripcion != null &&
                    tarea.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Enunciado',
                    style: context.textos.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(tarea.descripcion!, style: context.textos.bodyMedium),
                ],

                if (tarea.archivoAdjuntoUrl != null) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _abrir(context, tarea.archivoAdjuntoUrl!),
                    icon: const Icon(Icons.attach_file_rounded, size: 18),
                    label: const Text('Ver material de la tarea'),
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                Text(
                  'Tu entrega',
                  style: context.textos.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                if (tarea.entregada)
                  _ResumenEntrega(
                    tarea: tarea,
                    alAbrir: (url) => _abrir(context, url),
                  )
                else
                  Text(
                    'Todavía no has entregado esta tarea.',
                    style: context.textos.bodyMedium?.copyWith(
                      color: context.colores.onSurfaceVariant,
                    ),
                  ),

                const SizedBox(height: 20),

                // Se permite reenviar mientras no esté calificada: el backend
                // sustituye la entrega anterior por la nueva.
                if (tarea.estado != EstadoTarea.calificada) ...[
                  FilledButton.icon(
                    onPressed: procesando
                        ? null
                        : () => _entregarArchivo(context),
                    icon: procesando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file_rounded),
                    label: Text(
                      tarea.entregada ? 'Reemplazar archivo' : 'Subir archivo',
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: procesando
                        ? null
                        : () => _entregarEnlace(context),
                    icon: const Icon(Icons.link_rounded, size: 18),
                    label: const Text('Entregar con un enlace'),
                  ),
                  if (tarea.estado == EstadoTarea.vencida) ...[
                    const SizedBox(height: 12),
                    Text(
                      'La fecha límite ya pasó. Aún puedes entregar, pero quedará '
                      'registrada como entrega tardía.',
                      style: context.textos.labelSmall?.copyWith(
                        color: context.estados.advertencia,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenEntrega extends StatelessWidget {
  const _ResumenEntrega({required this.tarea, required this.alAbrir});

  final Tarea tarea;
  final void Function(String) alAbrir;

  @override
  Widget build(BuildContext context) {
    final estados = context.estados;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colores.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: estados.exito,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Entregada el ${Formato.fechaHora(tarea.fechaEnvio)}',
                      style: context.textos.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (tarea.entregaTardia) ...[
                const SizedBox(height: 6),
                ChipEstado(
                  texto: 'Entrega tardía',
                  tono: TonoEstado.advertencia,
                  icono: Icons.schedule_rounded,
                ),
              ],
              if (tarea.archivoEntregadoUrl != null) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => alAbrir(tarea.archivoEntregadoUrl!),
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('Ver lo que entregaste'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ],
            ],
          ),
        ),
        if (tarea.calificacion != null) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Calificación',
                style: context.textos.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                Formato.nota(tarea.calificacion),
                style: context.textos.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tarea.calificacion! >= 70
                      ? estados.exito
                      : estados.error,
                ),
              ),
            ],
          ),
        ],
        if (tarea.comentariosProfesor != null &&
            tarea.comentariosProfesor!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: estados.infoSuave,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comentario del profesor',
                  style: context.textos.labelMedium?.copyWith(
                    color: estados.info,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tarea.comentariosProfesor!,
                  style: context.textos.bodySmall?.copyWith(
                    color: estados.info,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Bloque extends StatelessWidget {
  const _Bloque({
    required this.icono,
    required this.titulo,
    required this.contenido,
    this.destacado,
  });

  final IconData icono;
  final String titulo;
  final String contenido;
  final String? destacado;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.colores.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icono,
            size: 20,
            color: context.colores.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: context.textos.labelSmall?.copyWith(
                  color: context.colores.onSurfaceVariant,
                ),
              ),
              Text(
                contenido,
                style: context.textos.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (destacado != null)
          Text(
            destacado!,
            style: context.textos.labelSmall?.copyWith(
              color: context.colores.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
