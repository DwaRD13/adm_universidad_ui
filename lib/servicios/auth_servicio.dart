import '../modelos/usuario.dart';
import '../nucleo/api_cliente.dart';

/// Resultado del login: token y usuario autenticado.
class ResultadoLogin {
  const ResultadoLogin({required this.token, required this.usuario});

  final String token;
  final Usuario usuario;
}

class AuthServicio {
  const AuthServicio(this._api);

  final ApiCliente _api;

  Future<ResultadoLogin> iniciarSesion(String email, String password) async {
    final json =
        await _api.post('/api/auth/login', {
              'email': email.trim(),
              'password': password,
            })
            as Map<String, dynamic>;

    return ResultadoLogin(
      token: json['token'] as String,
      usuario: Usuario.desdeJson(json['usuario'] as Map<String, dynamic>),
    );
  }

  /// Valida el token guardado al arrancar y refresca los datos del usuario.
  Future<Usuario> yo() async {
    final json = await _api.get('/api/auth/yo') as Map<String, dynamic>;
    return Usuario.desdeJson(json);
  }
}
