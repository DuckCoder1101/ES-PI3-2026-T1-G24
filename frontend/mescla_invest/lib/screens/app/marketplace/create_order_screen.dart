// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/order/order.dart';
import 'package:mescla_invest/models/startup/startup.dart';

class CreateOrderScreen extends StatefulWidget {
  final String? startupId;
  final String tipo;

  const CreateOrderScreen({super.key, this.startupId, this.tipo = 'Comprar'});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  late String _tipo;

  // Startup selecionada no dropdown
  StartupModel? _startupSelecionada;
  List<StartupModel> _startups = [];
  bool _isLoadingStartups = true;

  // Quantidade e preço por token (em centavos internamente)
  final _quantidadeController = TextEditingController(text: '1');
  final _precoController = TextEditingController();

  bool _isSubmitting = false;

  int get _tokenAmount => int.tryParse(_quantidadeController.text) ?? 0;

  // Preço digitado convertido para centavos
  int get _pricePerTokenCents {
    final raw = _precoController.text.replaceAll(',', '.');
    final parsed = double.tryParse(raw) ?? 0.0;
    return (parsed * 100).round();
  }

  double get _total => (_pricePerTokenCents / 100) * _tokenAmount;

  @override
  void initState() {
    super.initState();
    _tipo = widget.tipo;
    _fetchStartups();
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  // Carrega a lista de startups para o dropdown
  Future<void> _fetchStartups() async {
    setState(() => _isLoadingStartups = true);
    try {
      final startups = await StartupModel.getStartups(
        offset: 0,
        limit: 50,
        stageFilter: StartupStageFilter.all,
        nameFilter: '',
      );

      if (mounted) {
        setState(() {
          _startups = startups;
          // Pré-seleciona a startup recebida via argumento
          if (widget.startupId != null) {
            try {
              _startupSelecionada = startups.firstWhere(
                (s) => s.id == widget.startupId,
              );
            } catch (_) {
              _startupSelecionada = startups.isNotEmpty ? startups.first : null;
            }
          }
        });
      }
    } catch (_) {
      _showSnack('Erro ao carregar startups.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingStartups = false);
    }
  }

  // Registra a ordem no balcão
  Future<void> _submitOrder() async {
    if (_startupSelecionada == null) {
      _showSnack('Selecione uma startup.', isError: true);
      return;
    }

    if (_tokenAmount <= 0) {
      _showSnack('A quantidade deve ser maior que zero.', isError: true);
      return;
    }

    if (_pricePerTokenCents <= 0) {
      _showSnack('Informe um preço válido por token.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await OrderModel.registerOrder(
        startupId: _startupSelecionada!.id,
        type: _tipo == 'Vender' ? OrderType.sell : OrderType.buy,
        pricePerTokenCents: _pricePerTokenCents,
        tokenAmount: _tokenAmount,
      );

      _showSnack('Ordem publicada com sucesso!', isError: false);

      // Retorna true para o MarketScreen recarregar a lista
      if (mounted) Navigator.pop(context, true);
    } on FirebaseFunctionsException catch (e) {
      _showSnack(e.message ?? 'Erro ao publicar ordem.', isError: true);
    } catch (_) {
      _showSnack('Erro inesperado. Tente novamente.', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : AppColors.verdeMescla,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundoEscuro,
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
                  color: AppColors.campoEscuro,
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
                              color: isSelected
                                  ? AppColors.verdeMescla
                                  : Colors.white54,
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

              // Dropdown de startup
              const Text('Startup', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.campoEscuro,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoadingStartups
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.verdeMescla,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<StartupModel>(
                          value: _startupSelecionada,
                          hint: const Text(
                            'Selecione uma startup',
                            style: TextStyle(color: Colors.white38),
                          ),
                          dropdownColor: AppColors.campoEscuro,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.verdeMescla,
                          ),
                          isExpanded: true,
                          items: _startups.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                s.name,
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

              // Quantidade de tokens
              const Text(
                'Quantidade de tokens',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      final current =
                          int.tryParse(_quantidadeController.text) ?? 1;
                      if (current > 1) {
                        _quantidadeController.text = '${current - 1}';
                        setState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.campoEscuro,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.remove, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.campoEscuro,
                        border: Border.all(color: AppColors.verdeMescla),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _quantidadeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      final current =
                          int.tryParse(_quantidadeController.text) ?? 0;
                      _quantidadeController.text = '${current + 1}';
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.verdeMescla,
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
                decoration: BoxDecoration(
                  color: AppColors.campoEscuro,
                  border: Border.all(color: AppColors.verdeMescla),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _precoController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    prefixText: 'R\$ ',
                    prefixStyle: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    hintText: '0,00',
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                  ],
                  onChanged: (_) => setState(() {}),
                ),
              ),

              const SizedBox(height: 24),

              // Resumo da ordem
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.fundoEscuro,
                  border: Border.all(
                    color: AppColors.verdeMescla.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildResumoRow(
                      'Tokens',
                      '${_tokenAmount > 0 ? _tokenAmount : "—"}',
                    ),
                    const SizedBox(height: 8),
                    _buildResumoRow(
                      'Preço/token',
                      _pricePerTokenCents > 0
                          ? 'R\$ ${(_pricePerTokenCents / 100).toStringAsFixed(2).replaceAll('.', ',')}'
                          : '—',
                    ),
                    const SizedBox(height: 8),
                    _buildResumoRow(
                      'Tipo',
                      _tipo == 'Comprar' ? 'Ordem de Compra' : 'Ordem de Venda',
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
                          _total > 0
                              ? 'R\$ ${_total.toStringAsFixed(2).replaceAll('.', ',')}'
                              : '—',
                          style: const TextStyle(
                            color: AppColors.verdeMescla,
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
                onPressed: _isSubmitting ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.verdeMescla,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor:
                      AppColors.verdeMescla.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        _tipo == 'Comprar'
                            ? 'Publicar oferta de compra'
                            : 'Publicar oferta de venda',
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
                  foregroundColor: AppColors.verdeMescla,
                  side: const BorderSide(color: AppColors.verdeMescla),
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
