import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../app/tema.dart';
import '../../../modelos/admin_resumen.dart';
import '../../../proveedores/admin_dashboard_proveedor.dart';
import '../../../proveedores/sesion_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Pantalla principal del administrativo: indicadores globales,
/// actividad reciente y accesos a los módulos de gestión.
class AdminDashboardPantalla extends StatefulWidget {
  const AdminDashboardPantalla({super.key});

  @override
  State<AdminDashboardPantalla> createState() => _AdminDashboardPantallaState();
}

class _AdminDashboardPantallaState extends State<AdminDashboardPantalla> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProveedor>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<AdminDashboardProveedor>();
    final usuario = context.watch<SesionProveedor>().usuario;
    final resumen = proveedor.resumen;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => proveedor.cargar(silencioso: true),
          child: VistaEstado(
            cargando: proveedor.cargando && resumen == null,
            error: resumen == null ? proveedor.error : null,
            vacio: false,
            alReintentar: proveedor.cargar,
            vistaVacia: const SizedBox.shrink(),
            skeleton: const CargandoSkeleton(lineas: 5, altura: 110),
            contenido: (context) => ContenidoCentrado(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  TarjetaHero(
                    child: _SaludoAdmin(
                      nombre: usuario?.nombres ?? '',
                      empleadoId: usuario?.matricula_empleado_id,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (resumen != null) ...[
                    _IndicadoresGlobales(resumen: resumen),
                    const SizedBox(height: 20),
                    _ActividadReciente(resumen: resumen),
                    const SizedBox(height: 20),
                    const EncabezadoSeccion(
                      titulo: 'Accesos rápidos',
                      subtitulo: 'Gestiona la plataforma',
                    ),
                    const SizedBox(height: 12),
                    _CuadriculaModulosAdmin(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Saludo administrativo sobre la tarjeta hero
// ---------------------------------------------------------------------------
class _SaludoAdmin extends StatelessWidget {
  const _SaludoAdmin({required this.nombre, this.empleadoId});

  final String nombre;
  final String? empleadoId;

  String get _franja {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final sobreAzul = colores.onPrimaryContainer;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _franja,
                style: context.textos.bodyMedium?.copyWith(
                  color: sobreAzul.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                nombre,
                style: context.textos.headlineMedium?.copyWith(
                  color: sobreAzul,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Panel administrativo',
                style: context.textos.bodySmall?.copyWith(
                  color: sobreAzul.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 10),
              if (empleadoId != null && empleadoId!.isNotEmpty)
                _Insignia(
                  texto: 'ID $empleadoId',
                  color: sobreAzul,
                  icono: Icons.badge_outlined,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colores.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            Formato.iniciales(nombre),
            style: context.textos.titleLarge?.copyWith(
              color: colores.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Fila de indicadores globales
// ---------------------------------------------------------------------------
class _IndicadoresGlobales extends StatelessWidget {
  const _IndicadoresGlobales({required this.resumen});

  final AdminResumen resumen;

  @override
  Widget build(BuildContext context) {
    final estados = context.estados;

    return Row(
      children: [
        Expanded(
          child: _Indicador(
            icono: Icons.people_alt_rounded,
            valor: '${resumen.totalEstudiantes}',
            etiqueta: 'Estudiantes',
            detalle: '${resumen.estudiantesActivos} activos',
            color: context.colores.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Indicador(
            icono: Icons.school_rounded,
            valor: '${resumen.totalProfesores}',
            etiqueta: 'Profesores',
            detalle: '${resumen.profesoresActivos} activos',
            color: estados.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Indicador(
            icono: Icons.meeting_room_rounded,
            valor: '${resumen.seccionesActivas}',
            etiqueta: 'Secciones',
            detalle: 'Periodo actual',
            color: estados.exito,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Actividad reciente (últimas inscripciones / mensajes)
// ---------------------------------------------------------------------------
class _ActividadReciente extends StatelessWidget {
  const _ActividadReciente({required this.resumen});

  final AdminResumen resumen;

  @override
  Widget build(BuildContext context) {
    // Si no hay actividad reciente se muestra un mensaje amigable
    if (resumen.ultimasActividades.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: context.estados.info),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No hay actividad reciente que mostrar.',
                  style: context.textos.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EncabezadoSeccion(
          titulo: 'Actividad reciente',
          subtitulo: 'Lo último que ha sucedido',
        ),
        const SizedBox(height: 8),
        ...List.generate(resumen.ultimasActividades.length, (i) {
          final act = resumen.ultimasActividades[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FilaActividad(actividad: act),
          );
        }),
        Center(
          child: TextButton(
            onPressed: () {}, // Podría ir a un historial
            child: const Text('Ver todo el historial'),
          ),
        ),
      ],
    );
  }
}

class _FilaActividad extends StatelessWidget {
  const _FilaActividad({required this.actividad});

  final ActividadReciente actividad;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              actividad.icono,
              size: 22,
              color: context.colores.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actividad.titulo,
                    style: context.textos.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    actividad.descripcion,
                    style: context.textos.bodySmall?.copyWith(
                      color: context.colores.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              actividad.hora,
              style: context.textos.labelSmall?.copyWith(
                color: context.colores.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cuadrícula de módulos administrativos
// ---------------------------------------------------------------------------
class _CuadriculaModulosAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final estados = context.estados;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        TarjetaModulo(
          icono: Icons.manage_accounts_rounded,
          titulo: 'Usuarios',
          color: estados.info,
          alPulsar: () => context.push(Rutas.usuarios),
        ),
        TarjetaModulo(
          icono: Icons.meeting_room_rounded,
          titulo: 'Secciones',
          color: estados.exito,
          alPulsar: () => context.push(Rutas.seccionesAdmin),
        ),
        TarjetaModulo(
          icono: Icons.auto_stories_rounded,
          titulo: 'Carreras',
          color: colores.tertiary,
          alPulsar: () => context.push(Rutas.carrerasAdmin),
        ),
        TarjetaModulo(
          icono: Icons.settings_rounded,
          titulo: 'Configuración',
          color: colores.secondary,
          alPulsar: () => context.push(Rutas.configuracion),
        ),
      ],
    );
  }
}