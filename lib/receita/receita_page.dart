import 'package:flutter/material.dart';
import 'package:flutter_application_1/produto/medida_service.dart';
import 'package:flutter_application_1/produto/produto_model.dart';
import 'package:flutter_application_1/produto/produto_service.dart';
import 'receita_service.dart';
import 'receita_model.dart';

class ReceitasPage extends StatefulWidget {
  const ReceitasPage({super.key});

  @override
  State<ReceitasPage> createState() => _ReceitasPageState();
}

class _ReceitasPageState extends State<ReceitasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receitas"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => AddReceitaBottomSheet(
              onSaved: () => setState(() {}),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: FutureBuilder<List<ReceitaModel>>(
        future: ReceitaService.fetchReceitas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          final receitas = snapshot.data!;

          return ListView.builder(
            itemCount: receitas.length,
            itemBuilder: (context, index) {
              final receita = receitas[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ExpansionTile(
                  title: Text(
                    receita.nomeReceita,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Medida ID: ${receita.idMedida}"),
                  children: receita.produtos.map((item) {
                    return ListTile(
                      title: Text(item.nomeProduto),
                      subtitle:
                          Text("Quantidade usada: ${item.quantidadeUsada}"),
                      trailing: Text("ID: ${item.idProduto}"),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// =======================================================
// ============= BOTTOM SHEET ============================
// =======================================================

class AddReceitaBottomSheet extends StatefulWidget {
  final VoidCallback onSaved;

  AddReceitaBottomSheet({required this.onSaved});

  @override
  _AddReceitaBottomSheetState createState() => _AddReceitaBottomSheetState();
}

class _AddReceitaBottomSheetState extends State<AddReceitaBottomSheet> {
  final TextEditingController nomeCtrl = TextEditingController();

  MedidaModel? medidaSelecionada;
  ProdutoModel? produtoSelecionado;

  int? medidaIdSelecionada;
  int? produtoIdSelecionado;

  final TextEditingController quantidadeCtrl = TextEditingController();

  List<Map<String, dynamic>> produtosSelecionados = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 22,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Cadastrar Receita",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // Nome receita
            TextField(
              controller: nomeCtrl,
              decoration: const InputDecoration(
                labelText: "Nome da Receita",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // DROPDOWN MEDIDA
            FutureBuilder<List<MedidaModel>>(
              future: MedidaService.fetchMedidas(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final medidas = snapshot.data!;

                return DropdownButtonFormField<int>(
                  value: medidaIdSelecionada,
                  decoration: const InputDecoration(
                    labelText: "Medida",
                    border: OutlineInputBorder(),
                  ),
                  items: medidas
                      .map((m) => DropdownMenuItem<int>(
                            value: m.idMedida,
                            child: Text(m.nomeMedida),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      medidaIdSelecionada = value;
                      medidaSelecionada =
                          medidas.firstWhere((m) => m.idMedida == value);
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // DROPDOWN PRODUTOS + QTD + ADD
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<List<ProdutoModel>>(
                    future: ProdutoService.fetchProdutos(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return CircularProgressIndicator();

                      final produtos = snapshot.data!;

                      return DropdownButtonFormField<int>(
                        value: produtoIdSelecionado,
                        decoration: const InputDecoration(
                          labelText: "Produto",
                          border: OutlineInputBorder(),
                        ),
                        items: produtos
                            .map((p) => DropdownMenuItem<int>(
                                  value: p.idProduto,
                                  child: Text(p.nomeProduto),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            produtoIdSelecionado = value;
                            produtoSelecionado = produtos.firstWhere(
                                (p) => p.idProduto == value);
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: quantidadeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Qtd",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                IconButton(
                  icon:
                      const Icon(Icons.add_circle, color: Colors.green, size: 32),
                  onPressed: () {
                    if (produtoIdSelecionado == null ||
                        quantidadeCtrl.text.isEmpty) {
                      showSnack("Selecione produto e quantidade!", error: true);
                      return;
                    }

                    produtosSelecionados.add({
                      "id_produto": produtoIdSelecionado!,
                      "qt_usada":
                          double.tryParse(quantidadeCtrl.text) ?? 0.0,
                    });

                    produtoSelecionado = null;
                    produtoIdSelecionado = null;
                    quantidadeCtrl.clear();
                    setState(() {});
                  },
                )
              ],
            ),

            const SizedBox(height: 15),

            // LISTA PRODUTOS ADICIONADOS
            if (produtosSelecionados.isNotEmpty)
              ...produtosSelecionados.map(
                (p) => ListTile(
                  title: Text("Produto ID: ${p["id_produto"]}"),
                  subtitle: Text("Qt usada: ${p["qt_usada"]}"),
                ),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: salvarReceita,
              child: const Text("Salvar Receita"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= SALVAR RECEITA ==================

  Future<void> salvarReceita() async {
    if (nomeCtrl.text.isEmpty) {
      return showSnack("Digite o nome da receita!");
    }
    if (medidaIdSelecionada == null) {
      return showSnack("Selecione a medida!");
    }
    if (produtosSelecionados.isEmpty) {
      return showSnack("Adicione pelo menos um produto!");
    }

    final json = {
      "nm_receita": nomeCtrl.text,
      "id_medida": medidaIdSelecionada.toString(),
      "produtos": produtosSelecionados
    };

    final sucesso = await ReceitaService.addReceita(json);

    if (sucesso) {
      Navigator.pop(context);
      widget.onSaved();
    } else {
      showSnack("Erro ao cadastrar receita!", error: true);
    }
  }

  void showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.orange,
      ),
    );
  }
}
