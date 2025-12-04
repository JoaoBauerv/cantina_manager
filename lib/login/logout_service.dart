import 'package:http/http.dart' as http;
import '../global.dart';

class LogoutService {
    static Future<bool> logout(int idUsuario) async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8000/api/logout/$idUsuario"),
      headers: {
        "Authorization": "Bearer ${Global.token}",
        "Content-Type": "application/json",
      },
    );

    return response.statusCode == 200;
  }
}

