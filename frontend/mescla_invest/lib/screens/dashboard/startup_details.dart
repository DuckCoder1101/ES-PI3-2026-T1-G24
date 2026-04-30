/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/widgets/layout/startup/about.dart';
import 'package:mescla_invest/widgets/layout/startup/partners.dart';
import 'package:mescla_invest/widgets/layout/startup/questions_answers.dart';
import 'package:mescla_invest/widgets/ui/primary_button.dart';
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
  String _activeTab = 'Sobre';

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

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "Startup não encontrada",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final startup = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header com Imagem de Capa
                Stack(
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            startup.galleryPaths.isNotEmpty
                                ? startup.galleryPaths[0]
                                : 'https://via.placeholder.com/400x250',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
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
                    PositionRectangle(
                      top: 40,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome e Tags
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              startup.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildTag(
                            startup.stage.name.toUpperCase(),
                            AppColors.verdeMescla.withValues(alpha: 0.8),
                            AppColors.verdeMescla,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        startup.type,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Barra de Navegação de Abas
                      _buildTabBar(),

                      const SizedBox(height: 24),

                      // Conteúdo Dinâmico com base na aba
                      _buildTabContent(startup),

                      const SizedBox(height: 30),

                      // Botão de Investimento Fixo no final
                      PrimaryButton(
                        text: "Investir agora",
                        onPressed: () {
                          // Lógica de investimento
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    List<String> tabs = ['Sobre', 'Sócios', 'Q&A', 'Updates'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tabs.map((tab) {
        bool isSelected = _activeTab == tab;
        return GestureDetector(
          onTap: () => setState(() => _activeTab = tab),
          child: Container(
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
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabContent(StartupModel startup) {
    switch (_activeTab) {
      case 'Sócios':
        return TabSocios(startup: startup, startupId: widget.startupId);
      case 'Q&A':
        return TabQA(startupId: widget.startupId, startupName: startup.name);
      case 'Updates':
        return const Center(
          child: Text(
            "Sem atualizações.",
            style: TextStyle(color: Colors.white38),
          ),
        );
      case 'Sobre':
      default:
        return TabSobre(startup: startup, startupId: widget.startupId);
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

// Widget auxiliar simples para posicionar o botão de volta no Stack
class PositionRectangle extends StatelessWidget {
  final double? top, left;
  final Widget child;
  const PositionRectangle({
    super.key,
    this.top,
    this.left,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(top: top, left: left, child: child);
  }
}
