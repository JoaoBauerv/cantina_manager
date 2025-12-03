class ReceitaModel {
  final int idReceita;
  final String nomeReceita;
  final int idMedida;
  final List<ItemReceitaModel> produtos;

  ReceitaModel({
    required this.idReceita,
    required this.nomeReceita,
    required this.idMedida,
    required this.produtos,
  });

  factory ReceitaModel.fromJson(Map<String, dynamic> json) {
    return ReceitaModel(
      idReceita: json["id_receita"],
      nomeReceita: json["nm_receita"],
      idMedida: json["id_medida"],
      produtos: (json["produtos_receita"] as List)
          .map((item) => ItemReceitaModel.fromJson(item))
          .toList(),
    );
  }
}

class ItemReceitaModel {
  final int idProduto;
  final String nomeProduto;
  final double quantidadeUsada;

  ItemReceitaModel({
    required this.idProduto,
    required this.nomeProduto,
    required this.quantidadeUsada,
  });

  factory ItemReceitaModel.fromJson(Map<String, dynamic> json) {
    return ItemReceitaModel(
      idProduto: json["id_produto"],
      nomeProduto: json["produto"]["nm_produto"],
      quantidadeUsada: double.tryParse(json["qt_usada"].toString()) ?? 0.0,
    );
  }
}
