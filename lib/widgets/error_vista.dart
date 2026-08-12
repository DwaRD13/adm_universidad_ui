import 'package:flutter/material.dart';

class ErrorVista extends StatelessWidget {
  final String mensaje;
  final VoidCallback? alReintentar;

  const ErrorVista({Key? key, required this.mensaje, this.alReintentar})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            mensaje,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (alReintentar != null)
            ElevatedButton(
              onPressed: alReintentar,
              child: const Text('Reintentar'),
            ),
        ],
      ),
    );
  }
}
