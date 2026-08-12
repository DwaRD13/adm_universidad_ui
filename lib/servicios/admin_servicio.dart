import '../nucleo/api_cliente.dart';

class AdminServicio {
  final ApiCliente _cliente;

  AdminServicio(this._cliente);

  // GET
  Future<dynamic> get(String path) async {
    return await _cliente.get('/api/admin$path');
  }

  // POST
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    return await _cliente.post('/api/admin$path', body);
  }

  // PUT
  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    return await _cliente.put('/api/admin$path', body);
  }

  // DELETE
  Future<void> delete(String path) async {
    await _cliente.delete('/api/admin$path');
  }
}
