// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/models/order_model.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';
import 'package:mescla_invest/models/user/investment_model.dart';
import 'package:mescla_invest/models/user/wallet_model.dart';
import 'package:mescla_invest/services/order_service.dart';
import 'package:mescla_invest/services/startup_service.dart';
import 'package:mescla_invest/services/user_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';
import 'package:mescla_invest/widgets/shared/ui/hint_text.dart';
import 'package:mescla_invest/widgets/market/order_sumary.dart';
import 'package:mescla_invest/widgets/market/order_type_toggle.dart';
import 'package:mescla_invest/widgets/market/startup_selector.dart';
import 'package:mescla_invest/widgets/shared/layout/model_header.dart';
import 'package:mescla_invest/widgets/shared/ui/currency_field.dart';
import 'package:mescla_invest/widgets/shared/ui/tokens_field.dart';

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

  WalletModel? _wallet;
  List<InvestmentModel> _investments = [];

  /// Tokens disponíveis (desbloqueados) do usuário na startup selecionada.
  int? get _selectedStartupTokens {
    if (_selectedStartup == null) return null;
    try {
      return _investments
          .firstWhere((i) => i.startup.id == _selectedStartup!.id)
          .tokenAmount;
    } catch (_) {
      return null;
    }
  }

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
    _fetchAll();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<List<StartupResumeDTO>> _fetchStartups() async {
    final startups = await StartupService.getAllStartupsResumes();
    if (!mounted) return startups;
    setState(() {
      _startups = startups;
      if (widget.startupId != null && startups.isNotEmpty) {
        _selectedStartup = startups.firstWhere(
          (s) => s.id == widget.startupId,
          orElse: () => startups.first,
        );
      }
    });
    return startups;
  }

  Future<void> _fetchWallet() async {
    final wallet = await UserService.getWallet();
    if (!mounted) return;
    setState(() => _wallet = wallet);
  }

  Future<void> _fetchInvestments() async {
    final investments = await UserService.getUserInvestments();
    if (!mounted) return;
    setState(() => _investments = investments);
  }

  Future<void> _fetchAll() async {
    setState(() => _isLoadingStartups = true);
    try {
      await Future.wait([
        _fetchStartups(),
        _fetchWallet(),
        _fetchInvestments(),
      ]);
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
              OrderTypeToggle(
                selected: _orderType,
                onChanged: (t) => setState(() {
                  _selectedStartup = null;
                  _orderType = t;
                }),
              ),
              const SizedBox(height: 24),
              StartupSelector(
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
              if (_orderType == OrderType.sell) ...[
                const SizedBox(height: 6),
                HintText(
                  text: _selectedStartupTokens != null
                      ? 'Disponível: $_selectedStartupTokens tokens'
                      : 'Selecione uma startup para ver seus tokens',
                ),
              ],
              const SizedBox(height: 24),
              CurrencyField(
                controller: _priceController,
                onChanged: () => setState(() {}),
              ),
              if (_orderType == OrderType.buy) ...[
                const SizedBox(height: 6),
                HintText(
                  text: _wallet != null
                      ? 'Saldo disponível: ${formatCurrency(_wallet!.funds)}'
                      : 'Carregando saldo...',
                ),
              ],
              const SizedBox(height: 24),
              OrderSummaryCard(
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
