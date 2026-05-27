// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/models/user/investment_model.dart';
import 'package:mescla_invest/models/user/wallet_model.dart';
import 'package:mescla_invest/screens/app/home/home_header.dart';
import 'package:mescla_invest/screens/app/home/startup_list_item.dart';
import 'package:mescla_invest/screens/app/home/token_chart.dart';
import 'package:mescla_invest/services/user_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color verdeMescla = Color(0xFF7FDD3A);

  WalletModel? _wallet;
  List<InvestmentModel> _investments = [];
  bool _isLoadingWallet = true;
  bool _isLoadingInvestments = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadWallet() async {
    setState(() => _isLoadingWallet = true);
    try {
      final wallet = await UserService.getWallet();
      if (mounted) setState(() => _wallet = wallet);
    } catch (err) {
      if (mounted) handleException(err: err, context: context);
    } finally {
      if (mounted) setState(() => _isLoadingWallet = false);
    }
  }

  Future<void> _loadInvestments() async {
    setState(() => _isLoadingInvestments = true);
    try {
      final investments = await UserService.getUserInvestments();
      if (mounted) setState(() => _investments = investments);
    } catch (err) {
      if (mounted) handleException(err: err, context: context);
    } finally {
      if (mounted) setState(() => _isLoadingInvestments = false);
    }
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadWallet(), _loadInvestments()]);
  }

  double get _totalPortfolioValue {
    return _investments.fold(0.0, (sum, i) {
      return sum + i.startup.tokenPrice * i.totalTokens;
    });
  }

  double get _totalCostValue {
    return _investments.fold(0.0, (sum, i) {
      return sum + i.startup.initialTokenPrice * i.totalTokens;
    });
  }

  double? get _portfolioAppreciationPercent {
    if (_totalCostValue == 0) return null;
    return ((_totalPortfolioValue - _totalCostValue) / _totalCostValue) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final appreciation = _portfolioAppreciationPercent;
    final isPositive = (appreciation ?? 0) >= 0;
    final appreciationColor = isPositive ? verdeMescla : Colors.redAccent;

    // FIX: padding horizontal consistente em toda a tela
    const double hPad = 16.0;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadAll,
        color: AppColors.verdeMescla,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: hPad),
                child: HomeHeader(
                  wallet: _wallet,
                  isLoadingWallet: _isLoadingWallet,
                  onWalletUpdated: _loadWallet,
                ),
              ),
            ),

            // FIX: espaço entre header e card
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Card total investido
            SliverToBoxAdapter(
              child: Padding(
                // FIX: margem horizontal para não encostar nas bordas
                padding: const EdgeInsets.symmetric(horizontal: hPad),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Investido',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Atualizado hoje',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      if (_isLoadingInvestments)
                        const CircularProgressIndicator(color: verdeMescla)
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              formatCurrency(_totalPortfolioValue),
                              style: const TextStyle(
                                color: verdeMescla,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (appreciation != null && _investments.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: appreciationColor.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPositive
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      color: appreciationColor,
                                      size: 16,
                                    ),
                                    Text(
                                      '${isPositive ? '+' : ''}${appreciation.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        color: appreciationColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // FIX: espaço entre card e gráfico
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Gráfico com padding lateral
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: hPad),
                child: const TokenChart(),
              ),
            ),

            // FIX: espaço entre gráfico e seção de investimentos
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Seção "Meus investimentos"
            SliverToBoxAdapter(
              child: Padding(
                // FIX: padding lateral na seção inteira
                padding: const EdgeInsets.symmetric(horizontal: hPad),
                child: Column(
                  // FIX: alinhar conteúdo à esquerda, não centralizado
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meus investimentos',
                      style: TextStyle(
                        color: verdeMescla,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),

                    // FIX: espaço entre título e lista
                    const SizedBox(height: 12),

                    if (_isLoadingInvestments)
                      const Center(
                        child: CircularProgressIndicator(color: verdeMescla),
                      )
                    else if (_investments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Você ainda não investiu em nenhuma startup.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    else
                      ..._investments.map(
                        (i) => StartupListItem(
                          nome: i.startup.name,
                          inicial: i.startup.name[0].toUpperCase(),
                          tokens: i.totalTokens,
                          tokenPrice: i.startup.tokenPrice,
                          appreciationPercent: i.startup.appreciationPercent,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // FIX: padding inferior para não cortar o último item
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
