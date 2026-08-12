import 'package:adm_universidad_ui/modelos/usuario_admin.dart';
import 'package:adm_universidad_ui/nucleo/formato.dart';
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
    final resumen = proveedor.resumen;
    final usuario = context.watch<SesionProveedor>().usuario;

    String nombreAdmin = usuario?.nombres != null
        ? '${usuario?.nombres} ${usuario?.apellidos}'
        : 'Administrador ';
    String? empleadoIdAdmin;

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
                      nombre: nombreAdmin,
                      empleadoId: empleadoIdAdmin,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (resumen != null) ...[
                    _IndicadoresGlobales(resumen: resumen),
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
// Saludo administrativo
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
// Insignia (igual que en el dashboard de estudiante)
// ---------------------------------------------------------------------------
class _Insignia extends StatelessWidget {
  const _Insignia({required this.texto, required this.color, this.icono});

  final String texto;
  final Color color;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: context.textos.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Indicadores globales
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
            detalle: '',
            color: context.colores.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Indicador(
            icono: Icons.school_rounded,
            valor: '${resumen.totalProfesores}',
            etiqueta: 'Profesores',
            detalle: '',
            color: estados.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Indicador(
            icono: Icons.meeting_room_rounded,
            valor: '${resumen.totalSecciones}',
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
// Widget _Indicador (idéntico al del dashboard de estudiante)
// ---------------------------------------------------------------------------
class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.detalle,
    required this.color,
  });

  final IconData icono;
  final String valor;
  final String etiqueta;
  final String detalle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icono, size: 18, color: color),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(valor, style: context.textos.headlineSmall),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: context.textos.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              detalle,
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
// Cuadrícula de módulos
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
          alPulsar: () => context.push(Rutas.adminUsuarios),
        ),
        TarjetaModulo(
          icono: Icons.meeting_room_rounded,
          titulo: 'Secciones',
          color: estados.exito,
          alPulsar: () => context.push(Rutas.adminSecciones),
        ),
        TarjetaModulo(
          icono: Icons.auto_stories_rounded,
          titulo: 'Carreras',
          color: colores.tertiary,
          alPulsar: () => context.push(Rutas.adminCarreras),
        ),
        TarjetaModulo(
          icono: Icons.bar_chart_rounded,
          titulo: 'Reportes',
          color: colores.secondary,
          alPulsar: () => context.push(Rutas.adminReportes),
        ),
      ],
    );
  }
}
