import 'package:flutter/material.dart';
import 'cardapio_model.dart';
import 'cardapio_service.dart';

class CardapioPage extends StatefulWidget {
  const CardapioPage({super.key});

  @override
  State<CardapioPage> createState() => _CardapioPageState();
}

class _CardapioPageState extends State<CardapioPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cardápios"),
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
                    "Cardapio ${c.idCardapio}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  children: c.receitas.map((r) {
                    return ListTile(
                      leading: Icon(Icons.restaurant_menu),
                      title: Text(r.nomeReceita),
                      subtitle: Text("Qtd: ${r.quantidadeProduzida}"),
                      trailing: Text("ID Receita: ${r.idReceita}"),
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
