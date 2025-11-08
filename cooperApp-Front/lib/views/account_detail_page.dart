import 'package:flutter/material.dart';

class AccountDetailPage extends StatefulWidget {
  const AccountDetailPage({super.key});

  @override
  State<AccountDetailPage> createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> deposits = [
    {
      'icon': Icons.attach_money,
      'name': 'Juan Perez',
      'date': '15 May 2025',
      'amount': 250.00,
    },
    {
      'icon': Icons.attach_money,
      'name': 'Maria Lopez',
      'date': '14 May 2025',
      'amount': 100.00,
    },
    {
      'icon': Icons.attach_money,
      'name': 'Carlos Ruiz',
      'date': '13 May 2025',
      'amount': 500.00,
    },
    {
      'icon': Icons.attach_money,
      'name': 'Ana Gómez',
      'date': '12 May 2025',
      'amount': 75.00,
    },
    {
      'icon': Icons.attach_money,
      'name': 'Luis Martinez',
      'date': '11 May 2025',
      'amount': 150.00,
    },
  ];

  final List<Map<String, dynamic>> withdrawals = [
    {
      'icon': Icons.money_off,
      'name': 'Juan Perez',
      'date': '10 May 2025',
      'amount': 50.00,
    },
    {
      'icon': Icons.money_off,
      'name': 'Maria Lopez',
      'date': '09 May 2025',
      'amount': 30.00,
    },
    {
      'icon': Icons.money_off,
      'name': 'Carlos Ruiz',
      'date': '08 May 2025',
      'amount': 100.00,
    },
    {
      'icon': Icons.money_off,
      'name': 'Ana Gómez',
      'date': '07 May 2025',
      'amount': 20.00,
    },
    {
      'icon': Icons.money_off,
      'name': 'Luis Martinez',
      'date': '06 May 2025',
      'amount': 10.00,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildRecord(Map<String, dynamic> record) {
    return ListTile(
      leading: Icon(record['icon'], color: Colors.green),
      title: Text(record['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(record['date']),
      trailing: Text('\$${record['amount'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta de Viaje de promoción'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Descargar historial',
            onPressed: () {
              // Aquí agregas la lógica para descargar el historial
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de descarga no implementada')),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Depósitos'),
            Tab(text: 'Retiros'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Depósitos
          ListView(
            children: [
              ...deposits.map(_buildRecord).toList(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    // Acción de depositar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función Depositar no implementada')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Depositar', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),

          // Retiros
          ListView(
            children: [
              ...withdrawals.map(_buildRecord).toList(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    // Acción de retirar (si quieres)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función Retirar no implementada')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Retirar', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}