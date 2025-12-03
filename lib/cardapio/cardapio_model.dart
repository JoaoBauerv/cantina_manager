class CardapioModel {
  final int idCardapio;
  final String dataCardapio;
  final List<CardapioReceitaModel> receitas;

  CardapioModel({
    required this.idCardapio,
    required this.dataCardapio,
    required this.receitas,
  });

  factory CardapioModel.fromJson(Map<String, dynamic> json) {
    return CardapioModel(
      idCardapio: json["id_cardapio"],
      dataCardapio: json["dt_cardapio"],
      receitas: (json["cardapio_receitas"] as List)
          .map((c) => CardapioReceitaModel.fromJson(c))
          .toList(),
    );
  }
}

class CardapioReceitaModel {
  final int idReceita;
  final int idCardapio;
  final double quantidadeProduzida;
  final String nomeReceita; // dentro de "receita": [{...}]

  CardapioReceitaModel({
    required this.idReceita,
    required this.idCardapio,
    required this.quantidadeProduzida,
    required this.nomeReceita,
  });

  factory CardapioReceitaModel.fromJson(Map<String, dynamic> json) {
    return CardapioReceitaModel(
      idReceita: json["id_receita"],
      idCardapio: json["id_cardapio"],
      quantidadeProduzida: double.tryParse(json["qt_produzida"].toString()) ?? 0,
      nomeReceita: json["receita"][0]["nm_receita"],
    );
  }
}
