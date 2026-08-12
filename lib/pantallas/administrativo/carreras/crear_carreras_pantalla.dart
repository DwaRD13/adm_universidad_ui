// lib/pantallas/admin/carreras/crear_editar_carrera_pantalla.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/tema.dart';
import '../../../modelos/carrera.dart';
import '../../../proveedores/carreras_proveedor.dart';
import '../../../widgets/comunes.dart';

class CrearEditarCarreraPantalla extends StatefulWidget {
  final int? id; // null para nueva
  const CrearEditarCarreraPantalla({super.key, this.id});

  @override
  State<CrearEditarCarreraPantalla> createState() =>
      _CrearEditarCarreraPantallaState();
}

class _CrearEditarCarreraPantallaState
    extends State<CrearEditarCarreraPantalla> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _codigoCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _duracionCtrl;
  bool _cargando = false;
  bool _esEdicion = false;

  @override
  void initState() {
    super.initState();
    _esEdicion = widget.id != null;
    _nombreCtrl = TextEditingController();
    _codigoCtrl = TextEditingController();
    _descripcionCtrl = TextEditingController();
    _duracionCtrl = TextEditingController();

    if (_esEdicion) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _cargarDatos());
    }
  }

  Future<void> _cargarDatos() async {
    final proveedor = context.read<CarrerasProveedor>();
    final carrera = await proveedor.obtenerCarrera(widget.id!);
    if (carrera != null && mounted) {
      _nombreCtrl.text = carrera.nombre;
      _codigoCtrl.text = carrera.codigo;
      _descripcionCtrl.text = carrera.descripcion ?? '';
      _duracionCtrl.text = carrera.duracionPeriodos.toString();
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _codigoCtrl.dispose();
    _descripcionCtrl.dispose();
    _duracionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final carrera = Carrera(
      id: widget.id,
      nombre: _nombreCtrl.text.trim(),
      codigo: _codigoCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim().isEmpty
          ? null
          : _descripcionCtrl.text.trim(),
      duracionPeriodos: int.tryParse(_duracionCtrl.text) ?? 0,
    );

    final proveedor = context.read<CarrerasProveedor>();
    bool ok;
    if (_esEdicion) {
      ok = await proveedor.actualizarCarrera(widget.id!, carrera);
    } else {
      ok = await proveedor.crearCarrera(carrera);
    }

    if (!mounted) return;
    setState(() => _cargando = false);

    if (ok) {
      context.pop(true); // regresa con éxito
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar la carrera'),
          backgroundColor: Colors.red, // opcional
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Carrera' : 'Nueva Carrera'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la carrera',
                prefixIcon: Icon(Icons.auto_stories_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codigoCtrl,
              decoration: const InputDecoration(
                labelText: 'Código',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _duracionCtrl,
              decoration: const InputDecoration(
                labelText: 'Duración (periodos)',
                prefixIcon: Icon(Icons.timelapse_rounded),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
                if (int.tryParse(v) == null || int.parse(v) <= 0) {
                  return 'Ingresa un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                prefixIcon: Icon(Icons.description_rounded),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: _cargando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_esEdicion ? 'Actualizar' : 'Guardar'),
              onPressed: _cargando ? null : _guardar,
            ),
          ],
        ),
      ),
    );
  }
}
