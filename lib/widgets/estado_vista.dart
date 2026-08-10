import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../app/tema.dart';
import 'comunes.dart';

/// Esqueleto de carga: rectángulos con brillo en lugar de un spinner suelto.
///
/// Da sensación de que el contenido "ya viene" y evita el salto visual del
/// indicador circular centrado.
class CargandoSkeleton extends StatelessWidget {
  const CargandoSkeleton({super.key, this.lineas = 4, this.altura = 92});

  /// Número de bloques que se dibujan.
  final int lineas;

  /// Alto de cada bloque; se ajusta al tipo de tarjeta que va a sustituir.
  final double altura;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;

    return Shimmer.fromColors(
      baseColor: colores.surfaceContainerHighest,
      highlightColor: colores.surfaceContainerLow,
      child: ContenidoCentrado(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lineas,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, _) => Container(
            height: altura,
            decoration: BoxDecoration(
              color: colores.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(TemaApp.radio),
            ),
          ),
        ),
      ),
    );
  }
}

/// Estado vacío ilustrado: icono grande, título y una explicación breve.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
    this.textoAccion,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;
  final VoidCallback? accion;
  final String? textoAccion;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: colores.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colores.primary.withValues(alpha: 0.16),
                  width: 6,
                ),
              ),
              child: Icon(icono, size: 46, color: colores.onPrimaryContainer),
            ),
            const SizedBox(height: 20),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: context.textos.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: context.textos.bodyMedium?.copyWith(
                color: colores.onSurfaceVariant,
              ),
            ),
            if (accion != null && textoAccion != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(onPressed: accion, child: Text(textoAccion!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error con opción de reintentar. Se usa cuando el backend no responde.
class EstadoError extends StatelessWidget {
  const EstadoError({
    super.key,
    required this.mensaje,
    required this.alReintentar,
  });

  final String mensaje;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: context.colores.error,
            ),
            const SizedBox(height: 16),
            Text(
              'No pudimos cargar la información',
              textAlign: TextAlign.center,
              style: context.textos.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: context.textos.bodyMedium?.copyWith(
                color: context.colores.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: alReintentar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Decide qué mostrar según el estado del proveedor: esqueleto, error, vacío o contenido.
///
/// Centralizarlo aquí es lo que hace que las nueve pantallas se sientan iguales.
class VistaEstado extends StatelessWidget {
  const VistaEstado({
    super.key,
    required this.cargando,
    required this.error,
    required this.vacio,
    required this.alReintentar,
    required this.contenido,
    required this.vistaVacia,
    this.skeleton,
  });

  final bool cargando;
  final String? error;
  final bool vacio;
  final VoidCallback alReintentar;
  final WidgetBuilder contenido;
  final Widget vistaVacia;
  final Widget? skeleton;

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return skeleton ?? const CargandoSkeleton();
    }
    if (error != null) {
      return EstadoError(mensaje: error!, alReintentar: alReintentar);
    }
    if (vacio) {
      return vistaVacia;
    }
    return contenido(context);
  }
}
