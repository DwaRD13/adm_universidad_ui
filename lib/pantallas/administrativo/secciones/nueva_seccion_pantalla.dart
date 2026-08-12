import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/tema.dart';
import '../../../modelos/materia.dart';
import '../../../modelos/usuario.dart';
import '../../../proveedores/secciones_proveedor.dart';
import '../../../widgets/comunes.dart';

class NuevaSeccionPantalla extends StatefulWidget {
  const NuevaSeccionPantalla({super.key});

  @override
  State<NuevaSeccionPantalla> createState() => _NuevaSeccionPantallaState();
}

class _NuevaSeccionPantallaState extends State<NuevaSeccionPantalla> {
  final _formKey = GlobalKey<FormState>();
  int? _materiaId;
  int? _profesorId;
  final _periodoCtrl = TextEditingController();
  final _cupoMaximoCtrl = TextEditingController();
  final _aulaCtrl = TextEditingController();
  final _horarioCtrl = TextEditingController();
  String _estado = 'Abierta'; // valor por defecto
  bool _guardando = false;

  @override
  void dispose() {
    _periodoCtrl.dispose();
    _cupoMaximoCtrl.dispose();
    _aulaCtrl.dispose();
    _horarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _guardando = true);
    try {
      final proveedor = context.read<SeccionesProveedor>();
      await proveedor.crearSeccion({
        'materiaId': _materiaId,
        'profesorId': _profesorId,
        'periodo': _periodoCtrl.text.trim(),
        'cupoMaximo': int.parse(_cupoMaximoCtrl.text.trim()),
        'aula': _aulaCtrl.text.trim(),
        'horarioDescripcion': _horarioCtrl.text.trim(),
        'estado': _estado,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sección creada exitosamente')),
        );
        context.pop(); // regresa a la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al crear: $e')));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<SeccionesProveedor>();
    final materias = proveedor.materias; // List<Materia>
    final profesores = proveedor.profesores; // List<Usuario> con rol profesor

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Sección')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Dropdown de materia
            DropdownButtonFormField<int>(
              value: _materiaId,
              decoration: const InputDecoration(labelText: 'Materia'),
              items: materias
                  .map(
                    (m) => DropdownMenuItem(value: m.id, child: Text(m.nombre)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _materiaId = val),
              validator: (val) => val == null ? 'Seleccione una materia' : null,
            ),
            const SizedBox(height: 16),
            // Dropdown de profesor
            DropdownButtonFormField<int>(
              value: _profesorId,
              decoration: const InputDecoration(labelText: 'Profesor'),
              items: profesores
                  .map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text('${p.nombres} ${p.apellidos}'),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _profesorId = val),
              validator: (val) => val == null ? 'Seleccione un profesor' : null,
            ),
            const SizedBox(height: 16),
            // Periodo
            TextFormField(
              controller: _periodoCtrl,
              decoration: const InputDecoration(
                labelText: 'Periodo',
                hintText: 'Ej: 2026-C3',
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            // Cupo máximo
            TextFormField(
              controller: _cupoMaximoCtrl,
              decoration: const InputDecoration(labelText: 'Cupo máximo'),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Campo requerido';
                if (int.tryParse(val.trim()) == null)
                  return 'Ingrese un número';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Aula
            TextFormField(
              controller: _aulaCtrl,
              decoration: const InputDecoration(labelText: 'Aula (opcional)'),
            ),
            const SizedBox(height: 16),
            // Horario descripción
            TextFormField(
              controller: _horarioCtrl,
              decoration: const InputDecoration(
                labelText: 'Horario',
                hintText: 'Ej: Lu-Mi 08:00 - 10:00',
              ),
            ),
            const SizedBox(height: 16),
            // Estado
            DropdownButtonFormField<String>(
              value: _estado,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: [
                'Abierta',
                'Cerrada',
                'En Curso',
                'Finalizada',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _estado = val!),
            ),
            const SizedBox(height: 32),
            // Botón guardar
            ElevatedButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Crear Sección'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
