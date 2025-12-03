import 'dart:convert';
import 'package:http/http.dart' as http;
import '../global.dart';

class MedidaModel {
  final int idMedida;
  final String nomeMedida;

  MedidaModel({required this.idMedida, required this.nomeMedida});

  factory MedidaModel.fromJson(Map<String, dynamic> json) {
    return MedidaModel(
      idMedida: json['id_medida'],
      nomeMedida: json['nm_medida'],
    );
  }
}

class MedidaService {
  static Future<List<MedidaModel>> fetchMedidas() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8000/api/medidas"),
      headers: {
        'Authorization': 'Bearer ${Global.token}',
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);
    final List medidas = data["medidas"];

    return medidas.map((m) => MedidaModel.fromJson(m)).toList();
  }
}
