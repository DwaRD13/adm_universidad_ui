import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../app/tema.dart';
import '../../../modelos/seccion.dart';
import '../../../proveedores/secciones_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Listado de secciones con filtros por periodo, materia y estado.
class SeccionesPantalla extends StatefulWidget {
  const SeccionesPantalla({super.key});

  @override
  State<SeccionesPantalla> createState() => _SeccionesPantallaState();
}

class _SeccionesPantallaState extends State<SeccionesPantalla> {
  final _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final proveedor = context.read<SeccionesProveedor>();
      proveedor.cargar();
      proveedor.cargarCatalogos();
    });
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<SeccionesProveedor>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Nueva sección',
            onPressed: () => context.push(Rutas.nuevaSeccion),
          ),
        ],
      ),
      body: Column(
        children: [
          // Búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _busquedaCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por materia, profesor o aula...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _busquedaCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _busquedaCtrl.clear();
                          proveedor.filtrarTexto('');
                        },
                      )
                    : null,
              ),
              onChanged: (t) => proveedor.filtrarTexto(t),
            ),
          ),
          // Filtros horizontales
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                // Periodo
                _ChipFiltro(
                  etiqueta: 'Todos los periodos',
                  seleccionado: proveedor.periodoSeleccionado == null,
                  alPulsar: () => proveedor.filtrarPorPeriodo(null),
                ),
                const SizedBox(width: 8),
                ...proveedor.periodos.map((p) {
                  final sel = proveedor.periodoSeleccionado == p;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _ChipFiltro(
                      etiqueta: p,
                      seleccionado: sel,
                      alPulsar: () => proveedor.filtrarPorPeriodo(p),
                    ),
                  );
                }),
                const SizedBox(width: 16),
                // Estado
                _ChipFiltro(
                  etiqueta: 'Todos los estados',
                  seleccionado: proveedor.estadoSeleccionado == null,
                  alPulsar: () => proveedor.filtrarPorEstado(null),
                ),
                const SizedBox(width: 8),
                ...['Abierta', 'En Curso', 'Cerrada', 'Finalizada'].map((e) {
                  final sel = proveedor.estadoSeleccionado == e;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _ChipFiltro(
                      etiqueta: e,
                      seleccionado: sel,
                      alPulsar: () => proveedor.filtrarPorEstado(e),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Lista
          Expanded(
            child: VistaEstado(
              cargando: proveedor.cargando && proveedor.secciones.isEmpty,
              error: proveedor.secciones.isEmpty ? proveedor.error : null,
              vacio: !proveedor.cargando && proveedor.secciones.isEmpty,
              alReintentar: proveedor.cargar,
              vistaVacia: const _ListaVacia(mensaje: 'No hay secciones'),
              skeleton: const CargandoSkeleton(lineas: 5, altura: 90),
              contenido: (context) => RefreshIndicator(
                onRefresh: () => proveedor.cargar(silencioso: true),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: proveedor.secciones.length,
                  itemBuilder: (_, i) {
                    final seccion = proveedor.secciones[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TarjetaSeccion(seccion: seccion),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reutiliza el mismo _ChipFiltro de materias (o ponlo en comunes)
class _ChipFiltro extends StatelessWidget {
  const _ChipFiltro({
    required this.etiqueta,
    required this.seleccionado,
    required this.alPulsar,
  });

  final String etiqueta;
  final bool seleccionado;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(etiqueta),
      selected: seleccionado,
      onSelected: (_) => alPulsar(),
      showCheckmark: false,
      selectedColor: context.colores.primaryContainer,
      labelStyle: context.textos.labelMedium?.copyWith(
        color: seleccionado
            ? context.colores.onPrimaryContainer
            : context.colores.onSurfaceVariant,
      ),
    );
  }
}

class _TarjetaSeccion extends StatelessWidget {
  const _TarjetaSeccion({required this.seccion});

  final Seccion seccion;

  Color _colorEstado(BuildContext context) {
    final estadoBackend = seccion.estado?.toUpperCase();

    switch (estadoBackend) {
      case 'ABIERTA':
        return context.estados.info;
      case 'EN CURSO':
        return context.estados.exito;
      case 'CERRADA':
        return context.estados.advertencia;
      case 'FINALIZADA':
        return context.estados.error;
      default:
        return context.colores.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final colorEstado = _colorEstado(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Rutas.detalleSeccion(seccion.id!)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador de color de estado
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: colorEstado,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seccion.materiaNombre ?? '',
                      style: context.textos.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${seccion.profesorNombre} • Periodo ${seccion.periodo}',
                      style: context.textos.bodySmall?.copyWith(
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (seccion.aula != null && seccion.aula!.isNotEmpty)
                          _EtiquetaSecundaria(
                            icono: Icons.meeting_room_rounded,
                            texto: seccion.aula!,
                          ),
                        if (seccion.horarioDescripcion != null &&
                            seccion.horarioDescripcion!.isNotEmpty)
                          _EtiquetaSecundaria(
                            icono: Icons.schedule_rounded,
                            texto: seccion.horarioDescripcion!,
                          ),
                        _EtiquetaSecundaria(
                          icono: Icons.people_rounded,
                          texto:
                              '${seccion.inscritos ?? 0}/${seccion.cupoMaximo}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ChipEstado(
                      texto: seccion.estado != null
                          ? seccion.estado![0].toUpperCase() +
                                seccion.estado!.substring(1).toLowerCase()
                          : '',
                      tono: colorEstado == context.estados.info
                          ? TonoEstado.info
                          : colorEstado == context.estados.exito
                          ? TonoEstado.exito
                          : colorEstado == context.estados.advertencia
                          ? TonoEstado.advertencia
                          : TonoEstado.error,
                      icono: Icons.circle_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _EtiquetaSecundaria extends StatelessWidget {
  const _EtiquetaSecundaria({required this.icono, required this.texto});
  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 14, color: context.colores.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          texto,
          style: context.textos.labelSmall?.copyWith(
            color: context.colores.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ListaVacia extends StatelessWidget {
  const _ListaVacia({required this.mensaje});
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.meeting_room_rounded,
          size: 64,
          color: context.colores.outline,
        ),
        const SizedBox(height: 16),
        Text(
          mensaje,
          textAlign: TextAlign.center,
          style: context.textos.titleMedium,
        ),
      ],
    );
  }
}
