import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../app/tema.dart';
import '../../../modelos/aula.dart';
import '../../../nucleo/formato.dart';
import '../../../proveedores/mensajes_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Bandeja de conversaciones. Los destinatarios posibles son los profesores de
/// las secciones en las que el estudiante está inscrito.
class MensajesPantalla extends StatefulWidget {
  const MensajesPantalla({super.key});

  @override
  State<MensajesPantalla> createState() => _MensajesPantallaState();
}

class _MensajesPantallaState extends State<MensajesPantalla> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MensajesProveedor>().cargar();
    });
  }

  Future<void> _nuevoMensaje() async {
    final proveedor = context.read<MensajesProveedor>();

    if (proveedor.contactos.isEmpty) {
      mostrarAviso(
        context,
        'Aún no tienes profesores asignados a quién escribir.',
        esError: true,
      );
      return;
    }

    final destinatarioId = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      builder: (hoja) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Nuevo mensaje',
                    style: context.textos.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Elige a quién quieres escribir',
                  style: context.textos.bodySmall?.copyWith(
                    color: context.colores.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final contacto in proveedor.contactos)
                    ListTile(
                      leading: AvatarIniciales(nombre: contacto.nombreCompleto),
                      title: Text(contacto.nombreCompleto),
                      subtitle: Text(contacto.rol),
                      onTap: () => Navigator.pop(hoja, contacto.id),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (destinatarioId != null && mounted) {
      context.push(Rutas.hilo(destinatarioId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<MensajesProveedor>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      floatingActionButton: FloatingActionButton(
        onPressed: _nuevoMensaje,
        tooltip: 'Nuevo mensaje',
        child: const Icon(Icons.edit_rounded),
      ),
      body: VistaEstado(
        cargando: proveedor.cargando && !proveedor.cargadoAlgunaVez,
        error: proveedor.error,
        vacio: proveedor.vacio,
        alReintentar: proveedor.cargar,
        skeleton: const CargandoSkeleton(lineas: 6, altura: 68),
        vistaVacia: EstadoVacio(
          icono: Icons.forum_outlined,
          titulo: 'Sin conversaciones',
          mensaje:
              'Escribe a tus profesores para resolver dudas sobre las clases, '
              'tareas o calificaciones.',
          textoAccion: 'Escribir mensaje',
          accion: _nuevoMensaje,
        ),
        contenido: (context) => RefreshIndicator(
          onRefresh: () => proveedor.cargar(silencioso: true),
          child: ContenidoCentrado(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: proveedor.conversaciones.length,
              separatorBuilder: (_, _) => const Divider(indent: 76, height: 1),
              itemBuilder: (context, indice) => EntradaAnimada(
                indice: indice,
                child: _FilaConversacion(
                  conversacion: proveedor.conversaciones[indice],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilaConversacion extends StatelessWidget {
  const _FilaConversacion({required this.conversacion});

  final Conversacion conversacion;

  @override
  Widget build(BuildContext context) {
    final sinLeer = conversacion.sinLeer > 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: AvatarIniciales(nombre: conversacion.nombre, radio: 24),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversacion.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textos.titleSmall?.copyWith(
                fontWeight: sinLeer ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            Formato.relativo(conversacion.fechaUltimoMensaje),
            style: context.textos.labelSmall?.copyWith(
              color: sinLeer
                  ? context.colores.primary
                  : context.colores.onSurfaceVariant,
              fontWeight: sinLeer ? FontWeight.w700 : null,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                conversacion.ultimoMensaje ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textos.bodySmall?.copyWith(
                  color: sinLeer
                      ? context.colores.onSurface
                      : context.colores.onSurfaceVariant,
                  fontWeight: sinLeer ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (sinLeer) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colores.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${conversacion.sinLeer}',
                  style: context.textos.labelSmall?.copyWith(
                    color: context.colores.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      onTap: () => context.push(Rutas.hilo(conversacion.usuarioId)),
    );
  }
}
