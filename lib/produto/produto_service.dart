import 'dart:convert';
import 'package:flutter_application_1/produto/produto_model.dart';
import 'package:http/http.dart' as http;
import '../global.dart';


class ProdutoService {
  static Future<List<ProdutoModel>> fetchProdutos() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/produtos'),
      headers: {
        'Authorization': 'Bearer ${Global.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List produtos = jsonBody['produtos'];

      return produtos.map((p) => ProdutoModel.fromJson(p)).toList();
    } else {
      throw Exception('Erro ao buscar produtos');
    }
  }

  static Future<bool> addProduto(String nomeProduto, int idMedida) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/produtos'),
      headers: {
        "Authorization": "Bearer ${Global.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "nm_produto": nomeProduto,
        "id_medida": idMedida,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }
}

