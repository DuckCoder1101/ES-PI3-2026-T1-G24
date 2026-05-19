import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/models/investment/investment.dart';
import 'package:mescla_invest/models/transaction/transaction.dart';
import 'package:mescla_invest/models/user/wallet.dart';
import 'package:mescla_invest/screens/app_root.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  WalletModel? _wallet;
  List<InvestmentModel> _investments = [];
  List<TransactionModel> _transactions = [];

  bool _isLoadingWallet = true;
  bool _isLoadingInvestments = true;
  bool _isLoadingTransactions = true;

  bool _balanceVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Carrega os três recursos em paralelo
  Future<void> _loadAll() async {
    await Future.wait([_loadWallet(), _loadInvestments(), _loadTransactions()]);
  }

  // Busca a carteira via Cloud Function getWallet
  Future<void> _loadWallet() async {
    setState(() => _isLoadingWallet = true);
    try {
      final wallet = await WalletModel.getWallet();
      if (mounted) setState(() => _wallet = wallet);
    } on FirebaseFunctionsException catch (e) {
      _showSnack(e.message ?? 'Erro ao carregar carteira.', isError: true);
    } catch (_) {
      _showSnack('Erro ao carregar carteira.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingWallet = false);
    }
  }

  // Busca os investimentos do usuário via Cloud Function getUserInvestments
  Future<void> _loadInvestments() async {
    setState(() => _isLoadingInvestments = true);
    try {
      final investments = await InvestmentModel.getUserInvestments();
      if (mounted) setState(() => _investments = investments);
    } on FirebaseFunctionsException catch (e) {
      _showSnack('Erro ao carregar investimentos ${e.message}.', isError: true);
    } catch (err) {
      debugPrint("Erro ao carregar investimentos: $err");
      _showSnack('Erro ao carregar investimentos.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingInvestments = false);
    }
  }

  // Busca o histórico de transações via Cloud Function getUserTransactions
  Future<void> _loadTransactions() async {
    setState(() => _isLoadingTransactions = true);
    try {
      final txs = await TransactionModel.getUserTransactions();
      if (mounted) setState(() => _transactions = txs);
    } on FirebaseFunctionsException catch (e) {
      _showSnack('Erro ao carregar transações: ${e.message}.', isError: true);
    } catch (err) {
      debugPrint("Erro ao carregar transações: $err");
      _showSnack('Erro ao carregar transações.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingTransactions = false);
    }
  }

  // Abre o sheet de adição de saldo fictício
  void _showAddFundsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.campoEscuro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddFundsSheet(
        onSuccess: () async {
          await _loadWallet();
          await _loadTransactions();
          _showSnack('Saldo adicionado com sucesso!');
        },
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.redAccent : AppColors.verdeMescla,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: NestedScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),

        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Card de saldo
            SliverToBoxAdapter(child: _buildBalanceCard()),

            // TabBar fixa no topo
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.verdeMescla,
                  indicatorWeight: 2,
                  labelColor: AppColors.verdeMescla,
                  unselectedLabelColor: Colors.white38,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Investimentos'),
                    Tab(text: 'Histórico'),
                  ],
                ),
              ),
            ),
          ];
        },

        // Conteúdo das abas
        body: TabBarView(
          controller: _tabController,
          children: [_buildInvestmentsTab(), _buildHistoryTab()],
        ),
      ),
    );
  }

  // Card de saldo

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2E1A), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.verdeMescla.withValues(alpha: 0.2)),
      ),
      child: _isLoadingWallet
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: AppColors.verdeMescla),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + toggle visibilidade
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MINHA CARTEIRA',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _balanceVisible = !_balanceVisible),
                      child: Icon(
                        _balanceVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white38,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Saldo total com animação de ocultação
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _balanceVisible
                        ? formatCurrency(_wallet?.totalFunds ?? 0)
                        : 'R\$ ••••••',
                    key: ValueKey(_balanceVisible),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Chips de disponível e bloqueado
                Row(
                  children: [
                    Expanded(
                      child: _buildBalanceChip(
                        label: 'Disponível',
                        value: _balanceVisible
                            ? formatCurrency(_wallet?.funds ?? 0)
                            : '••••',
                        color: AppColors.verdeMescla,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBalanceChip(
                        label: 'Bloqueado',
                        value: _balanceVisible
                            ? formatCurrency(_wallet?.lockedFunds ?? 0)
                            : '••••',
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Botão adicionar fundos
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showAddFundsModal,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Adicionar fundos'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.verdeMescla,
                      side: const BorderSide(color: AppColors.verdeMescla),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBalanceChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.fundoEscuro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Investimentos

  Widget _buildInvestmentsTab() {
    if (_isLoadingInvestments) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.verdeMescla),
      );
    }

    if (_investments.isEmpty) {
      return _buildEmpty(
        icon: Icons.rocket_launch_outlined,
        message: 'Você ainda não investiu em nenhuma startup.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      color: AppColors.verdeMescla,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _investments.length,
        itemBuilder: (_, i) => _buildInvestmentCard(_investments[i]),
      ),
    );
  }

  Widget _buildInvestmentCard(InvestmentModel inv) {
    // Proporção de tokens disponíveis sobre o total
    final availablePct = inv.totalTokens > 0
        ? inv.tokenAmount / inv.totalTokens
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID da startup + badge de total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  inv.startup.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.verdeMescla.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${inv.totalTokens} tokens',
                  style: const TextStyle(
                    color: AppColors.verdeMescla,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Barra de proporção disponível vs bloqueado
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: availablePct,
              backgroundColor: Colors.redAccent.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.verdeMescla,
              ),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 10),

          // Chips de disponível e bloqueado
          Row(
            children: [
              _buildTokenChip(
                label: 'Disponível',
                value: inv.tokenAmount,
                color: AppColors.verdeMescla,
              ),

              if (inv.lockedTokenAmount > 0) ...[
                const SizedBox(width: 16),
                _buildTokenChip(
                  label: 'Bloqueado',
                  value: inv.lockedTokenAmount,
                  color: Colors.white38,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenChip({
    required String label,
    required int value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$value $label', style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  // Histórico

  Widget _buildHistoryTab() {
    if (_isLoadingTransactions) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.verdeMescla),
      );
    }

    if (_transactions.isEmpty) {
      return _buildEmpty(
        icon: Icons.receipt_long_outlined,
        message: 'Nenhuma transação registrada.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      color: AppColors.verdeMescla,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _transactions.length,
        itemBuilder: (_, i) => _buildTransactionCard(_transactions[i]),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel tx) {
    final uid = authUserDataProvider.value?.uid ?? '';

    final IconData icon;
    final Color iconColor;
    final String title;
    final String subtitle;
    final bool isPositive;

    switch (tx.type) {
      case TransactionType.funds:
        icon = Icons.add_card_rounded;
        iconColor = Colors.greenAccent;
        title = 'Depósito';
        subtitle = 'Adição de saldo fictício';
        isPositive = true;

      case TransactionType.investment:
        final t = tx as InvestmentTransactionModel;
        icon = Icons.rocket_launch_rounded;
        iconColor = AppColors.verdeMescla;
        title = 'Compra direta — ${t.startup.name}';
        subtitle =
            '${t.tokensPurchased} tokens × ${formatCurrency(t.tokenPrice)}';
        isPositive = false;

      case TransactionType.trade:
        final t = tx as TradeTransactionModel;
        final isBuyer = t.purchaserUId == uid;

        icon = isBuyer
            ? Icons.trending_up_rounded
            : Icons.trending_down_rounded;

        iconColor = isBuyer ? AppColors.verdeMescla : Colors.orangeAccent;
        title = isBuyer
            ? 'Compra no balcão — ${t.startupId}'
            : 'Venda no balcão — ${t.startupId}';
        subtitle =
            '${t.tokensPurchased} tokens × ${formatCurrency(t.tokenPrice)}';
        isPositive = !isBuyer;
    }

    final formattedDate = formatDate(tx.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Ícone do tipo de transação
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),

          const SizedBox(width: 12),

          // Título, subtítulo e data
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Valor com sinal
          Text(
            '${isPositive ? '+' : '-'} ${formatCurrency(tx.amount)}',
            style: TextStyle(
              color: isPositive ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // Helpers

  Widget _buildEmpty({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white24, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// Sheet de adição de fundos

class _AddFundsSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  const _AddFundsSheet({required this.onSuccess});

  @override
  State<_AddFundsSheet> createState() => _AddFundsSheetState();
}

class _AddFundsSheetState extends State<_AddFundsSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _controller.text.replaceAll(',', '.');
    final value = double.tryParse(raw) ?? 0;

    if (value < 10) {
      setState(() => _error = 'O valor mínimo é R\$ 10,00.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await WalletModel.addFunds(value);
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        setState(() => _error = e.message ?? 'Erro ao adicionar fundos.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Erro inesperado. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Adicionar fundos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Simulação — nenhum valor real será cobrado. Mínimo: R\$ 10,00.',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: 'R\$ ',
              prefixStyle: const TextStyle(
                color: AppColors.verdeMescla,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              hintText: '0,00',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 28),
              errorText: _error,
              errorStyle: const TextStyle(color: Colors.redAccent),
              border: InputBorder.none,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white12),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.verdeMescla, width: 2),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),

          const SizedBox(height: 24),

          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.verdeMescla,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Text(
                    'Confirmar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.fundoEscuro, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}
