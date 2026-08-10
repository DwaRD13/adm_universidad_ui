import '../app/constantes.dart';
import '../nucleo/api_cliente.dart';

/// Subida de archivos al backend y resolución de URLs de descarga.
class ArchivoServicio {
  const ArchivoServicio(this._api);

  final ApiCliente _api;

  /// Sube el archivo y devuelve la URL que después se guarda en la entrega.
  Future<String> subir(List<int> bytes, String nombreArchivo) async {
    final json =
        await _api.subirArchivo('/api/archivos', bytes, nombreArchivo)
            as Map<String, dynamic>;
    return json['url'] as String;
  }

  /// Convierte la URL guardada en una absoluta que se pueda abrir en el navegador.
  ///
  /// Los materiales del profesor suelen ser enlaces externos completos; las
  /// entregas subidas al servidor llegan como ruta relativa `/api/archivos/...`.
  static String urlAbsoluta(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${Constantes.urlBase}$url';
  }
}
