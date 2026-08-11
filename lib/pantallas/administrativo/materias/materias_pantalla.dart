import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../app/tema.dart';
import '../../../modelos/materia.dart';
import '../../../proveedores/materias_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Listado de materias con filtro por carrera.
class MateriasPantalla extends StatefulWidget {
  const MateriasPantalla({super.key});

  @override
  State<MateriasPantalla> createState() => _MateriasPantallaState();
}

class _MateriasPantallaState extends State<MateriasPantalla> {
  final _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final proveedor = context.read<MateriasProveedor>();
      proveedor.cargar();
      proveedor.cargarCarreras(); // para el filtro
    });
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<MateriasProveedor>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Nueva materia',
            onPressed: () => context.push(Rutas.nuevaMateria),
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
                hintText: 'Buscar por nombre o código...',
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
          // Filtro por carrera
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _ChipFiltro(
                  etiqueta: 'Todas las carreras',
                  seleccionado: proveedor.carreraSeleccionada == null,
                  alPulsar: () => proveedor.filtrarPorCarrera(null),
                ),
                const SizedBox(width: 8),
                ...proveedor.carreras.map((carrera) {
                  final seleccionado =
                      proveedor.carreraSeleccionada?.id == carrera.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _ChipFiltro(
                      etiqueta: carrera.nombre,
                      seleccionado: seleccionado,
                      alPulsar: () => proveedor.filtrarPorCarrera(carrera),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Lista
          Expanded(
            child: VistaEstado(
              cargando: proveedor.cargando && proveedor.materias.isEmpty,
              error: proveedor.materias.isEmpty ? proveedor.error : null,
              vacio: !proveedor.cargando && proveedor.materias.isEmpty,
              alReintentar: proveedor.cargar,
              vistaVacia: const _ListaVacia(mensaje: 'No hay materias registradas'),
              skeleton: const CargandoSkeleton(lineas: 5, altura: 80),
              contenido: (context) => RefreshIndicator(
                onRefresh: () => proveedor.cargar(silencioso: true),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: proveedor.materias.length,
                  itemBuilder: (_, i) {
                    final materia = proveedor.materias[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TarjetaMateria(materia: materia),
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

// Reutilizamos el chip de filtro (lo extraigo a un widget compartido si prefieres)
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

class _TarjetaMateria extends StatelessWidget {
  const _TarjetaMateria({required this.materia});

  final Materia materia;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(
          Rutas.detalleMateria.replaceAll(':id', materia.id.toString()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colores.tertiaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.menu_book_rounded,
                  color: colores.onTertiaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      materia.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textos.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Insignia(
                          texto: materia.codigo,
                          color: colores.primary,
                        ),
                        const SizedBox(width: 6),
                        _Insignia(
                          texto: '${materia.creditos} créditos',
                          color: colores.secondary,
                        ),
                      ],
                    ),
                    if (materia.carreraNombre != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        materia.carreraNombre!,
                        style: context.textos.bodySmall?.copyWith(
                          color: colores.onSurfaceVariant,
                        ),
                      ),
                    ],
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

class _Insignia extends StatelessWidget {
  const _Insignia({required this.texto, required this.color});
  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        texto,
        style: context.textos.labelSmall?.copyWith(color: color),
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
        Icon(Icons.menu_book_rounded, size: 64, color: context.colores.outline),
        const SizedBox(height: 16),
        Text(mensaje,
            textAlign: TextAlign.center, style: context.textos.titleMedium),
      ],
    );
  }
}