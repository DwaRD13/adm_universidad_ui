import 'package:flutter/material.dart';

/// Header usado en todas las pantallas del módulo Profesor, para que compartan
/// una misma identidad visual tipo "campus": azul oscuro sólido, sin degradado.
class EncabezadoGradiente extends StatelessWidget {
  const EncabezadoGradiente({
    super.key,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    this.trailing,
  });

  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    // Azul oscuro derivado del primary del tema, no un degradado con el acento dorado.
    final fondo = Color.lerp(colores.primary, Colors.black, 0.18)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: fondo.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icono, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitulo,
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class ChipEstadistica extends StatelessWidget {
  const ChipEstadistica({super.key, required this.valor, required this.etiqueta});

  final String valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(valor,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
          Text(etiqueta, style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 11)),
        ],
      ),
    );
  }
}

class TarjetaVacia extends StatelessWidget {
  const TarjetaVacia({super.key, required this.icono, required this.mensaje});

  final IconData icono;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colores.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colores.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icono, size: 40, color: colores.onSurfaceVariant.withOpacity(0.6)),
          const SizedBox(height: 12),
          Text(mensaje, textAlign: TextAlign.center, style: TextStyle(color: colores.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class VistaErrorProfesor extends StatelessWidget {
  const VistaErrorProfesor({super.key, required this.mensaje, required this.alReintentar});

  final String mensaje;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 52, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: alReintentar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de lista con borde y esquinas redondeadas que envuelve un ListTile
/// correctamente: el color de fondo vive en el Material interno, no en un
/// DecoratedBox externo, para que el ripple y el color no queden tapados.
class TarjetaListTile extends StatelessWidget {
  const TarjetaListTile({super.key, required this.child, this.colorFondo, this.margenInferior = 8});

  final Widget child;
  final Color? colorFondo;
  final double margenInferior;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: margenInferior),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colores.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: colorFondo ?? colores.surface,
        child: child,
      ),
    );
  }
}

Future<bool> confirmarEliminacion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return resultado ?? false;
}