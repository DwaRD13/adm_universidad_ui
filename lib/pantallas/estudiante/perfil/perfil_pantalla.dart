import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/tema.dart';
import '../../../modelos/usuario.dart';
import '../../../proveedores/perfil_proveedor.dart';
import '../../../proveedores/sesion_proveedor.dart';
import '../../../proveedores/tema_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Datos personales del estudiante, edición de teléfono y contraseña,
/// preferencia de tema y cierre de sesión.
class PerfilPantalla extends StatefulWidget {
  const PerfilPantalla({super.key});

  @override
  State<PerfilPantalla> createState() => _PerfilPantallaState();
}

class _PerfilPantallaState extends State<PerfilPantalla> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerfilProveedor>().cargar();
    });
  }

  Future<void> _editarTelefono(Usuario usuario) async {
    final controlador = TextEditingController(text: usuario.telefono ?? '');

    final nuevo = await showDialog<String>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Editar teléfono'),
        content: TextField(
          controller: controlador,
          autofocus: true,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            hintText: '809-555-0000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogo, controlador.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    controlador.dispose();
    if (nuevo == null || !mounted) return;

    await _guardar(telefono: nuevo);
  }

  Future<void> _cambiarPassword() async {
    final actual = TextEditingController();
    final nueva = TextEditingController();
    final formulario = GlobalKey<FormState>();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Form(
          key: formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: actual,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Escribe tu contraseña actual.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nueva,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                ),
                validator: (v) => (v == null || v.length < 6)
                    ? 'La nueva contraseña debe tener al menos 6 caracteres.'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formulario.currentState!.validate()) {
                Navigator.pop(dialogo, true);
              }
            },
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );

    if (confirmado == true && mounted) {
      await _guardar(passwordActual: actual.text, passwordNueva: nueva.text);
    }

    actual.dispose();
    nueva.dispose();
  }

  Future<void> _guardar({
    String? telefono,
    String? passwordActual,
    String? passwordNueva,
  }) async {
    final proveedor = context.read<PerfilProveedor>();

    final error = await proveedor.guardar(
      telefono: telefono,
      passwordActual: passwordActual,
      passwordNueva: passwordNueva,
    );
    if (!mounted) return;

    if (error == null && proveedor.usuario != null) {
      // La sesión guarda su propia copia del usuario: hay que sincronizarla.
      context.read<SesionProveedor>().actualizarUsuario(proveedor.usuario!);
    }

    mostrarAviso(
      context,
      error ?? 'Cambios guardados correctamente.',
      esError: error != null,
    );
  }

  Future<void> _cerrarSesion() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogo, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmado == true && mounted) {
      await context.read<SesionProveedor>().cerrarSesion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<PerfilProveedor>();
    // Si el perfil aún no llegó, se usa el usuario de la sesión para pintar ya.
    final usuario =
        proveedor.usuario ?? context.watch<SesionProveedor>().usuario;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: VistaEstado(
        cargando: proveedor.cargando && usuario == null,
        error: usuario == null ? proveedor.error : null,
        vacio: usuario == null,
        alReintentar: proveedor.cargar,
        skeleton: const CargandoSkeleton(lineas: 4, altura: 100),
        vistaVacia: const EstadoVacio(
          icono: Icons.person_off_outlined,
          titulo: 'No pudimos cargar tu perfil',
          mensaje: 'Vuelve a intentarlo en unos segundos.',
        ),
        contenido: (context) => RefreshIndicator(
          onRefresh: () => proveedor.cargar(silencioso: true),
          child: ContenidoCentrado(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _Cabecera(usuario: usuario!),
                const SizedBox(height: 24),

                const EncabezadoSeccion(titulo: 'Datos personales'),
                const SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      _Fila(
                        icono: Icons.badge_outlined,
                        etiqueta: 'Matrícula',
                        valor: usuario.matricula ?? 'No asignada',
                      ),
                      const Divider(height: 1, indent: 56),
                      _Fila(
                        icono: Icons.alternate_email_rounded,
                        etiqueta: 'Correo institucional',
                        valor: usuario.email,
                      ),
                      const Divider(height: 1, indent: 56),
                      _Fila(
                        icono: Icons.phone_outlined,
                        etiqueta: 'Teléfono',
                        valor: usuario.telefono ?? 'Sin registrar',
                        alPulsar: proveedor.guardando
                            ? null
                            : () => _editarTelefono(usuario),
                      ),
                      const Divider(height: 1, indent: 56),
                      _Fila(
                        icono: Icons.verified_user_outlined,
                        etiqueta: 'Estado de la cuenta',
                        valor: usuario.estado ?? 'Activo',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const EncabezadoSeccion(titulo: 'Preferencias'),
                const SizedBox(height: 10),
                const Card(child: _SelectorTema()),

                const SizedBox(height: 24),
                const EncabezadoSeccion(titulo: 'Seguridad'),
                const SizedBox(height: 10),
                Card(
                  child: _Fila(
                    icono: Icons.lock_outline_rounded,
                    etiqueta: 'Contraseña',
                    valor: 'Cambiar mi contraseña',
                    alPulsar: proveedor.guardando ? null : _cambiarPassword,
                  ),
                ),

                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: _cerrarSesion,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesión'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colores.error,
                    side: BorderSide(
                      color: context.colores.error.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Mismo azul que la tarjeta de promedio: las dos superficies invertidas
        // de la app se ven como la misma familia y no como dos decisiones.
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: colores.onPrimary.withValues(alpha: 0.2),
            child: Text(
              usuario.nombreCompleto.isEmpty
                  ? '?'
                  : usuario.nombreCompleto
                        .trim()
                        .split(RegExp(r'\s+'))
                        .take(2)
                        .map((p) => p[0].toUpperCase())
                        .join(),
              style: context.textos.headlineSmall?.copyWith(
                color: colores.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.nombreCompleto,
                  style: context.textos.titleLarge?.copyWith(
                    color: colores.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  usuario.rol,
                  style: context.textos.bodySmall?.copyWith(
                    color: colores.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                if (usuario.matricula != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colores.onPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      usuario.matricula!,
                      style: context.textos.labelMedium?.copyWith(
                        color: colores.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    this.alPulsar,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono, color: context.colores.onSurfaceVariant),
      title: Text(
        etiqueta,
        style: context.textos.bodySmall?.copyWith(
          color: context.colores.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        valor,
        style: context.textos.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: alPulsar == null
          ? null
          : Icon(
              Icons.chevron_right_rounded,
              color: context.colores.onSurfaceVariant,
            ),
      onTap: alPulsar,
    );
  }
}

class _SelectorTema extends StatelessWidget {
  const _SelectorTema();

  @override
  Widget build(BuildContext context) {
    final tema = context.watch<TemaProveedor>();

    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.palette_outlined,
            color: context.colores.onSurfaceVariant,
          ),
          title: Text(
            'Apariencia',
            style: context.textos.bodySmall?.copyWith(
              color: context.colores.onSurfaceVariant,
            ),
          ),
          subtitle: Text(
            tema.etiqueta,
            style: context.textos.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_rounded, size: 18),
                label: Text('Claro'),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_rounded, size: 18),
                label: Text('Auto'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_rounded, size: 18),
                label: Text('Oscuro'),
              ),
            ],
            selected: {tema.modo},
            onSelectionChanged: (seleccion) => tema.cambiar(seleccion.first),
            showSelectedIcon: false,
          ),
        ),
      ],
    );
  }
}
