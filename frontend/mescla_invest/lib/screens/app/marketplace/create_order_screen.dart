// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/models/order_model.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';
import 'package:mescla_invest/services/order_service.dart';
import 'package:mescla_invest/services/startup_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';
import 'package:mescla_invest/widgets/layout/model_header.dart';
import 'package:mescla_invest/widgets/ui/currency_field.dart';
import 'package:mescla_invest/widgets/ui/tokens_field.dart';

class CreateOrderScreen extends StatefulWidget {
  final String? startupId;
  const CreateOrderScreen({super.key, this.startupId});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  OrderType _orderType = OrderType.buy;

  List<StartupResumeDTO> _startups = [];
  List<StartupResumeDTO> get _filteredStartups => _orderType == OrderType.buy
      ? _startups
      : _startups.where((s) => s.isInvestor).toList();

  StartupResumeDTO? _selectedStartup;
  bool _isLoadingStartups = true;
  bool _isSubmitting = false;

  final _amountController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  int get _tokenAmount => int.tryParse(_amountController.text) ?? 0;
  int get _pricePerTokenCents {
    final raw = _priceController.text.replaceAll(',', '.');
    return ((double.tryParse(raw) ?? 0.0) * 100).round();
  }

  double get _total => (_pricePerTokenCents / 100) * _tokenAmount;

  @override
  void initState() {
    super.initState();
    _fetchStartups();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _fetchStartups() async {
    setState(() => _isLoadingStartups = true);
    try {
      final startups = await StartupService.getAllStartupsResumes();
      if (!mounted) return;
      setState(() {
        _startups = startups;
        if (widget.startupId != null) {
          _selectedStartup = startups.firstWhere(
            (s) => s.id == widget.startupId,
            orElse: () => startups.first,
          );
        }
      });
    } catch (err, stack) {
      if (mounted) handleException(err: err, stack: stack, context: context);
    } finally {
      if (mounted) setState(() => _isLoadingStartups = false);
    }
  }

  Future<void> _submitOrder() async {
    if (_selectedStartup == null) {
      return showSnackbar(
        msg: 'Selecione uma startup para continuar!',
        context: context,
        isError: true,
      );
    }

    setState(() => _isSubmitting = true);
    try {
      await OrderService.registerOrder(
        startupId: _selectedStartup!.id,
        type: _orderType,
        pricePerTokenCents: _pricePerTokenCents,
        tokenAmount: _tokenAmount,
      );
      if (mounted) {
        Navigator.pop(context, true);
        showSnackbar(msg: 'Ordem publicada com sucesso!', context: context);
      }
    } catch (err, stack) {
      if (mounted) handleException(err: err, stack: stack, context: context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
              ModalHeader(title: 'NOVA ORDEM'),
              const SizedBox(height: 24),
              _OrderTypeToggle(
                selected: _orderType,
                onChanged: (t) => setState(() {
                  _selectedStartup = null;
                  _orderType = t;
                }),
              ),
              const SizedBox(height: 24),
              _StartupSelector(
                startups: _filteredStartups,
                selected: _selectedStartup,
                isLoading: _isLoadingStartups,
                onChanged: (s) => setState(() => _selectedStartup = s),
              ),
              const SizedBox(height: 24),
              TokenAmountField(
                controller: _amountController,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 24),
              CurrencyField(
                controller: _priceController,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 24),
              _OrderSummaryCard(
                tokenAmount: _tokenAmount,
                pricePerTokenCents: _pricePerTokenCents,
                orderType: _orderType,
                total: _total,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.verdeMescla,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppColors.verdeMescla.withValues(
                    alpha: 0.5,
                  ),
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
                    : const Text(
                        'Registrar ordem',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
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
}

class _OrderTypeToggle extends StatelessWidget {
  final OrderType selected;
  final void Function(OrderType) onChanged;

  const _OrderTypeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: OrderType.values.map((t) {
          final isSelected = selected == t;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(t),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2A2A2A)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  t.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? AppColors.verdeMescla : Colors.white54,
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
    );
  }
}

class _StartupSelector extends StatelessWidget {
  final List<StartupResumeDTO> startups;
  final StartupResumeDTO? selected;
  final bool isLoading;
  final void Function(StartupResumeDTO?) onChanged;

  const _StartupSelector({
    required this.startups,
    required this.selected,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Startup', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.campoEscuro,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isLoading
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
                  child: DropdownButton<StartupResumeDTO>(
                    value: selected,
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
                    items: startups
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
        ),
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final int tokenAmount;
  final int pricePerTokenCents;
  final OrderType orderType;
  final double total;

  const _OrderSummaryCard({
    required this.tokenAmount,
    required this.pricePerTokenCents,
    required this.orderType,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fundoEscuro,
        border: Border.all(color: AppColors.verdeMescla.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _row('Tokens', tokenAmount > 0 ? '$tokenAmount' : '—'),
          const SizedBox(height: 8),
          _row(
            'Preço/token',
            pricePerTokenCents > 0
                ? formatCurrency(pricePerTokenCents / 100)
                : '—',
          ),
          const SizedBox(height: 8),
          _row('Tipo', orderType.label),
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
                total > 0 ? formatCurrency(total) : '—',
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
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
