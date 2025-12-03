import 'dart:convert';
import 'package:flutter_application_1/lote/lote_model.dart';
import 'package:http/http.dart' as http;
import '../global.dart';

class LoteService {
  Future<List<Lote>> fetchLotes() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/lotes');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${Global.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final List lotesJson = jsonBody["lotes"];

      return lotesJson.map((j) => Lote.fromJson(j)).toList();
    }

    throw Exception("Erro ao carregar lotes: ${response.statusCode}");
  }

  Future<bool> criarLote({
    required DateTime dataEntrada,
    required int idUsuario,
    required List<Map<String, dynamic>> produtos,
  }) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/lotes');

    final body = {
      "dt_entrada": dataEntrada.toIso8601String().substring(0, 10),
      "id_usuario": idUsuario,
      "produtos": produtos
    };

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${Global.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );


    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }
}
