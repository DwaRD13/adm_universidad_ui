import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/tema.dart';
import '../../../modelos/aula.dart';
import '../../../nucleo/formato.dart';
import '../../../proveedores/tareas_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';
import 'detalle_tarea.dart';

/// Tareas de las secciones del estudiante, separadas por estado de entrega.
class TareasPantalla extends StatefulWidget {
  const TareasPantalla({super.key});

  @override
  State<TareasPantalla> createState() => _TareasPantallaState();
}

class _TareasPantallaState extends State<TareasPantalla> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TareasProveedor>().cargar();
    });
  }

  void _abrirDetalle(Tarea tarea) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DetalleTarea(tareaId: tarea.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<TareasProveedor>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tareas'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pendientes (${proveedor.pendientes.length})'),
              Tab(text: 'Entregadas (${proveedor.entregadas.length})'),
              Tab(text: 'Vencidas (${proveedor.vencidas.length})'),
            ],
          ),
        ),
        body: VistaEstado(
          cargando: proveedor.cargando && !proveedor.cargadoAlgunaVez,
          error: proveedor.error,
          vacio: proveedor.vacio,
          alReintentar: proveedor.cargar,
          skeleton: const CargandoSkeleton(lineas: 4, altura: 118),
          vistaVacia: const EstadoVacio(
            icono: Icons.assignment_outlined,
            titulo: 'No hay tareas asignadas',
            mensaje:
                'Cuando tus profesores publiquen tareas en tus secciones, '
                'aparecerán aquí ordenadas por fecha de entrega.',
          ),
          contenido: (context) => TabBarView(
            children: [
              _ListaTareas(
                tareas: proveedor.pendientes,
                alRefrescar: () => proveedor.cargar(silencioso: true),
                alAbrir: _abrirDetalle,
                iconoVacio: Icons.task_alt_rounded,
                tituloVacio: 'Nada pendiente',
                mensajeVacio: 'No tienes tareas por entregar. Vas al día.',
              ),
              _ListaTareas(
                tareas: proveedor.entregadas,
                alRefrescar: () => proveedor.cargar(silencioso: true),
                alAbrir: _abrirDetalle,
                iconoVacio: Icons.upload_file_rounded,
                tituloVacio: 'Sin entregas todavía',
                mensajeVacio:
                    'Cuando entregues una tarea aparecerá en esta pestaña.',
              ),
              _ListaTareas(
                tareas: proveedor.vencidas,
                alRefrescar: () => proveedor.cargar(silencioso: true),
                alAbrir: _abrirDetalle,
                iconoVacio: Icons.verified_rounded,
                tituloVacio: 'Ninguna tarea vencida',
                mensajeVacio: 'No dejaste pasar ninguna fecha de entrega.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListaTareas extends StatelessWidget {
  const _ListaTareas({
    required this.tareas,
    required this.alRefrescar,
    required this.alAbrir,
    required this.iconoVacio,
    required this.tituloVacio,
    required this.mensajeVacio,
  });

  final List<Tarea> tareas;
  final Future<void> Function() alRefrescar;
  final void Function(Tarea) alAbrir;
  final IconData iconoVacio;
  final String tituloVacio;
  final String mensajeVacio;

  @override
  Widget build(BuildContext context) {
    if (tareas.isEmpty) {
      return EstadoVacio(
        icono: iconoVacio,
        titulo: tituloVacio,
        mensaje: mensajeVacio,
      );
    }

    return RefreshIndicator(
      onRefresh: alRefrescar,
      child: ContenidoCentrado(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: tareas.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, indice) => EntradaAnimada(
            indice: indice,
            child: TarjetaTarea(
              tarea: tareas[indice],
              alPulsar: () => alAbrir(tareas[indice]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de tarea reutilizada en la lista y en el detalle.
class TarjetaTarea extends StatelessWidget {
  const TarjetaTarea({super.key, required this.tarea, this.alPulsar});

  final Tarea tarea;
  final VoidCallback? alPulsar;

  static (TonoEstado, IconData) apariencia(EstadoTarea estado) =>
      switch (estado) {
        EstadoTarea.calificada => (
          TonoEstado.exito,
          Icons.workspace_premium_rounded,
        ),
        EstadoTarea.entregada => (
          TonoEstado.info,
          Icons.check_circle_outline_rounded,
        ),
        EstadoTarea.vencida => (TonoEstado.error, Icons.error_outline_rounded),
        EstadoTarea.pendiente => (
          TonoEstado.advertencia,
          Icons.pending_outlined,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final (tono, icono) = apariencia(tarea.estado);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alPulsar,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      tarea.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textos.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                style: context.textos.bodySmall?.copyWith(
                  color: context.colores.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 15,
                    color: context.colores.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      Formato.fechaHora(tarea.fechaEntrega),
                      style: context.textos.bodySmall?.copyWith(
                        color: context.colores.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (tarea.calificacion != null)
                    ChipEstado(
                      texto: Formato.nota(tarea.calificacion),
                      tono: tarea.calificacion! >= 70
                          ? TonoEstado.exito
                          : TonoEstado.error,
                      icono: Icons.star_rounded,
                    )
                  else if (!tarea.entregada)
                    Text(
                      Formato.tiempoRestante(tarea.fechaEntrega),
                      style: context.textos.labelSmall?.copyWith(
                        color: tarea.estado == EstadoTarea.vencida
                            ? context.estados.error
                            : context.estados.advertencia,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
