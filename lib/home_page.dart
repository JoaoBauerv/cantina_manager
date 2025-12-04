import 'package:flutter/material.dart';
import 'package:flutter_application_1/cardapio/cardapio_page.dart';
import 'package:flutter_application_1/global.dart';
import 'package:flutter_application_1/login/login_page.dart';
import 'package:flutter_application_1/login/logout_service.dart';
import 'package:flutter_application_1/lote/lote_page.dart';
import 'package:flutter_application_1/produto/produto_page.dart';
import 'package:flutter_application_1/produto/produto_service.dart';
import 'package:flutter_application_1/receita/receita_page.dart';

class HomePage extends StatelessWidget {
  final String usuarioLogado;
  final String token;

  const HomePage({
    super.key,
    required this.usuarioLogado,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bem-vindo,",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
            Text(
              usuarioLogado,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final sucesso = await LogoutService.logout(Global.id_usuario);

              if (sucesso) {
                Global.token = "";
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Erro ao deslogar.")),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // header

            // card dos 5 menores
            Padding(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: ProdutoService.fetchTopMenorEstoque(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text("Erro ao carregar: ${snapshot.error}"),
                      ),
                    );
                  }

                  final produtos = snapshot.data ?? [];

                  if (produtos.isEmpty) {
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text("Nenhum produto encontrado."),
                      ),
                    );
                  }

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Produtos com menor estoque",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...produtos.map((p) {
                            // acesso defensivo aos campos
                            final nome = (p['nm_produto'] ??  '').toString();
                            final qtRaw = p['qt_estoque'] ?? p['qtEstoque'] ?? '0';
                            final qtStr = qtRaw.toString();
                            final qtParsed = double.tryParse(qtStr.replaceAll(',', '.')) ?? 0.0;
                            final qtDisplay = qtParsed.toStringAsFixed(2);

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.inventory_2),
                              title: Text(nome.isNotEmpty ? nome : '—'),
                              trailing: Text(
                                qtDisplay,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: qtParsed <= 5 ? Colors.red : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // grid de botões (sem mudança)
            Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildMenuCard(
                    context,
                    title: "Produtos",
                    icon: Icons.inventory_2_outlined,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProdutosPage()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: "Lotes",
                    icon: Icons.view_module_outlined,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LotesPage()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: "Receitas",
                    icon: Icons.restaurant_menu_outlined,
                    color: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReceitasPage()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: "Cardápios",
                    icon: Icons.menu_book_outlined,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CardapioPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
