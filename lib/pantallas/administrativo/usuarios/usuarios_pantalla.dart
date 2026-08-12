import 'package:adm_universidad_ui/modelos/usuario_admin.dart';
import 'package:adm_universidad_ui/nucleo/formato.dart';
import 'package:adm_universidad_ui/proveedores/usuarios_proveedor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../app/tema.dart';
import '../../../proveedores/sesion_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Listado de usuarios con búsqueda, filtros por rol y estado.
class UsuariosPantalla extends StatefulWidget {
  const UsuariosPantalla({super.key});

  @override
  State<UsuariosPantalla> createState() => _UsuariosPantallaState();
}

class _UsuariosPantallaState extends State<UsuariosPantalla> {
  final _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsuariosProveedor>().cargarUsuarios();
    });
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<UsuariosProveedor>();
    final sesion = context.watch<SesionProveedor>().usuario;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'Nuevo usuario',
            onPressed: () => context.push(Rutas.nuevoUsuario),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _busquedaCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, email o ID...',
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

          // Filtros de rol y estado
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _ChipFiltro(
                  etiqueta: 'Todos',
                  seleccionado: proveedor.filtroRol == null,
                  alPulsar: () => proveedor.cambiarFiltroRol(null),
                ),
                const SizedBox(width: 8),
                _ChipFiltro(
                  etiqueta: 'Estudiantes',
                  seleccionado: proveedor.filtroRol == 'Estudiante',
                  alPulsar: () => proveedor.cambiarFiltroRol('Estudiante'),
                ),
                const SizedBox(width: 8),
                _ChipFiltro(
                  etiqueta: 'Profesores',
                  seleccionado: proveedor.filtroRol == 'Profesor',
                  alPulsar: () => proveedor.cambiarFiltroRol('Profesor'),
                ),
                const SizedBox(width: 8),
                _ChipFiltro(
                  etiqueta: 'Administrativos',
                  seleccionado: proveedor.filtroRol == 'Administrativo',
                  alPulsar: () => proveedor.cambiarFiltroRol('Administrativo'),
                ),
                const SizedBox(width: 16),
                _ChipFiltro(
                  etiqueta: 'Activo',
                  seleccionado: proveedor.filtroEstado == 'Activo',
                  alPulsar: () => proveedor.cambiarFiltroEstado('Activo'),
                ),
                const SizedBox(width: 8),
                _ChipFiltro(
                  etiqueta: 'Inactivo',
                  seleccionado: proveedor.filtroEstado == 'Inactivo',
                  alPulsar: () => proveedor.cambiarFiltroEstado('Inactivo'),
                ),
                const SizedBox(width: 8),
                _ChipFiltro(
                  etiqueta: 'Suspendido',
                  seleccionado: proveedor.filtroEstado == 'Suspendido',
                  alPulsar: () => proveedor.cambiarFiltroEstado('Suspendido'),
                ),
              ],
            ),
          ),

          // Lista de usuarios
          Expanded(
            child: VistaEstado(
              cargando: proveedor.cargando && proveedor.usuarios.isEmpty,
              error: proveedor.usuarios.isEmpty ? proveedor.error : null,
              vacio: !proveedor.cargando && proveedor.usuarios.isEmpty,
              alReintentar: proveedor.cargarUsuarios,
              vistaVacia: const _ListaVacia(),
              skeleton: const CargandoSkeleton(lineas: 6, altura: 72),
              contenido: (context) => RefreshIndicator(
                onRefresh: () => proveedor.cargarUsuarios(silencioso: true),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: proveedor.usuarios.length,
                  itemBuilder: (_, i) {
                    final usuario = proveedor.usuarios[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TarjetaUsuario(usuario: usuario),
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

// ---------------------------------------------------------------------------
// Chip de filtro reutilizable
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// Tarjeta de cada usuario
// ---------------------------------------------------------------------------
class _TarjetaUsuario extends StatelessWidget {
  const _TarjetaUsuario({required this.usuario});

  final UsuarioAdmin usuario;

  Color _colorEstado(BuildContext context) {
    switch (usuario.estado) {
      case 'Activo':
        return context.estados.exito;
      case 'Inactivo':
        return context.estados.advertencia;
      case 'Suspendido':
        return context.estados.error;
      default:
        return context.colores.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final estadoColor = _colorEstado(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Rutas.detalleUsuario(usuario.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Iniciales o avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: colores.primaryContainer,
                child: Text(
                  Formato.iniciales('${usuario.nombres} ${usuario.apellidos}'),
                  style: context.textos.labelLarge?.copyWith(
                    color: colores.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${usuario.nombres} ${usuario.apellidos}',
                      style: context.textos.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      usuario.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textos.bodySmall?.copyWith(
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Insignia de rol y estado
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _InsigniaRol(usuario: usuario),
                        ChipEstado(
                          texto: usuario.estado ?? 'Desconocido',
                          tono: estadoColor == context.estados.exito
                              ? TonoEstado.exito
                              : estadoColor == context.estados.advertencia
                              ? TonoEstado.advertencia
                              : TonoEstado.error,
                          icono: Icons.circle_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Indicador de matrícula / ID si existe
              if (usuario.matricula != null &&
                  usuario.matricula!.isNotEmpty)
                Chip(
                  avatar: const Icon(Icons.tag_rounded, size: 16),
                  label: Text(
                    usuario.matricula!,
                    style: context.textos.labelSmall,
                  ),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: colores.surfaceContainerHighest,
                  side: BorderSide.none,
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

class _InsigniaRol extends StatelessWidget {
  const _InsigniaRol({required this.usuario});

  final UsuarioAdmin usuario;

  @override
  Widget build(BuildContext context) {
    IconData icono;
    Color color;
    switch (usuario.rol) {
      case 'Administrativo':
        icono = Icons.admin_panel_settings_rounded;
        color = context.colores.primary;
        break;
      case 'Profesor':
        icono = Icons.school_rounded;
        color = context.estados.info;
        break;
      case 'Estudiante':
        icono = Icons.person_rounded;
        color = context.estados.exito;
        break;
      default:
        icono = Icons.person_outline;
        color = context.colores.outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            usuario.rol,
            style: context.textos.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vista cuando no hay usuarios
// ---------------------------------------------------------------------------
class _ListaVacia extends StatelessWidget {
  const _ListaVacia();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.people_outline_rounded,
          size: 64,
          color: context.colores.outline,
        ),
        const SizedBox(height: 16),
        Text(
          'No se encontraron usuarios',
          textAlign: TextAlign.center,
          style: context.textos.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Ajusta los filtros o añade nuevos usuarios.',
          textAlign: TextAlign.center,
          style: context.textos.bodySmall?.copyWith(
            color: context.colores.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
