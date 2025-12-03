class ProdutoModel {
  final int idProduto;
  final String nomeProduto;
  final double quantidadeEstoque;

  ProdutoModel({
    required this.idProduto,
    required this.nomeProduto,
    required this.quantidadeEstoque,
  });

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      idProduto: json['id_produto'],
      nomeProduto: json['nm_produto'],
      quantidadeEstoque: double.parse(json['qt_estoque']),
    );
  }
}
