import 'dart:convert';
import 'package:http/http.dart' as http;
import '../global.dart';
import 'cardapio_model.dart';

class CardapioService {
  static Future<List<CardapioModel>> fetchCardapios() async {
    final url = Uri.parse("http://10.0.2.2:8000/api/cardapios");

    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer ${Global.token}",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao carregar cardápios");
    }

    final data = jsonDecode(response.body);
    List lista = data["cardapios"] ?? [];

    return lista.map((c) => CardapioModel.fromJson(c)).toList();
  }
}
