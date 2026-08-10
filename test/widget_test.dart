import 'package:adm_universidad_ui/nucleo/formato.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('Formato.iniciales', () {
    test('toma la primera letra del nombre y del apellido', () {
      expect(Formato.iniciales('Ana Martínez'), 'AM');
      expect(Formato.iniciales('Julio César Encarnación'), 'JE');
    });

    test('funciona con un solo nombre y con texto vacío', () {
      expect(Formato.iniciales('Ana'), 'A');
      expect(Formato.iniciales('   '), '?');
    });
  });

  group('Formato.porcentaje', () {
    test('omite los decimales cuando el valor es entero', () {
      expect(Formato.porcentaje(92), '92%');
      expect(Formato.porcentaje(92.5), '92.5%');
    });

    test('muestra un guion cuando no hay dato', () {
      expect(Formato.porcentaje(null), '—');
    });
  });

  group('Formato.tiempoRestante', () {
    test('distingue entre una fecha futura y una vencida', () {
      final futura = DateTime.now().add(const Duration(days: 3));
      final pasada = DateTime.now().subtract(const Duration(days: 2));

      expect(Formato.tiempoRestante(futura), contains('Vence en'));
      expect(Formato.tiempoRestante(pasada), contains('Venció'));
    });
  });

  group('Formato.nota', () {
    test('siempre usa dos decimales', () {
      expect(Formato.nota(92.5), '92.50');
      expect(Formato.nota(null), '—');
    });
  });
}
