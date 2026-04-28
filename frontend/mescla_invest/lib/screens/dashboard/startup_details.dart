import 'package:flutter/material.dart';
import 'package:mescla_invest/components/ui/primary_button.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/startup.dart';

class StartupDetailsScreen extends StatefulWidget {
  final String startupId;
  const StartupDetailsScreen({super.key, required this.startupId});

  @override
  State<StartupDetailsScreen> createState() => _StartupDetailsScreenState();
}

class _StartupDetailsScreenState extends State<StartupDetailsScreen> {
  late Future<StartupModel> _startupFuture;

  @override
  void initState() {
    super.initState();
    _startupFuture = StartupModel.getStartupDetails(widget.startupId);
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

          final startup = snapshot.data!;

          return CustomScrollView(
            slivers: [
              _buildHeader(startup),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTabs(),
                      const SizedBox(height: 20),
                      _buildStatsRow(startup),
                      const SizedBox(height: 30),
                      _buildSectionTitle("SUMÁRIO EXECUTIVO"),
                      _buildInfoCard(startup.description),
                      const SizedBox(height: 30),
                      _buildSectionTitle("VÍDEOS"),
                      _buildVideoPlaceholder(startup.videoPath),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          text: "Comprar / Vender Tokens",
                          onPressed: () => debugPrint("Trade acionado"),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(StartupModel startup) {
    return SliverAppBar(
      expandedHeight: 180,
      backgroundColor: const Color(0xFF1B2D0C), // Tom verde escuro da imagem
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.verdeMescla),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                startup.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTag(
                    startup.stage.toString(),
                    AppColors.verdeMescla.withValues(),
                    AppColors.verdeMescla,
                  ),
                  const SizedBox(width: 8),
                  _buildTag(startup.type, Colors.white10, Colors.white70),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(StartupModel startup) {
    return Row(
      children: [
        _buildStatItem(
          "R\$ ${startup.tokenPrice.toStringAsFixed(2)}",
          "Preço token",
        ),
        const SizedBox(width: 12),
        _buildStatItem(startup.totalTokens.toString(), "Tokens emitidos"),
        const SizedBox(width: 12),
        _buildStatItem("R\$ ${startup.totalRaised.toString()}k", "Captado"),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.campoEscuro,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, height: 1.5),
      ),
    );
  }

  Widget _buildVideoPlaceholder(String? path) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.play_arrow_rounded,
          size: 64,
          color: AppColors.verdeMescla,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ['Sobre', 'Sócios', 'Q&A', 'Updates'].map((tab) {
        bool isSelected = tab == 'Sobre';
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.campoEscuro : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: Colors.white10) : null,
          ),
          child: Text(
            tab,
            style: TextStyle(
              color: isSelected ? AppColors.verdeMescla : Colors.white38,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.verdeMescla,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
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
