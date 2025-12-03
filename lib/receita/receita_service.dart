import 'dart:convert';
import 'package:flutter_application_1/receita/receita_model.dart';
import 'package:http/http.dart' as http;
import '../global.dart';

class ReceitaService {
  static Future<List<ReceitaModel>> fetchReceitas() async {
    final url = Uri.parse("http://10.0.2.2:8000/api/receitas");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${Global.token}',
        "Accept": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao buscar receitas");
    }

    final body = jsonDecode(response.body);
    List receitas = body["receitas"] ?? [];

    return receitas.map((r) => ReceitaModel.fromJson(r)).toList();
  }

  static Future<bool> addReceita(Map<String, dynamic> data) async {
    final url = Uri.parse("http://10.0.2.2:8000/api/receitas");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${Global.token}",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    // Sucesso (201)
    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }
}
