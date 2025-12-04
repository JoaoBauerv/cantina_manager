class LoginResponse {
  final String token;
  final String nomeUsuario;
  final int id_usuario;

  LoginResponse({
    required this.token,
    required this.nomeUsuario,
    required this.id_usuario,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      nomeUsuario: json['user']['nm_usuario'],
      id_usuario: json['user']['id_usuario'],
    );
  }
}