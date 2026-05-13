/*
 * Tela de Carteira - Mescla Invest
 * Exibe saldo, investimentos por startup e histórico de transações.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Importar os models do projeto:
// import '../../../models/investment/investment_model.dart';
// import '../../../models/transaction/transaction_model.dart';

// ─────────────────────────────────────────────
//  CORES DO PROJETO (replicadas do catálogo)
// ─────────────────────────────────────────────
const _bg = Color(0xFF0D0D0D);
const _surface = Color(0xFF1A1A1A);
const _surfaceAlt = Color(0xFF222222);
const _green = Color(0xFF39FF14);
const _greenDim = Color(0xFF1A6600);
const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFF8A8A8A);
const _red = Color(0xFFFF4444);

// ─────────────────────────────────────────────
//  MOCK DATA (remover quando integrar Firebase)
// ─────────────────────────────────────────────
class _MockWallet {
  final int fundsCents;
  final int lockedFundsCents;
  double get funds => fundsCents / 100;
  double get lockedFunds => lockedFundsCents / 100;
  double get totalFunds => (fundsCents + lockedFundsCents) / 100;
  _MockWallet({required this.fundsCents, required this.lockedFundsCents});
}

class _MockInvestment {
  final String startupId;
  final String startupName;
  final int tokenAmount;
  final int lockedTokenAmount;
  int get totalTokens => tokenAmount + lockedTokenAmount;
  _MockInvestment({
    required this.startupId,
    required this.startupName,
    required this.tokenAmount,
    required this.lockedTokenAmount,
  });
}

enum _TxType { investment, funds, trade }

class _MockTransaction {
  final String id;
  final _TxType type;
  final int amountCents;
  final DateTime createdAt;
  final String? startupName;
  final int? tokensPurchased;
  double get amount => amountCents / 100;
  _MockTransaction({
    required this.id,
    required this.type,
    required this.amountCents,
    required this.createdAt,
    this.startupName,
    this.tokensPurchased,
  });
}

// ─────────────────────────────────────────────
//  WALLET SCREEN
// ─────────────────────────────────────────────
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  bool _balanceVisible = true;

  late _MockWallet _wallet;
  late List<_MockInvestment> _investments;
  late List<_MockTransaction> _transactions;

  late TabController _tabController;

  // Controlador para o campo de adicionar fundos
  final _fundsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    // ── Substituir pelo Firebase real: ──
    // _wallet = await WalletModel.getWallet();
    // _investments = ...
    // _transactions = await TransactionModel.getUserTransactions();

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _wallet = _MockWallet(fundsCents: 153750, lockedFundsCents: 20000);

      _investments = [
        _MockInvestment(
          startupId: 's1',
          startupName: 'QuantumSec',
          tokenAmount: 120,
          lockedTokenAmount: 30,
        ),
        _MockInvestment(
          startupId: 's2',
          startupName: 'AgroAI',
          tokenAmount: 50,
          lockedTokenAmount: 0,
        ),
        _MockInvestment(
          startupId: 's3',
          startupName: 'MedChain',
          tokenAmount: 200,
          lockedTokenAmount: 100,
        ),
      ];

      _transactions = [
        _MockTransaction(
          id: 't1',
          type: _TxType.investment,
          amountCents: 30000,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          startupName: 'QuantumSec',
          tokensPurchased: 30,
        ),
        _MockTransaction(
          id: 't2',
          type: _TxType.funds,
          amountCents: 100000,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        _MockTransaction(
          id: 't3',
          type: _TxType.trade,
          amountCents: 5000,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          startupName: 'AgroAI',
          tokensPurchased: 10,
        ),
        _MockTransaction(
          id: 't4',
          type: _TxType.investment,
          amountCents: 50000,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          startupName: 'MedChain',
          tokensPurchased: 100,
        ),
        _MockTransaction(
          id: 't5',
          type: _TxType.funds,
          amountCents: 200000,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];

      _loading = false;
    });
  }

  void _showAddFundsSheet() {
    _fundsController.clear();
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _textSecondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Adicionar fundos',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Valor mínimo: R\$ 10,00',
              style: TextStyle(color: _textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _fundsController,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                prefixText: 'R\$ ',
                prefixStyle: const TextStyle(
                  color: _green,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                hintText: '0,00',
                hintStyle: TextStyle(
                  color: _textSecondary.withValues(alpha: 0.5),
                  fontSize: 28,
                ),
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: _textSecondary.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: _green, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Integrar: WalletModel.addFunds(double.parse(...))
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Fundos adicionados com sucesso!'),
                      backgroundColor: _greenDim,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays == 1) return 'ontem';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Widget _txIcon(_TxType type) {
    IconData icon;
    Color color;
    Color bg;
    switch (type) {
      case _TxType.funds:
        icon = Icons.add_circle_outline_rounded;
        color = _green;
        bg = _greenDim.withValues(alpha: 0.4);
        break;
      case _TxType.investment:
        icon = Icons.rocket_launch_rounded;
        color = const Color(0xFF4FC3F7);
        bg = const Color(0xFF0D2A35);
        break;
      case _TxType.trade:
        icon = Icons.swap_horiz_rounded;
        color = const Color(0xFFFFB74D);
        bg = const Color(0xFF2A1A00);
        break;
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color, size: 22),
    );
  }

  String _txLabel(_MockTransaction tx) {
    switch (tx.type) {
      case _TxType.funds:
        return 'Depósito';
      case _TxType.investment:
        return 'Investimento • ${tx.startupName ?? ''}';
      case _TxType.trade:
        return 'Negociação • ${tx.startupName ?? ''}';
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _loading ? _buildLoading() : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: _green, strokeWidth: 2),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Column(
        children: [
          // ── Header com saldo ──────────────────────────────────
          _buildBalanceCard(),

          // ── Tabs ──────────────────────────────────────────────
          Container(
            color: _bg,
            child: TabBar(
              controller: _tabController,
              indicatorColor: _green,
              indicatorWeight: 2,
              labelColor: _green,
              unselectedLabelColor: _textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Investimentos'),
                Tab(text: 'Histórico'),
              ],
            ),
          ),

          // ── Tab content ───────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInvestmentsTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _greenDim.withValues(alpha: 0.6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + toggle visibilidade
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Minha Carteira',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                child: Icon(
                  _balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Saldo total
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _balanceVisible
                  ? _formatCurrency(_wallet.totalFunds)
                  : 'R\$ ••••••',
              key: ValueKey(_balanceVisible),
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Disponível / Bloqueado
          Row(
            children: [
              Expanded(
                child: _buildBalanceChip(
                  label: 'Disponível',
                  value: _balanceVisible
                      ? _formatCurrency(_wallet.funds)
                      : '••••',
                  color: _green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBalanceChip(
                  label: 'Bloqueado',
                  value: _balanceVisible
                      ? _formatCurrency(_wallet.lockedFunds)
                      : '••••',
                  color: _textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botão adicionar fundos
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddFundsSheet,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Adicionar fundos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _green,
                side: const BorderSide(color: _greenDim),
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
        color: _surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: _textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentsTab() {
    if (_investments.isEmpty) {
      return _buildEmpty(
        icon: Icons.rocket_launch_outlined,
        message: 'Você ainda não investiu em nenhuma startup.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _investments.length,
      itemBuilder: (_, i) => _buildInvestmentCard(_investments[i]),
    );
  }

  Widget _buildInvestmentCard(_MockInvestment inv) {
    final availablePct =
        inv.totalTokens > 0 ? inv.tokenAmount / inv.totalTokens : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome + total tokens
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                inv.startupName,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _greenDim.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${inv.totalTokens} tokens',
                  style: const TextStyle(
                    color: _green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Barra de disponível vs bloqueado
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: availablePct,
              backgroundColor: _red.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(_green),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _tokenChip(
                label: 'Disponível',
                value: inv.tokenAmount,
                color: _green,
              ),
              const SizedBox(width: 12),
              if (inv.lockedTokenAmount > 0)
                _tokenChip(
                  label: 'Bloqueado',
                  value: inv.lockedTokenAmount,
                  color: _textSecondary,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tokenChip({
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
        Text(
          '$value $label',
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    if (_transactions.isEmpty) {
      return _buildEmpty(
        icon: Icons.receipt_long_outlined,
        message: 'Nenhuma transação encontrada.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _transactions.length,
      itemBuilder: (_, i) => _buildTransactionTile(_transactions[i]),
    );
  }

  Widget _buildTransactionTile(_MockTransaction tx) {
    final isFunds = tx.type == _TxType.funds;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _txIcon(tx.type),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _txLabel(tx),
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _formatDate(tx.createdAt),
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (tx.tokensPurchased != null) ...[
                      const Text(
                        '  ·  ',
                        style: TextStyle(color: _textSecondary, fontSize: 12),
                      ),
                      Text(
                        '${tx.tokensPurchased} tokens',
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isFunds ? '+' : '-'} ${_formatCurrency(tx.amount)}',
            style: TextStyle(
              color: isFunds ? _green : _textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _textSecondary, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fundsController.dispose();
    super.dispose();
  }
}