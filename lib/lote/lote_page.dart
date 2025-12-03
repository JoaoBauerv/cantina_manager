import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/lote/lote_model.dart';
import 'package:flutter_application_1/lote/lote_service.dart';
import 'package:flutter_application_1/produto/produto_model.dart';
import 'package:flutter_application_1/produto/produto_service.dart';

class LotesPage extends StatefulWidget {
  const LotesPage({super.key});

  @override
  State<LotesPage> createState() => _LotesPageState();
}

class _LotesPageState extends State<LotesPage> {
  final LoteService _service = LoteService();
  late Future<List<Lote>> futureLotes;

  @override
  void initState() {
    super.initState();
    futureLotes = _service.fetchLotes();
  }

Future<void> _abrirBottomSheetNovoLote() async {
  DateTime? dataEntrada;
  List<ProdutoModel> produtos = await ProdutoService.fetchProdutos();

  // Produtos selecionados
  List<Map<String, dynamic>> produtosSelecionados = [];

  // Controllers por produto
  Map<int, TextEditingController> entradaCtrl = {};

  // Mapa de erros por produto
  Map<int, String?> entradaError = {};

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (contextBS) {
      return StatefulBuilder(builder: (contextSB, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(contextBS).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Novo Lote",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // DATA
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dataEntrada == null
                            ? "Selecione a data"
                            : dataEntrada.toString().split(" ")[0],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: contextBS,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setSheetState(() {
                            dataEntrada = picked;
                          });
                        }
                      },
                      child: const Text("Escolher Data"),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // PRODUTOS
                const Text(
                  "Adicionar Produtos",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                const SizedBox(height: 10),

                Column(
                  children: produtos.map((p) {
                    bool jaSelecionado = produtosSelecionados
                        .any((item) => item["id_produto"] == p.idProduto);

                    return CheckboxListTile(
                      title: Text(p.nomeProduto),
                      value: jaSelecionado,
                      onChanged: (value) {
                        setSheetState(() {
                          if (value == true) {
                            produtosSelecionados.add({
                              "id_produto": p.idProduto,
                              "qt_entrada": 0,
                              "qt_atual_lote": 0,
                              "nome": p.nomeProduto,
                            });

                            entradaCtrl[p.idProduto] =
                                TextEditingController();

                            entradaError[p.idProduto] = null;
                          } else {
                            produtosSelecionados.removeWhere((item) =>
                                item["id_produto"] == p.idProduto);
                            entradaCtrl.remove(p.idProduto);
                            entradaError.remove(p.idProduto);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),

                // CAMPOS DE QUANTIDADE
                Column(
                  children: produtosSelecionados.map((prod) {
                    int id = prod["id_produto"];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prod["nome"],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),

                        // CAMPO COM ERRO ABAIXO
                        TextField(
                          controller: entradaCtrl[id],
                          decoration: InputDecoration(
                            labelText: "Quantidade de Entrada",
                            border: const OutlineInputBorder(),
                            errorText: entradaError[id],
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, // <--- SOMENTE NÚMEROS
                          ],
                          onChanged: (_) {
                            setSheetState(() {
                              entradaError[id] = null; // limpa erro ao digitar
                            });
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                ),

                // BOTÃO SALVAR
                ElevatedButton(
                  onPressed: () async {
                    if (dataEntrada == null) {
                      ScaffoldMessenger.of(contextBS).showSnackBar(
                        const SnackBar(
                            content: Text("Selecione a data de entrada")),
                      );
                      return;
                    }

                    if (produtosSelecionados.isEmpty) {
                      ScaffoldMessenger.of(contextBS).showSnackBar(
                        const SnackBar(
                            content: Text("Selecione ao menos um produto")),
                      );
                      return;
                    }

                    // VALIDAÇÃO
                    bool valido = true;
                    entradaError.clear();

                    List<Map<String, dynamic>> produtosFinal = [];

                    for (var prod in produtosSelecionados) {
                      int id = prod["id_produto"];
                      String texto = entradaCtrl[id]!.text.trim();

                      int? entrada = int.tryParse(texto);

                      if (entrada == null || entrada <= 0) {
                        valido = false;
                        setSheetState(() {
                          entradaError[id] =
                              "Informe uma quantidade válida";
                        });
                        continue;
                      }

                      produtosFinal.add({
                        "id_produto": id,
                        "qt_entrada": entrada,
                        "qt_atual_lote": entrada,
                      });
                    }

                    if (!valido) return;

                    // ENVIA PARA API
                    bool sucesso = await _service.criarLote(
                      dataEntrada: dataEntrada!,
                      idUsuario: 1,
                      produtos: produtosFinal,
                    );

                    if (sucesso) {
                      Navigator.pop(contextBS);

                      setState(() {
                        futureLotes = _service.fetchLotes();
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Lote criado com sucesso!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Erro ao criar lote"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text("Salvar Lote"),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lotes"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _abrirBottomSheetNovoLote,
        child: const Icon(Icons.add),
      ),

      body: FutureBuilder<List<Lote>>(
        future: futureLotes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          final lotes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lotes.length,
            itemBuilder: (context, index) {
              final lote = lotes[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lote #${lote.idLote}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text("Entrada: ${lote.dataEntrada}"),

                      const SizedBox(height: 12),

                      const Text(
                        "Produtos:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),

                      const SizedBox(height: 6),

                      ...lote.produtos.map(
                        (prod) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "- ${prod.nomeProduto} (Entrada: ${prod.qtEntrada}, Atual: ${prod.qtAtual})",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
