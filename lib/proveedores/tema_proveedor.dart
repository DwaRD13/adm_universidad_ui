import 'package:flutter/material.dart';

import '../nucleo/sesion.dart';

/// Preferencia de tema del usuario, persistida en el dispositivo.
class TemaProveedor extends ChangeNotifier {
  TemaProveedor({AlmacenSesion? almacen})
    : _almacen = almacen ?? AlmacenSesion();

  final AlmacenSesion _almacen;

  ThemeMode _modo = ThemeMode.system;

  ThemeMode get modo => _modo;

  String get etiqueta => switch (_modo) {
    ThemeMode.light => 'Claro',
    ThemeMode.dark => 'Oscuro',
    ThemeMode.system => 'Automático',
  };

  Future<void> restaurar() async {
    final guardado = await _almacen.leerTema();
    _modo = switch (guardado) {
      'claro' => ThemeMode.light,
      'oscuro' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> cambiar(ThemeMode modo) async {
    if (_modo == modo) return;
    _modo = modo;
    notifyListeners();
    await _almacen.guardarTema(switch (modo) {
      ThemeMode.light => 'claro',
      ThemeMode.dark => 'oscuro',
      ThemeMode.system => 'sistema',
    });
  }
}
