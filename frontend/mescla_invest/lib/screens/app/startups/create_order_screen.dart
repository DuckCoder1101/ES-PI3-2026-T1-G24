// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';

class CreateOrderScreen extends StatefulWidget {
  final String? startupName;
  final String tipo;

  const CreateOrderScreen({super.key, this.startupName, this.tipo = 'Comprar'});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  static const Color verdeMescla = Color(0xFF7FDD3A);

  late String _tipo;
  late String? _startupSelecionada;
  int _quantidade = 1;
  double _preco = 1.45;
  final double _saldo = 3450.00;

  final List<String> _startups = [
    'EcoTech PUC',
    'MedConnect',
    'AgriSmart',
    'BioGrid Solutions',
  ];

  @override
  void initState() {
    super.initState();
    _tipo = widget.tipo;
    _startupSelecionada = widget.startupName;
  }

  double get _total => _quantidade * _preco;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'MERCADO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Nova Oferta',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Toggle Comprar/Vender
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: ['Comprar', 'Vender'].map((t) {
                    final isSelected = _tipo == t;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tipo = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2A2A2A)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            t,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? verdeMescla : Colors.white54,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Startup
              const Text('Startup', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _startupSelecionada,
                    hint: const Text(
                      'Selecione uma startup',
                      style: TextStyle(color: Colors.white38),
                    ),
                    dropdownColor: const Color(0xFF1E1E1E),
                    icon: const Icon(Icons.arrow_drop_down, color: verdeMescla),
                    isExpanded: true,
                    items: _startups.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(
                          s,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _startupSelecionada = value),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quantidade
              const Text(
                'Quantidade de tokens',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      if (_quantidade > 1) _quantidade--;
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.remove, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        border: Border.all(color: verdeMescla),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_quantidade',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _quantidade++),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: verdeMescla,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Preço por token
              const Text(
                'Preço por token (R\$)',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  border: Border.all(color: verdeMescla),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'R\$ ${_preco.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Resumo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  border: Border.all(color: verdeMescla.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildResumoRow('Tokens', '$_quantidade'),
                    const SizedBox(height: 8),
                    _buildResumoRow(
                      'Preço/token',
                      'R\$ ${_preco.toStringAsFixed(2).replaceAll('.', ',')}',
                    ),
                    const SizedBox(height: 8),
                    _buildResumoRow(
                      'Saldo atual',
                      'R\$ ${_saldo.toStringAsFixed(2).replaceAll('.', ',')}',
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'R\$ ${_total.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            color: verdeMescla,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botão publicar
              ElevatedButton(
                onPressed: () {
                  // TODO: chamar Cloud Function
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: verdeMescla,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _tipo == 'Comprar' ? 'Publicar oferta de compra' : 'Publicar oferta de venda',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Botão cancelar
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: verdeMescla,
                  side: const BorderSide(color: verdeMescla),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumoRow(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        Text(valor, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
