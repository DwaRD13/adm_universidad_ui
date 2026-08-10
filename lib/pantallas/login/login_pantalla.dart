import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constantes.dart';
import '../../app/tema.dart';
import '../../proveedores/sesion_proveedor.dart';
import '../../widgets/comunes.dart';

/// Puerta de entrada única de la aplicación. Tras autenticar, el router decide
/// a qué panel llevar al usuario según su rol.
class LoginPantalla extends StatefulWidget {
  const LoginPantalla({super.key});

  @override
  State<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends State<LoginPantalla> {
  final _formulario = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await context.read<SesionProveedor>().iniciarSesion(
      _email.text,
      _password.text,
    );
    // La navegación la resuelve el redirect del router al cambiar la sesión.
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProveedor>();
    final colores = context.colores;

    return Scaffold(
      // Velo azul que baja desde arriba: la única superficie de la app que no es
      // plana, para que la puerta de entrada tenga presencia de marca.
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colores.primaryContainer.withValues(alpha: 0.55),
              colores.surface,
            ],
            stops: const [0, 0.45],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _formularioLogin(context, sesion, colores),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formularioLogin(
    BuildContext context,
    SesionProveedor sesion,
    ColorScheme colores,
  ) {
    return Form(
      key: _formulario,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EntradaAnimada(indice: 0, child: _Marca(colores: colores)),
          const SizedBox(height: 40),
          EntradaAnimada(
            indice: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bienvenido de vuelta',
                  style: context.textos.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Inicia sesión con tu correo institucional.',
                  style: context.textos.bodyMedium?.copyWith(
                    color: colores.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          if (sesion.expirada) ...[
            _Aviso(
              icono: Icons.info_outline_rounded,
              mensaje: 'Tu sesión expiró. Vuelve a iniciar sesión.',
              color: colores.tertiary,
            ),
            const SizedBox(height: 16),
          ],

          EntradaAnimada(
            indice: 2,
            child: TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Correo institucional',
                hintText: 'nombre.apellido@uniconnect.edu.do',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (valor) {
                final texto = valor?.trim() ?? '';
                if (texto.isEmpty) return 'Escribe tu correo.';
                if (!texto.contains('@') || !texto.contains('.')) {
                  return 'El correo no parece válido.';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          EntradaAnimada(
            indice: 3,
            child: TextFormField(
              controller: _password,
              obscureText: _ocultarPassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _entrar(),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _ocultarPassword = !_ocultarPassword),
                  icon: Icon(
                    _ocultarPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  tooltip: _ocultarPassword ? 'Mostrar' : 'Ocultar',
                ),
              ),
              validator: (valor) => (valor == null || valor.isEmpty)
                  ? 'Escribe tu contraseña.'
                  : null,
            ),
          ),

          if (sesion.error != null) ...[
            const SizedBox(height: 16),
            _Aviso(
              icono: Icons.error_outline_rounded,
              mensaje: sesion.error!,
              color: colores.error,
            ),
          ],

          const SizedBox(height: 28),
          EntradaAnimada(
            indice: 4,
            child: FilledButton(
              onPressed: sesion.procesando ? null : _entrar,
              child: sesion.procesando
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: colores.onPrimary,
                      ),
                    )
                  : const Text('Iniciar sesión'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '¿Olvidaste tu contraseña? Comunícate con el departamento administrativo.',
            textAlign: TextAlign.center,
            style: context.textos.bodySmall?.copyWith(
              color: colores.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca({required this.colores});

  final ColorScheme colores;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            // Degradado dentro de la propia familia azul: el logotipo tiene
            // volumen sin introducir un color ajeno a la paleta.
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colores.primary, colores.secondary],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colores.primary.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(Icons.school_rounded, size: 42, color: colores.onPrimary),
        ),
        const SizedBox(height: 16),
        Text(Constantes.nombreInstitucion, style: context.textos.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Portal académico',
          style: context.textos.labelSmall?.copyWith(
            color: colores.onSurfaceVariant,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}

/// Mensaje destacado dentro del formulario (error de credenciales, sesión expirada).
class _Aviso extends StatelessWidget {
  const _Aviso({
    required this.icono,
    required this.mensaje,
    required this.color,
  });

  final IconData icono;
  final String mensaje;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: context.textos.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
