class LoginResponse {
  final String token;
  final String nomeUsuario;

  LoginResponse({
    required this.token,
    required this.nomeUsuario,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      nomeUsuario: json['user']['nm_usuario'],
    );
  }
}