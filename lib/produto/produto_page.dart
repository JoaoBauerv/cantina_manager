import 'package:flutter/material.dart';
import 'package:flutter_application_1/produto/medida_service.dart';
import 'package:flutter_application_1/produto/produto_model.dart';
import 'package:flutter_application_1/produto/produto_service.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {

  Future<void> _abrirBottomSheetAdicionarProduto() async {
    TextEditingController nomeController = TextEditingController();
    int? idMedidaSelecionada;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (contextBottomSheet) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(contextBottomSheet).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (contextSB, setStateSheet) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Adicionar Produto",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // -------------------------
                    // CAMPO NOME COM VALIDAÇÃO
                    // -------------------------
                    TextFormField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: "Nome do Produto",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Digite o nome do produto";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // -------------------------
                    // DROPDOWN COM VALIDAÇÃO
                    // -------------------------
                    FutureBuilder<List<MedidaModel>>(
                      future: MedidaService.fetchMedidas(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final medidas = snapshot.data!;

                        return DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: "Medida",
                            border: OutlineInputBorder(),
                          ),
                          value: idMedidaSelecionada,
                          items: medidas.map((m) {
                            return DropdownMenuItem(
                              value: m.idMedida,
                              child: Text(m.nomeMedida),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setStateSheet(() {
                              idMedidaSelecionada = value;
                            });
                          },

                          validator: (value) {
                            if (value == null) {
                              return "Selecione a medida";
                            }
                            return null;
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () async {
                        // VERIFICA SE O FORM É VÁLIDO
                        if (!formKey.currentState!.validate()) {
                          return; // impede salvar
                        }

                        // CHAMA API
                        final sucesso = await ProdutoService.addProduto(
                          nomeController.text.trim(),
                          idMedidaSelecionada!,
                        );

                        if (sucesso) {
                          Navigator.pop(contextBottomSheet);
                          setState(() {});
                        } else {
                          ScaffoldMessenger.of(contextBottomSheet).showSnackBar(
                            const SnackBar(
                              content: Text("Erro ao cadastrar produto"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text("Salvar"),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Produtos"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _abrirBottomSheetAdicionarProduto,
        child: const Icon(Icons.add),
      ),

      body: FutureBuilder<List<ProdutoModel>>(
        future: ProdutoService.fetchProdutos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final produtos = snapshot.data!;

          return ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final p = produtos[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: ListTile(
                  title: Text(
                    p.nomeProduto,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Estoque: ${p.quantidadeEstoque.toStringAsFixed(2)}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
