import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../app/tema.dart';
import '../../../modelos/inscripcion.dart';
import '../../../proveedores/inscripciones_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Listado de inscripciones con filtros por estudiante, sección y estado.
class InscripcionesPantalla extends StatefulWidget {
  const InscripcionesPantalla({super.key});

  @override
  State<InscripcionesPantalla> createState() => _InscripcionesPantallaState();
}

class _InscripcionesPantallaState extends State<InscripcionesPantalla> {
  final _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final proveedor = context.read<InscripcionesProveedor>();
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
    final proveedor = context.watch<InscripcionesProveedor>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscripciones'),
        // No se añade botón de nuevo porque la inscripción la hace el admin
        // desde la sección de inscripciones de estudiantes.
      ),
      body: Column(
        children: [
          // Búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _busquedaCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por estudiante o código de sección...',
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
          // Filtros rápidos
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _ChipFiltro(
                  etiqueta: 'Todos los estados',
                  seleccionado: proveedor.estadoSeleccionado == null,
                  alPulsar: () => proveedor.filtrarPorEstado(null),
                ),
                const SizedBox(width: 8),
                ...['Inscrito', 'Retirado', 'Aprobado', 'Reprobado'].map((e) {
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
                const SizedBox(width: 16),
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
              ],
            ),
          ),
          // Lista
          Expanded(
            child: VistaEstado(
              cargando: proveedor.cargando && proveedor.inscripciones.isEmpty,
              error: proveedor.inscripciones.isEmpty ? proveedor.error : null,
              vacio: !proveedor.cargando && proveedor.inscripciones.isEmpty,
              alReintentar: proveedor.cargar,
              vistaVacia:
                  const _ListaVacia(mensaje: 'No hay inscripciones registradas'),
              skeleton: const CargandoSkeleton(lineas: 5, altura: 80),
              contenido: (context) => RefreshIndicator(
                onRefresh: () => proveedor.cargar(silencioso: true),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: proveedor.inscripciones.length,
                  itemBuilder: (_, i) {
                    final inscripcion = proveedor.inscripciones[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TarjetaInscripcion(inscripcion: inscripcion),
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

// Reutiliza _ChipFiltro de las pantallas anteriores.

class _TarjetaInscripcion extends StatelessWidget {
  const _TarjetaInscripcion({required this.inscripcion});

  final Inscripcion inscripcion;

  Color _colorEstado(BuildContext context) {
    switch (inscripcion.estado) {
      case 'Inscrito':
        return context.estados.info;
      case 'Aprobado':
        return context.estados.exito;
      case 'Retirado':
        return context.estados.advertencia;
      case 'Reprobado':
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
      child: InkWell(
        onTap: () => context.push(
          Rutas.detalleInscripcion.replaceAll(':id', inscripcion.id.toString()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      inscripcion.estudianteNombre,
                      style: context.textos.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ChipEstado(
                    texto: inscripcion.estado,
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
              const SizedBox(height: 6),
              Text(
                '${inscripcion.materiaNombre} (${inscripcion.codigoMateria})',
                style: context.textos.bodyMedium?.copyWith(
                  color: colores.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sección: ${inscripcion.seccionId} • ${inscripcion.periodo}',
                style: context.textos.bodySmall?.copyWith(
                  color: colores.onSurfaceVariant,
                ),
              ),
              if (inscripcion.notaFinal != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Calificación: ${inscripcion.notaFinal}',
                  style: context.textos.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colores.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
        Icon(Icons.playlist_add_check_rounded,
            size: 64, color: context.colores.outline),
        const SizedBox(height: 16),
        Text(mensaje,
            textAlign: TextAlign.center, style: context.textos.titleMedium),
      ],
    );
  }
}