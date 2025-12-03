class ProdutoDoLote {
  final int idProduto;
  final int qtEntrada;
  final int qtAtual;
  final String nomeProduto;

  ProdutoDoLote({
    required this.idProduto,
    required this.qtEntrada,
    required this.qtAtual,
    required this.nomeProduto,
  });

  factory ProdutoDoLote.fromJson(Map<String, dynamic> json) {
    return ProdutoDoLote(
      idProduto: json["id_produto"],
      qtEntrada: json["qt_entrada"],
      qtAtual: json["qt_atual_lote"],
      nomeProduto: json["produto"]["nm_produto"],
    );
  }
}

class Lote {
  final int idLote;
  final String dataEntrada;
  final List<ProdutoDoLote> produtos;

  Lote({
    required this.idLote,
    required this.dataEntrada,
    required this.produtos,
  });

  factory Lote.fromJson(Map<String, dynamic> json) {
    return Lote(
      idLote: json["id_lote"],
      dataEntrada: json["dt_entrada"],
      produtos: (json["produtos_lote"] as List)
          .map((p) => ProdutoDoLote.fromJson(p))
          .toList(),
    );
  }
}
