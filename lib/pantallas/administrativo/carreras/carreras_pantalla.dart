import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../app/tema.dart';
import '../../../modelos/carrera.dart';
import '../../../proveedores/carreras_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Listado de carreras con búsqueda y gestión.
class CarrerasPantalla extends StatefulWidget {
  const CarrerasPantalla({super.key});

  @override
  State<CarrerasPantalla> createState() => _CarrerasPantallaState();
}

class _CarrerasPantallaState extends State<CarrerasPantalla> {
  final _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarrerasProveedor>().cargar();
    });
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<CarrerasProveedor>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carreras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Nueva carrera',
            onPressed: () => context.push(Rutas.nuevaCarrera),
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
                          proveedor.filtrar('');
                        },
                      )
                    : null,
              ),
              onChanged: (texto) => proveedor.filtrar(texto),
            ),
          ),
          // Lista
          Expanded(
            child: VistaEstado(
              cargando: proveedor.cargando && proveedor.carreras.isEmpty,
              error: proveedor.carreras.isEmpty ? proveedor.error : null,
              vacio: !proveedor.cargando && proveedor.carreras.isEmpty,
              alReintentar: proveedor.cargar,
              vistaVacia: const _ListaVacia(mensaje: 'No hay carreras registradas'),
              skeleton: const CargandoSkeleton(lineas: 5, altura: 80),
              contenido: (context) => RefreshIndicator(
                onRefresh: () => proveedor.cargar(silencioso: true),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: proveedor.carreras.length,
                  itemBuilder: (_, i) {
                    final carrera = proveedor.carreras[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TarjetaCarrera(carrera: carrera),
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

class _TarjetaCarrera extends StatelessWidget {
  const _TarjetaCarrera({required this.carrera});

  final Carrera carrera;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(
          Rutas.detalleCarrera.replaceAll(':id', carrera.id.toString()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icono representativo
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colores.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: colores.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carrera.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textos.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Código: ${carrera.codigo}  •  ${carrera.duracionPeriodos} periodos',
                      style: context.textos.bodySmall?.copyWith(
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                    if (carrera.descripcion != null &&
                        carrera.descripcion!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        carrera.descripcion!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

class _ListaVacia extends StatelessWidget {
  const _ListaVacia({required this.mensaje});
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Icon(Icons.school_rounded, size: 64, color: context.colores.outline),
        const SizedBox(height: 16),
        Text(mensaje,
            textAlign: TextAlign.center, style: context.textos.titleMedium),
      ],
    );
  }
}