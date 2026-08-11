import 'package:flutter/material.dart';

import '../app/tema.dart';
import '../nucleo/formato.dart';

/// Limita el ancho del contenido y lo centra.
///
/// En móvil no se nota; en tablet y web evita que una lista se estire a todo el
/// monitor, que es lo que la vuelve ilegible.
/// Limita el ancho del contenido y lo centra.
///
/// Se puede utilizar dentro de SingleChildScrollView sin provocar
/// restricciones de altura infinita.
class ContenidoCentrado extends StatelessWidget {
  const ContenidoCentrado({
    super.key,
    required this.child,
    this.ancho = TemaApp.anchoMaximo,
  });

  final Widget child;
  final double ancho;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,

      // IMPORTANTE:
      // Hace que Align tome únicamente la altura real de su hijo.
      // Esto evita que intente ocupar una altura infinita cuando
      // está dentro de un SingleChildScrollView.
      heightFactor: 1,

      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ancho,
        ),
        child: child,
      ),
    );
  }
}
/// Tarjeta destacada: el segundo nivel de superficie sobre la [Card] normal.
///
/// Se reserva para el bloque principal de una pantalla (el saludo, el resumen).
/// Si todo fuera una tarjeta plana igual, nada tendría jerarquía.
class TarjetaHero extends StatelessWidget {
  const TarjetaHero({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        // Degradado muy corto: da profundidad al azul sin convertirse en adorno.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colores.primaryContainer,
            Color.lerp(colores.primaryContainer, colores.surface, 0.45)!,
          ],
        ),
        borderRadius: BorderRadius.circular(TemaApp.radio + 2),
        border: Border.all(color: colores.primary.withValues(alpha: 0.18)),
      ),
      child: child,
    );
  }
}

/// Etiqueta de color según el significado del estado (aprobado, ausente, pendiente...).
class ChipEstado extends StatelessWidget {
  const ChipEstado({
    super.key,
    required this.texto,
    required this.tono,
    this.icono,
  });

  final String texto;
  final TonoEstado tono;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final estados = context.estados;
    final (fondo, frente) = switch (tono) {
      TonoEstado.exito => (estados.exitoSuave, estados.exito),
      TonoEstado.advertencia => (estados.advertenciaSuave, estados.advertencia),
      TonoEstado.error => (estados.errorSuave, estados.error),
      TonoEstado.info => (estados.infoSuave, estados.info),
      TonoEstado.neutro => (
        context.colores.surfaceContainerHighest,
        context.colores.onSurfaceVariant,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 14, color: frente),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: context.textos.labelMedium?.copyWith(
              color: frente,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum TonoEstado { exito, advertencia, error, info, neutro }

/// Avatar circular con las iniciales del nombre.
///
/// El color se deriva del propio nombre para que cada persona tenga siempre el
/// mismo, sin necesidad de guardar nada.
class AvatarIniciales extends StatelessWidget {
  const AvatarIniciales({super.key, required this.nombre, this.radio = 22});

  final String nombre;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final color = context.academica.porNombre(nombre);

    return CircleAvatar(
      radius: radio,
      backgroundColor: color.withValues(alpha: 0.16),
      child: Text(
        Formato.iniciales(nombre),
        style: context.textos.titleSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: radio * 0.7,
        ),
      ),
    );
  }
}

/// Encabezado de sección dentro de una pantalla, con acción opcional a la derecha.
class EncabezadoSeccion extends StatelessWidget {
  const EncabezadoSeccion({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.accion,
  });

  final String titulo;
  final String? subtitulo;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: context.textos.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitulo != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitulo!,
                  style: context.textos.bodySmall?.copyWith(
                    color: context.colores.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?accion,
      ],
    );
  }
}

/// Anillo de progreso con el porcentaje en el centro.
///
/// Se dibuja con `CircularProgressIndicator` en vez de una librería de gráficos:
/// es un solo dato y así respeta el tema sin configuración extra.
class AnilloProgreso extends StatelessWidget {
  const AnilloProgreso({
    super.key,
    required this.valor,
    required this.etiqueta,
    this.tamano = 116,
    this.color,
  });

  /// Valor entre 0 y 100.
  final double valor;
  final String etiqueta;
  final double tamano;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tono = color ?? context.colores.primary;
    final proporcion = (valor / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: tamano,
      height: tamano,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: tamano,
            height: tamano,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: proporcion),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, animado, _) => CircularProgressIndicator(
                value: animado,
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                backgroundColor: tono.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(tono),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Formato.porcentaje(valor),
                style: context.textos.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tono,
                ),
              ),
              Text(
                etiqueta,
                style: context.textos.labelSmall?.copyWith(
                  color: context.colores.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de acceso rápido a un módulo, usada en la cuadrícula del dashboard.
class TarjetaModulo extends StatelessWidget {
  const TarjetaModulo({
    super.key,
    required this.icono,
    required this.titulo,
    required this.alPulsar,
    this.insignia,
    this.color,
  });

  final IconData icono;
  final String titulo;
  final VoidCallback alPulsar;

  /// Número que se muestra en una burbuja (tareas pendientes, mensajes sin leer).
  final int? insignia;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tono = color ?? context.colores.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alPulsar,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tono.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icono, color: tono, size: 22),
                  ),
                  if (insignia != null && insignia! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: context.colores.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$insignia',
                        style: context.textos.labelSmall?.copyWith(
                          color: context.colores.onError,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                titulo,
                style: context.textos.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra de progreso fina con etiqueta, para cupos y porcentajes de asistencia.
class BarraProgreso extends StatelessWidget {
  const BarraProgreso({
    super.key,
    required this.valor,
    required this.color,
    this.altura = 6,
  });

  /// Valor entre 0 y 1.
  final double valor;
  final Color color;
  final double altura;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(altura),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: valor.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        builder: (context, animado, _) => LinearProgressIndicator(
          value: animado,
          minHeight: altura,
          backgroundColor: color.withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    );
  }
}

/// Muestra un mensaje efímero con el estilo del tema.
void mostrarAviso(
  BuildContext context,
  String mensaje, {
  bool esError = false,
}) {
  final mensajero = ScaffoldMessenger.of(context);
  mensajero.hideCurrentSnackBar();
  mensajero.showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: esError ? context.colores.errorContainer : null,
      showCloseIcon: true,
    ),
  );
}

/// Anima la entrada de los elementos de una lista con un desplazamiento suave.
class EntradaAnimada extends StatelessWidget {
  const EntradaAnimada({super.key, required this.indice, required this.child});

  final int indice;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Se escalona el retardo, con tope para que las listas largas no se demoren.
    final retardo = Duration(milliseconds: 40 * (indice.clamp(0, 8)));

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350) + retardo,
      curve: Curves.easeOutCubic,
      builder: (context, valor, hijo) => Opacity(
        opacity: valor.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - valor)),
          child: hijo,
        ),
      ),
      child: child,
    );
  }
}
