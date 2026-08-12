import 'package:adm_universidad_ui/proveedores/usuarios_proveedor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../modelos/usuario_admin.dart';
import '../../../servicios/admin_servicio.dart';
import '../../../app/tema.dart'; // Ajusta la ruta según tu proyecto

class NuevoUsuarioPantalla extends StatefulWidget {
  const NuevoUsuarioPantalla({super.key});

  @override
  State<NuevoUsuarioPantalla> createState() => _NuevoUsuarioPantallaState();
}

class _NuevoUsuarioPantallaState extends State<NuevoUsuarioPantalla> {
  final _formKey = GlobalKey<FormState>();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl =
      TextEditingController(); // <- NUEVO: Controlador para contraseña
  final _matriculaCtrl = TextEditingController();
  String _rolSeleccionado = 'Estudiante';
  bool _cargando = false;

  // IDs de roles (ajusta según tu base de datos)
  static const _roles = [
    {'nombre': 'Administrativo', 'id': 1},
    {'nombre': 'Profesor', 'id': 2},
    {'nombre': 'Estudiante', 'id': 3},
  ];

  Future<void> _crear() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    try {
      final admin = context.read<AdminServicio>();
      final rolId = _roles.firstWhere(
        (r) => r['nombre'] == _rolSeleccionado,
      )['id'];

      // JSON BODY AJUSTADO
      final body = {
        'nombres': _nombresCtrl.text.trim(),
        'apellidos': _apellidosCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'passwordHash': _passwordCtrl.text
            .trim(), // Coincide con la variable en Java
        'rol': {'id': rolId},
        'estado': 'ACTIVO', // Todo en mayúsculas por el Enum
        'matriculaEmpleadoId': _matriculaCtrl.text.trim().isEmpty
            ? null
            : _matriculaCtrl.text.trim(), // CamelCase como en Java
      };

      await admin.post('/usuarios', body: body);
      if (mounted) {
        context.read<UsuariosProveedor>().cargarUsuarios();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose(); // No olvides limpiar la memoria
    _matriculaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Información personal', style: context.textos.titleMedium),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombresCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombres',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apellidosCtrl,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // NUEVO CAMPO: CONTRASEÑA
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 24),
              Text('Datos institucionales', style: context.textos.titleMedium),
              const SizedBox(height: 16),
              TextFormField(
                controller: _matriculaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Matrícula / ID empleado (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _rolSeleccionado,
                items: _roles
                    .map(
                      (r) => DropdownMenuItem(
                        value: r['nombre'] as String,
                        child: Text(r['nombre'] as String),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _rolSeleccionado = v!),
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.admin_panel_settings),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _cargando ? null : _crear,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _cargando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Crear usuario',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
