import 'package:intl/intl.dart';

/// Formato de fechas, notas y textos. Todo en español dominicano.
class Formato {
  const Formato._();

  static final DateFormat _fechaCorta = DateFormat('d MMM yyyy', 'es');
  static final DateFormat _fechaLarga = DateFormat(
    "d 'de' MMMM 'de' yyyy",
    'es',
  );
  static final DateFormat _fechaHora = DateFormat("d MMM, h:mm a", 'es');
  static final DateFormat _soloHora = DateFormat('h:mm a', 'es');
  static final DateFormat _diaSemana = DateFormat('EEEE', 'es');

  static String fecha(DateTime? valor) =>
      valor == null ? '—' : _capitalizar(_fechaCorta.format(valor));

  static String fechaLarga(DateTime? valor) =>
      valor == null ? '—' : _capitalizar(_fechaLarga.format(valor));

  static String fechaHora(DateTime? valor) =>
      valor == null ? '—' : _capitalizar(_fechaHora.format(valor));

  static String hora(DateTime? valor) =>
      valor == null ? '—' : _soloHora.format(valor);

  static String diaSemana(DateTime valor) =>
      _capitalizar(_diaSemana.format(valor));

  /// Nota con dos decimales, o un guion cuando aún no hay calificación.
  static String nota(num? valor) =>
      valor == null ? '—' : valor.toStringAsFixed(2);

  /// Porcentaje sin decimales innecesarios: 92.0 -> "92%", 92.5 -> "92.5%".
  static String porcentaje(num? valor) {
    if (valor == null) return '—';
    final texto = valor % 1 == 0
        ? valor.toStringAsFixed(0)
        : valor.toStringAsFixed(1);
    return '$texto%';
  }

  /// Distancia hasta una fecha, en lenguaje natural: "Vence en 3 días".
  static String tiempoRestante(DateTime limite) {
    final diferencia = limite.difference(DateTime.now());

    if (diferencia.isNegative) {
      final pasado = diferencia.abs();
      if (pasado.inDays >= 1) {
        return 'Venció hace ${pasado.inDays} ${pasado.inDays == 1 ? 'día' : 'días'}';
      }
      if (pasado.inHours >= 1) {
        return 'Venció hace ${pasado.inHours} h';
      }
      return 'Venció hace un momento';
    }

    if (diferencia.inDays >= 1) {
      return 'Vence en ${diferencia.inDays} ${diferencia.inDays == 1 ? 'día' : 'días'}';
    }
    if (diferencia.inHours >= 1) {
      return 'Vence en ${diferencia.inHours} h';
    }
    return 'Vence en ${diferencia.inMinutes} min';
  }

  /// Marca de tiempo relativa para la lista de conversaciones.
  static String relativo(DateTime? valor) {
    if (valor == null) return '';
    final ahora = DateTime.now();
    final diferencia = ahora.difference(valor);

    if (diferencia.inMinutes < 1) return 'Ahora';
    if (diferencia.inHours < 1) return 'Hace ${diferencia.inMinutes} min';
    if (_mismoDia(valor, ahora)) return _soloHora.format(valor);
    if (diferencia.inDays < 7) return _capitalizar(_diaSemana.format(valor));
    return _fechaCorta.format(valor);
  }

  /// Iniciales para los avatares: "Ana Martínez" -> "AM".
  static String iniciales(String nombreCompleto) {
    final partes = nombreCompleto.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1))
        .toUpperCase();
  }

  static bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _capitalizar(String texto) =>
      texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
}
