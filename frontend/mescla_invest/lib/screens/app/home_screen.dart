// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';
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
    _loadWallet();
    _loadInvestments();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com saldo real
              HomeHeader(
                wallet: _wallet,
                isLoadingWallet: _isLoadingWallet,
                onWalletUpdated: _loadWallet,
              ),

              const SizedBox(height: 24),

              // Card total investido
              Container(
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
                    _isLoadingWallet
                        ? const CircularProgressIndicator(color: verdeMescla)
                        : Text(
                            'R\$ ${((_wallet?.totalFunds ?? 0) - (_wallet?.funds ?? 0)).toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(
                              color: verdeMescla,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Gráfico
              const TokenChart(),

              const SizedBox(height: 24),

              // Minhas Startups
              const Text(
                'Meus investimentos',
                style: TextStyle(
                  color: verdeMescla,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              if (_isLoadingInvestments)
                const Center(
                  child: CircularProgressIndicator(color: verdeMescla),
                )
              else if (_investments.isEmpty)
                const Text(
                  'Você ainda não investiu em nenhuma startup.',
                  style: TextStyle(color: Colors.white54),
                )
              else
                ..._investments.map(
                  (i) => StartupListItem(
                    nome: i.startup.name,
                    inicial: i.startup.name[0].toUpperCase(),
                    tokens: i.totalTokens,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}