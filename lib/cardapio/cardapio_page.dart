import 'package:flutter/material.dart';
import 'cardapio_model.dart';
import 'cardapio_service.dart';
import '../receita/receita_service.dart';
import '../receita/receita_model.dart';

class CardapioPage extends StatefulWidget {
  const CardapioPage({super.key});

  @override
  State<CardapioPage> createState() => _CardapioPageState();
}

class _CardapioPageState extends State<CardapioPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cardápios")),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _abrirBottomSheetNovoCardapio(context),
      ),

      body: FutureBuilder<List<CardapioModel>>(
        future: CardapioService.fetchCardapios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          final cardapios = snapshot.data!;

          return ListView.builder(
            itemCount: cardapios.length,
            itemBuilder: (context, index) {
              final c = cardapios[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                child: ExpansionTile(
                  title: Text(
                    "Cardápio ${c.idCardapio}",
                    style: const TextStyle(fontSize: 18),
                  ),

                  children: c.receitas.map((r) {
                    return ListTile(
                      leading: const Icon(Icons.restaurant_menu),
                      title: Text(r.nomeReceita),
                      subtitle: Text("Qtd produzida: ${r.quantidadeProduzida}"),
                      trailing: Text("ID: ${r.idReceita}"),
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

  // -----------------------------------------------------------
  // BOTTOM SHEET PARA CRIAR UM NOVO CARDÁPIO
  // -----------------------------------------------------------
  void _abrirBottomSheetNovoCardapio(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => NovoCardapioSheet(onCreated: () {
        setState(() {}); // atualizar lista após criar cardápio
      }),
    );
  }
}

// ===================================================================
// BOTTOM SHEET DE CADASTRO DE CARDÁPIO
// ===================================================================
class NovoCardapioSheet extends StatefulWidget {
  final VoidCallback onCreated;

  const NovoCardapioSheet({super.key, required this.onCreated});

  @override
  State<NovoCardapioSheet> createState() => _NovoCardapioSheetState();
}

class _NovoCardapioSheetState extends State<NovoCardapioSheet> {
  int? receitaSelecionadaId;
  final qtController = TextEditingController();

  // LISTA DE RECEITAS ADICIONADAS
  List<Map<String, dynamic>> receitasAdicionadas = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Novo Cardápio",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            //--------------------------------------------------------------------
            // DROPDOWN DE RECEITAS
            //--------------------------------------------------------------------
            FutureBuilder<List<ReceitaModel>>(
              future: ReceitaService.fetchReceitas(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final receitas = snapshot.data!;

                return DropdownButtonFormField<int>(
                  hint: const Text("Selecione a Receita"),
                  value: receitaSelecionadaId,
                  items: receitas.map((r) {
                    return DropdownMenuItem<int>(
                      value: r.idReceita,
                      child: Text(r.nomeReceita),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      receitaSelecionadaId = value;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            //--------------------------------------------------------------------
            // QUANTIDADE
            //--------------------------------------------------------------------
            TextField(
              controller: qtController,
              decoration: const InputDecoration(
                labelText: "Quantidade Produzida",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 15),

            // BOTÃO DE ADICIONAR RECEITA AO CARDÁPIO
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Adicionar Receita"),
              onPressed: _adicionarReceita,
            ),

            const SizedBox(height: 20),

            //--------------------------------------------------------------------
            // LISTA DE RECEITAS ADICIONADAS
            //--------------------------------------------------------------------
            if (receitasAdicionadas.isNotEmpty)
              Column(
                children: receitasAdicionadas.map((rec) {
                  return Card(
                    child: ListTile(
                      title: Text("Receita ID: ${rec['id_receita']}"),
                      subtitle: Text("Qtd produzida: ${rec['qt_produzida']}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            receitasAdicionadas.remove(rec);
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            // BOTÃO FINAL
            ElevatedButton(
              onPressed: _salvarCardapio,
              child: const Text("Salvar Cardápio"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // ADICIONAR RECEITA À LISTA
  // -----------------------------------------------------------
  void _adicionarReceita() {
    if (receitaSelecionadaId == null || qtController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione uma receita e informe a quantidade!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    receitasAdicionadas.add({
      "id_receita": receitaSelecionadaId!,
      "qt_produzida": double.parse(qtController.text),
    });

    receitaSelecionadaId = null;
    qtController.clear();

    setState(() {});
  }

  // -----------------------------------------------------------
  // SALVAR CARDÁPIO COMPLETO
  // -----------------------------------------------------------
  Future<void> _salvarCardapio() async {
    if (receitasAdicionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Adicione pelo menos uma receita!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // JSON FINAL
    final json = {
      "dt_cardapio": DateTime.now().toIso8601String().substring(0, 10),
      "receitas": receitasAdicionadas,
    };

    final success = await CardapioService.addCardapio(json);

    if (success) {
      Navigator.pop(context);
      widget.onCreated();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cardápio criado com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao criar cardápio."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
