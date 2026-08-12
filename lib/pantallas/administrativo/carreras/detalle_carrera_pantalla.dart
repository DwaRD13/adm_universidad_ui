// lib/pantallas/admin/carreras/detalle_carrera_pantalla.dart
import 'package:adm_universidad_ui/widgets/error_vista.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/router.dart';
import '../../../app/tema.dart';
import '../../../modelos/carrera.dart';
import '../../../proveedores/carreras_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

class DetalleCarreraPantalla extends StatefulWidget {
  final int id;
  const DetalleCarreraPantalla({super.key, required this.id});

  @override
  State<DetalleCarreraPantalla> createState() => _DetalleCarreraPantallaState();
}

class _DetalleCarreraPantallaState extends State<DetalleCarreraPantalla> {
  late Future<Carrera?> _carga;

  @override
  void initState() {
    super.initState();
    _carga = context.read<CarrerasProveedor>().obtenerCarrera(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Carrera'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Editar carrera',
            onPressed: () async {
              // Navega a editar y recarga al volver
              await context.push(Rutas.editarCarrera(widget.id));
              setState(() {
                _carga = context.read<CarrerasProveedor>().obtenerCarrera(
                  widget.id,
                );
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Carrera?>(
        future: _carga,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CargandoSkeleton(lineas: 6, altura: 70);
          }
          if (snapshot.hasError || snapshot.data == null) {
            return ErrorVista(
              mensaje: 'Carrera no encontrada',
              alReintentar: () {
                setState(() {
                  _carga = context.read<CarrerasProveedor>().obtenerCarrera(
                    widget.id,
                  );
                });
              },
            );
          }
          return _DetalleCarrera(carrera: snapshot.data!);
        },
      ),
    );
  }
}

class _DetalleCarrera extends StatelessWidget {
  final Carrera carrera;
  const _DetalleCarrera({required this.carrera});

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: colores.primaryContainer,
                child: Icon(
                  Icons.school_rounded,
                  size: 32,
                  color: colores.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carrera.nombre,
                      style: context.textos.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${carrera.id}',
                      style: context.textos.labelLarge?.copyWith(
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Tarjeta principal
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FilaDetalle(
                    icono: Icons.tag_rounded,
                    etiqueta: 'Código',
                    valor: carrera.codigo,
                  ),
                  const Divider(height: 24),
                  _FilaDetalle(
                    icono: Icons.timelapse_rounded,
                    etiqueta: 'Duración',
                    valor: '${carrera.duracionPeriodos} periodos',
                  ),
                  const Divider(height: 24),
                  _FilaDetalle(
                    icono: Icons.description_rounded,
                    etiqueta: 'Descripción',
                    valor: carrera.descripcion?.isNotEmpty == true
                        ? carrera.descripcion!
                        : 'Sin descripción',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Editar'),
                  onPressed: () =>
                      context.push(Rutas.editarCarrera(carrera.id!)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.list_rounded),
                  label: const Text('Ver secciones'),
                  onPressed: () {
                    // Navegación opcional si quieres enlazar secciones de esta carrera
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Eliminar carrera'),
              style: TextButton.styleFrom(
                foregroundColor: context.colores.error,
              ),
              onPressed: () => _confirmarEliminacion(context),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar carrera'),
        content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final ok = await context
                  .read<CarrerasProveedor>()
                  .eliminarCarrera(carrera.id!);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (ok) {
                context.pop(); // vuelve a la lista
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _FilaDetalle extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _FilaDetalle({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icono, size: 20, color: context.colores.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: context.textos.labelMedium?.copyWith(
                  color: context.colores.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(valor, style: context.textos.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
