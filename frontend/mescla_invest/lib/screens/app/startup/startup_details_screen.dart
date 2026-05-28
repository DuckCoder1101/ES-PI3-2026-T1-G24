/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/screens/app/startup/about_tab.dart';
import 'package:mescla_invest/screens/app/startup/buy_tokens_sheet.dart';
import 'package:mescla_invest/screens/app/startup/partners_tab.dart';
import 'package:mescla_invest/screens/app/startup/price_history_tab.dart';
import 'package:mescla_invest/screens/app/startup/qa_tab.dart';
import 'package:mescla_invest/screens/app/startup/updates_tab.dart';
import 'package:mescla_invest/services/startup_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';
import 'package:mescla_invest/widgets/layout/model_header.dart';
import 'package:mescla_invest/widgets/ui/primary_button.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';

enum _StartupDetailsTab {
  about,
  price,
  partners,
  qa,
  updates;

  IconData get icon {
    return switch (this) {
      about => Icons.text_snippet_outlined,
      price => Icons.currency_bitcoin_outlined,
      partners => Icons.people_outline,
      qa => Icons.question_answer_outlined,
      updates => Icons.newspaper_outlined,
    };
  }

  IconData get iconSelected => switch (this) {
    about => Icons.text_snippet_rounded,
    price => Icons.currency_bitcoin_rounded,
    partners => Icons.people_rounded,
    qa => Icons.question_answer_rounded,
    updates => Icons.newspaper_rounded,
  };
}

class StartupDetailsScreen extends StatefulWidget {
  final String? startupId;
  const StartupDetailsScreen({super.key, this.startupId});

  @override
  State<StartupDetailsScreen> createState() => _StartupDetailsScreenState();
}

class _StartupDetailsScreenState extends State<StartupDetailsScreen> {
  Future<StartupModel>? _startupFuture;

  _StartupDetailsTab _activeTab = _StartupDetailsTab.about;

  @override
  void initState() {
    super.initState();
    if (widget.startupId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return;
    }

    try {
      _startupFuture = StartupService.getStartupById(widget.startupId!);
    } catch (err, stack) {
      if (mounted) {
        handleException(err: err, stack: stack, context: context);
        Navigator.pop(context);
      }
    }
  }

  void _showBuyTokensModal(StartupModel startup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.campoEscuro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BuyTokensSheet(
        startup: startup,
        onSuccess: () {
          setState(() {
            _startupFuture = StartupService.getStartupById(widget.startupId!);
          });

          showSnackbar(msg: "Tokens comprados com sucesso!", context: context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<StartupModel>(
        future: _startupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.verdeMescla),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erro: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "Startup não encontrada",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final startup = snapshot.data!;
          return SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      children: [
                        ModalHeader(title: startup.name),
                        const SizedBox(height: 24),
                        Stack(
                          children: [
                            Container(
                              height: 250,
                              width: double.infinity,
                              color: AppColors.campoEscuro,
                              child: startup.thumbnailUrl != null
                                  ? Image.network(
                                      startup.thumbnailUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          const _ThumbPlaceholder(),
                                    )
                                  : const _ThumbPlaceholder(),
                            ),
                            Container(
                              height: 250,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      startup.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  _buildTag(
                                    startup.stage.name.toUpperCase().replaceAll(
                                      '_',
                                      ' ',
                                    ),
                                    AppColors.verdeMescla.withValues(
                                      alpha: 0.8,
                                    ),
                                    AppColors.verdeMescla,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildMetricsRow(startup),
                              const SizedBox(height: 24),
                              _buildTabBar(),
                              const SizedBox(height: 24),
                              _buildTabContent(startup),
                              const SizedBox(height: 30),
                              PrimaryButton(
                                text: startup.totalTokensAvailable > 0
                                    ? "Investir agora"
                                    : "Tokens esgotados",
                                onPressed: startup.totalTokensAvailable > 0
                                    ? () => _showBuyTokensModal(startup)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricsRow(StartupModel startup) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricChip(
            icon: Icons.token_rounded,
            label: 'Preço/token',
            value: formatCurrency(startup.tokenPrice),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricChip(
            icon: Icons.inventory_2_rounded,
            label: 'Disponíveis',
            value: '${startup.totalTokensAvailable}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricChip(
            icon: Icons.trending_up_rounded,
            label: 'Captado',
            value: formatCurrency(startup.tokenPrice),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.verdeMescla, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = _StartupDetailsTab.values.toList();
    return Row(
      children: tabs.map((tab) {
        final isSelected = _activeTab == tab;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _activeTab = tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.verdeMescla.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  isSelected ? tab.iconSelected : tab.icon,
                  key: ValueKey(isSelected),
                  color: isSelected ? AppColors.verdeMescla : Colors.white30,
                  size: 22,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabContent(StartupModel startup) {
    switch (_activeTab) {
      case _StartupDetailsTab.price: // ← novo case
        return TabPriceHistory(startupId: widget.startupId!);
      case _StartupDetailsTab.partners:
        return TabPartners(startup: startup);
      case _StartupDetailsTab.qa:
        return TabQA(startup: startup);
      case _StartupDetailsTab.updates:
        return TabUpdates(startupId: widget.startupId!);
      case _StartupDetailsTab.about:
        return TabAbout(startup: startup);
    }
  }

  Widget _buildTag(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textCol,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.campoEscuro,
      child: const Center(
        child: Icon(
          Icons.rocket_launch_rounded,
          color: AppColors.verdeMescla,
          size: 64,
        ),
      ),
    );
  }
}
