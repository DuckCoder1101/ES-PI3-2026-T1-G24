// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';
import 'package:mescla_invest/screens/app/startups/create_order_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  static const Color verdeMescla = Color(0xFF7FDD3A);
  String _activeTab = 'Compra';

  final List<Map<String, dynamic>> _ofertasCompra = [
    {'startup': 'EcoTech PUC', 'quantidade': 50, 'preco': 1.45},
    {'startup': 'MedConnect', 'quantidade': 30, 'preco': 0.75},
    {'startup': 'EcoTech PUC', 'quantidade': 100, 'preco': 1.40},
    {'startup': 'AgriSmart', 'quantidade': 200, 'preco': 2.10},
  ];

  final List<Map<String, dynamic>> _ofertasVenda = [
    {'startup': 'EcoTech PUC', 'quantidade': 20, 'preco': 1.60},
    {'startup': 'AgriSmart', 'quantidade': 80, 'preco': 2.30},
  ];

  final List<Map<String, dynamic>> _minhasOrdens = [
    {'startup': 'MedConnect', 'quantidade': 15, 'preco': 0.80, 'tipo': 'Compra'},
    {'startup': 'EcoTech PUC', 'quantidade': 10, 'preco': 1.50, 'tipo': 'Venda'},
  ];

  void _navegarParaCriarOferta({String? startupName, String tipo = 'Comprar'}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateOrderScreen(
          startupName: startupName,
          tipo: tipo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Olá, usuário',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _navegarParaCriarOferta(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: verdeMescla,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '+ Oferta',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.notifications_outlined,
                          color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),

            // Toggle abas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: ['Compra', 'Venda', 'Minhas Ordens'].map((tab) {
                    final isSelected = _activeTab == tab;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = tab),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2A2A2A)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tab,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? verdeMescla : Colors.white54,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _activeTab == 'Compra'
                      ? 'OFERTAS DE COMPRA ABERTAS'
                      : _activeTab == 'Venda'
                          ? 'OFERTAS DE VENDA ABERTAS'
                          : 'MINHAS ORDENS',
                  style: const TextStyle(
                    color: verdeMescla,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Lista
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _activeTab == 'Compra'
                    ? _ofertasCompra.length
                    : _activeTab == 'Venda'
                        ? _ofertasVenda.length
                        : _minhasOrdens.length,
                itemBuilder: (context, index) {
                  final oferta = _activeTab == 'Compra'
                      ? _ofertasCompra[index]
                      : _activeTab == 'Venda'
                          ? _ofertasVenda[index]
                          : _minhasOrdens[index];

                  return GestureDetector(
                    onTap: () => _navegarParaCriarOferta(
                      startupName: oferta['startup'],
                      tipo: _activeTab == 'Venda' ? 'Vender' : 'Comprar',
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                oferta['startup'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Qtd: ${oferta['quantidade']} tokens',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'R\$ ${oferta['preco'].toStringAsFixed(2).replaceAll('.', ',')}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Text(
                                    '/token',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: verdeMescla,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _activeTab == 'Compra' ? 'Vender' : 'Comprar',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}