import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/user/investment_model.dart';
import 'package:mescla_invest/models/user/transaction_model.dart';
import 'package:mescla_invest/models/user/wallet_model.dart';
import 'package:mescla_invest/screens/app/wallet/history_tab.dart';
import 'package:mescla_invest/screens/app/wallet/investments_tab.dart';
import 'package:mescla_invest/screens/app/wallet/wallet_ballance_card.dart';
import 'package:mescla_invest/services/user_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';
import 'package:mescla_invest/widgets/layout/add_funds_sheet.dart';

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

  Future<void> _loadAll() async {
    await Future.wait([_loadWallet(), _loadInvestments(), _loadTransactions()]);
  }

  Future<void> _loadWallet() async {
    setState(() => _isLoadingWallet = true);
    try {
      final wallet = await UserService.getWallet();
      if (mounted) setState(() => _wallet = wallet);
    } catch (err, stack) {
      if (mounted) handleException(err: err, stack: stack, context: context);
    } finally {
      if (mounted) setState(() => _isLoadingWallet = false);
    }
  }

  Future<void> _loadInvestments() async {
    setState(() => _isLoadingInvestments = true);
    try {
      final investments = await UserService.getUserInvestments();
      if (mounted) setState(() => _investments = investments);
    } catch (err, stack) {
      if (mounted) handleException(err: err, stack: stack, context: context);
    } finally {
      if (mounted) setState(() => _isLoadingInvestments = false);
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoadingTransactions = true);
    try {
      final txs = await UserService.getUserTransactions();
      if (mounted) setState(() => _transactions = txs);
    } catch (err, stack) {
      if (mounted) handleException(err: err, stack: stack, context: context);
    } finally {
      if (mounted) setState(() => _isLoadingTransactions = false);
    }
  }

  void _showAddFundsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.campoEscuro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddFundsSheet(
        onSuccess: () async {
          await _loadWallet();
          await _loadTransactions();
          if (mounted) {
            showSnackbar(
              msg: 'Saldo adicionado com sucesso!',
              context: context,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadAll,
        color: AppColors.verdeMescla,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: WalletBalanceCard(
                wallet: _wallet,
                isLoading: _isLoadingWallet,
                balanceVisible: _balanceVisible,
                onToggleVisibility: () =>
                    setState(() => _balanceVisible = !_balanceVisible),
                onAddFunds: _showAddFundsModal,
              ),
            ),
            SliverToBoxAdapter(
              child: TabBar(
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
            SliverFillRemaining(
              hasScrollBody: true,
              child: TabBarView(
                controller: _tabController,
                children: [
                  InvestmentsTab(
                    investments: _investments,
                    isLoading: _isLoadingInvestments,
                  ),
                  HistoryTab(
                    transactions: _transactions,
                    isLoading: _isLoadingTransactions,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
