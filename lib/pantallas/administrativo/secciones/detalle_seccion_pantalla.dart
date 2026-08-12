import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/tema.dart';
import '../../../modelos/seccion.dart';
import '../../../proveedores/secciones_proveedor.dart';

class DetalleSeccionPantalla extends StatelessWidget {
  final int id;
  const DetalleSeccionPantalla({super.key, required this.id});

  // Método auxiliar para capitalizar el estado (Ej: "ABIERTA" -> "Abierta")
  String _capitalizar(String? texto) {
    if (texto == null || texto.isEmpty) return 'N/A';
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<SeccionesProveedor>();

    // Buscamos la sección en la lista cargada
    final seccion = proveedor.secciones.firstWhere(
      (s) => s.id == id,
      orElse: () => Seccion(
        id: id,
        materiaNombre: 'Desconocida',
        profesorNombre: 'No asignado',
        materiaId: 0,
        profesorId: 0,
        periodo: '',
        cupoMaximo: 0,
        estado: 'Desconocido',
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Sección')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado visual (Avatar con ícono en lugar de iniciales)
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: context.colores.primaryContainer,
                  child: Icon(
                    Icons.meeting_room_rounded,
                    size: 36,
                    color: context.colores.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seccion.materiaNombre ?? 'Sin materia',
                        style: context.textos.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sección ID: ${seccion.id}',
                        style: context.textos.bodyLarge?.copyWith(
                          color: context.colores.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            Text('Información General', style: context.textos.titleMedium),
            const SizedBox(height: 16),

            _CampoDetalle(
              label: 'Profesor Asignado',
              valor: seccion.profesorNombre ?? 'N/A',
              icono: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _CampoDetalle(
              label: 'Periodo Académico',
              valor: seccion.periodo ?? 'N/A',
              icono: Icons.date_range_rounded,
            ),
            const SizedBox(height: 12),
            _CampoDetalle(
              label: 'Estado',
              valor: _capitalizar(seccion.estado),
              icono: Icons.info_outline_rounded,
            ),

            const SizedBox(height: 24),
            Text('Horario y Capacidad', style: context.textos.titleMedium),
            const SizedBox(height: 16),

            _CampoDetalle(
              label: 'Aula / Laboratorio',
              valor: seccion.aula ?? 'No asignada',
              icono: Icons.door_front_door_outlined,
            ),
            const SizedBox(height: 12),
            _CampoDetalle(
              label: 'Horario',
              valor: seccion.horarioDescripcion ?? 'No definido',
              icono: Icons.schedule_rounded,
            ),
            const SizedBox(height: 12),
            _CampoDetalle(
              label: 'Inscritos / Cupo Máximo',
              // Formato para mostrar "15 de 30 estudiantes"
              valor:
                  '${seccion.inscritos ?? 0} de ${seccion.cupoMaximo} estudiantes',
              icono: Icons.people_outline_rounded,
            ),

            const SizedBox(height: 32),
            // Aquí puedes agregar botones de acción (Ej: "Ver estudiantes inscritos", "Editar sección")
          ],
        ),
      ),
    );
  }
}

// Versión mejorada de _CampoDetalle que soporta un ícono opcional
class _CampoDetalle extends StatelessWidget {
  final String label;
  final String valor;
  final IconData? icono;

  const _CampoDetalle({required this.label, required this.valor, this.icono});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icono != null) ...[
          Icon(icono, size: 20, color: context.colores.onSurfaceVariant),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
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
