import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_view_model.dart';
import '../models/account_model.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  final String userName;

  const HomePage({super.key, this.userName = 'Usuario'});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        drawer: const AppDrawer(),
        backgroundColor: const Color(0xFFFFFCF5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Consumer<HomeViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      Text(
                        'Hola, $userName',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        "Cuentas donde soy dueño",
                        viewModel.ownerAccounts,
                        context,
                        isOwner: true,
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        "Cuentas donde soy miembro",
                        viewModel.memberAccounts,
                        context,
                        isOwner: false,
                      ),
                      const SizedBox(height: 30),
                      _buildSuggestionBox(context),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        Image.asset(
          'assets/images/ardillas.png',
          height: 60,
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.green),
          onPressed: () {
            Provider.of<HomeViewModel>(context, listen: false).loadAccounts();
          },
        ),
      ],
    );
  }

  Widget _buildSection(
      String title, List<AccountModel> accounts, BuildContext context,
      {required bool isOwner}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 10),
        if (accounts.isEmpty)
          Text(
            'No tienes cuentas en esta categoría.',
            style: TextStyle(color: Colors.grey.shade700),
          )
        else
          ...accounts.map((acc) => GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                isOwner ? '/accountDueno' : '/accountMiembro',
                arguments: acc,
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    acc.nombreCuenta,
                    style:
                    const TextStyle(fontSize: 18, color: Colors.brown),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${acc.moneda} ${acc.saldo.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Estado: ${acc.estado}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tipo: ${acc.tipo}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          )),
      ],
    );
  }

  Widget _buildSuggestionBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿No sabes cómo ahorrar?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '¡Te ayudamos!',
            style: TextStyle(fontSize: 16, color: Colors.brown),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/aiAssistant');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              '¡AhorraYa!',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
