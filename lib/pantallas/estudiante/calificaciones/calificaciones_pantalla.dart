import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/tema.dart';
import '../../../modelos/academico.dart';
import '../../../nucleo/formato.dart';
import '../../../proveedores/calificaciones_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Calificaciones finales publicadas, agrupadas por periodo académico.
class CalificacionesPantalla extends StatefulWidget {
  const CalificacionesPantalla({super.key});

  @override
  State<CalificacionesPantalla> createState() => _CalificacionesPantallaState();
}

class _CalificacionesPantallaState extends State<CalificacionesPantalla> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalificacionesProveedor>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<CalificacionesProveedor>();
    final datos = proveedor.datos;

    return Scaffold(
      appBar: AppBar(title: const Text('Calificaciones')),
      body: VistaEstado(
        cargando: proveedor.cargando && !proveedor.cargadoAlgunaVez,
        error: proveedor.error,
        vacio: proveedor.vacio,
        alReintentar: proveedor.cargar,
        skeleton: const CargandoSkeleton(lineas: 5, altura: 84),
        vistaVacia: const EstadoVacio(
          icono: Icons.grade_rounded,
          titulo: 'Todavía no hay notas',
          mensaje:
              'Cuando tus profesores publiquen las calificaciones finales, '
              'las verás aquí junto a tu promedio.',
        ),
        contenido: (context) => RefreshIndicator(
          onRefresh: () => proveedor.cargar(silencioso: true),
          child: ContenidoCentrado(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _ResumenPromedio(datos: datos!),
                const SizedBox(height: 24),
                for (final entrada in proveedor.porPeriodo.entries) ...[
                  EncabezadoSeccion(
                    titulo: 'Periodo ${entrada.key}',
                    subtitulo:
                        '${entrada.value.length} '
                        '${entrada.value.length == 1 ? 'materia' : 'materias'}',
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < entrada.value.length; i++)
                    EntradaAnimada(
                      indice: i,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TarjetaNota(nota: entrada.value[i]),
                      ),
                    ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta destacada con el promedio general ponderado por créditos.
class _ResumenPromedio extends StatelessWidget {
  const _ResumenPromedio({required this.datos});

  final Calificaciones datos;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final estados = context.estados;
    final promedio = datos.promedioGeneral ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Azul sólido de marca: es la única superficie "invertida" de la
        // pantalla y por eso el promedio se lee como el dato principal.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colores.primary,
            Color.lerp(colores.primary, colores.secondary, 0.6)!,
          ],
        ),
        borderRadius: BorderRadius.circular(TemaApp.radio + 2),
        boxShadow: [
          BoxShadow(
            color: colores.primary.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promedio general',
            style: context.textos.labelLarge?.copyWith(
              color: colores.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formato.nota(datos.promedioGeneral),
                style: context.textos.displaySmall?.copyWith(
                  color: colores.onPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '/ 100',
                  style: context.textos.titleMedium?.copyWith(
                    color: colores.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          BarraProgreso(
            valor: promedio / 100,
            color: colores.onPrimary,
            altura: 8,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _Contador(
                valor: datos.materiasAprobadas,
                etiqueta: 'Aprobadas',
                color: estados.exito,
              ),
              const SizedBox(width: 12),
              _Contador(
                valor: datos.materiasReprobadas,
                etiqueta: 'Reprobadas',
                color: estados.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador({
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  final int valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.colores.onPrimary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '$valor',
              style: context.textos.titleMedium?.copyWith(
                color: context.colores.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                etiqueta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textos.labelSmall?.copyWith(
                  color: context.colores.onPrimary.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaNota extends StatelessWidget {
  const _TarjetaNota({required this.nota});

  final Calificacion nota;

  @override
  Widget build(BuildContext context) {
    final estados = context.estados;
    final aprobada =
        nota.aprobada || (nota.estadoInscripcion == null && nota.nota >= 70);
    final color = aprobada ? estados.exito : estados.error;

    return Card(
      child: Theme(
        // Quita las líneas divisorias que ExpansionTile dibuja por defecto.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: const Border(),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              nota.literal ?? '—',
              style: context.textos.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            nota.materia,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textos.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${nota.codigoMateria} · ${nota.creditos} créditos',
              style: context.textos.bodySmall?.copyWith(
                color: context.colores.onSurfaceVariant,
              ),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formato.nota(nota.nota),
                style: context.textos.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (nota.estadoInscripcion != null)
                Text(
                  nota.estadoInscripcion!,
                  style: context.textos.labelSmall?.copyWith(color: color),
                ),
            ],
          ),
          children: [
            const Divider(height: 20),
            _Linea(etiqueta: 'Profesor', valor: nota.profesor),
            _Linea(etiqueta: 'Periodo', valor: nota.periodo),
            _Linea(etiqueta: 'Créditos', valor: '${nota.creditos}'),
            _Linea(
              etiqueta: 'Publicada',
              valor: Formato.fechaLarga(nota.fechaPublicacion),
            ),
          ],
        ),
      ),
    );
  }
}

class _Linea extends StatelessWidget {
  const _Linea({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              etiqueta,
              style: context.textos.bodySmall?.copyWith(
                color: context.colores.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: context.textos.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
