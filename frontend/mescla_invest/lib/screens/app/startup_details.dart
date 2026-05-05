/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/models/startup/question.dart';
import 'package:mescla_invest/widgets/ui/primary_button.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/startup/startup.dart';

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
        return TabPartners(startup: startup, startupId: widget.startupId);
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
        return TabAbout(startup: startup, startupId: widget.startupId);
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

class TabAbout extends StatelessWidget {
  final StartupModel startup;
  final String startupId; // Parâmetro solicitado

  const TabAbout({super.key, required this.startup, required this.startupId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (startup.videoPath != null) _buildVideoSection(),
        const Text(
          "DESCRIÇÃO",
          style: TextStyle(
            color: AppColors.verdeMescla,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          startup.description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "VÍDEO",
          style: TextStyle(
            color: AppColors.verdeMescla,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: AppColors.campoEscuro,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.play_circle_fill,
            size: 64,
            color: AppColors.verdeMescla,
          ),
        ),
      ],
    );
  }
}

class TabPartners extends StatelessWidget {
  final StartupModel startup;
  final String startupId; // Parâmetro solicitado

  const TabPartners({
    super.key,
    required this.startup,
    required this.startupId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "FUNDADORES",
          style: TextStyle(
            color: AppColors.verdeMescla,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...startup.founders.map(
          (f) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: AppColors.campoEscuro,
              child: Icon(Icons.person, color: AppColors.verdeMescla),
            ),
            title: Text(f.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              "${f.role} • ${f.equityPercent}%",
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}

class TabQA extends StatefulWidget {
  final String startupId;
  final String startupName;

  const TabQA({super.key, required this.startupId, required this.startupName});

  @override
  State<TabQA> createState() => _TabQAState();
}

class _TabQAState extends State<TabQA> {
  bool _isLoading = false;
  bool _isEnviando = false;
  QuestionVisibility _visibility = QuestionVisibility.publica;
  List<QuestionModel> _questions = [];
  final _perguntaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshQuestions();
  }

  @override
  void dispose() {
    _perguntaController.dispose();
    super.dispose();
  }

  // Helper para feedback padronizado (Igual ao Login)
  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isError ? Colors.redAccent : AppColors.verdeMescla,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  Future<void> _refreshQuestions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await QuestionModel.getQuestions(
        startupId: widget.startupId,
        visibility: _visibility,
      );
      if (mounted) setState(() => _questions = data);
    } catch (e) {
      _showFeedback("Erro ao carregar perguntas.", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _enviarPergunta() async {
    final texto = _perguntaController.text.trim();
    if (texto.isEmpty) return;

    setState(() => _isEnviando = true);
    try {
      await QuestionModel.registerQuestion(
        startupId: widget.startupId,
        content: texto,
        visibility: _visibility,
      );

      _perguntaController.clear();
      await _refreshQuestions();
    } catch (e) {
      _showFeedback("Erro ao enviar. Tente novamente.", isError: true);
    } finally {
      if (mounted) setState(() => _isEnviando = false);
    }
  }

  Future<void> _handleDelete(String questionId) async {
    try {
      await QuestionModel.deleteQuestion(
        startupId: widget.startupId,
        questionId: questionId,
      );
      _refreshQuestions();
    } catch (e) {
      _showFeedback("Não foi possível excluir a pergunta.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color corDestaque = _visibility == QuestionVisibility.publica
        ? AppColors.verdeMescla
        : const Color(0xFFFFB300);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggle(corDestaque),
        const SizedBox(height: 24),
        if (_visibility == QuestionVisibility.privada)
          _buildAvisoPrivado(corDestaque),

        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: AppColors.verdeMescla),
            ),
          )
        else if (_questions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                "Nenhuma pergunta por aqui.",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          )
        else
          ..._questions.map((q) => _buildDismissibleCard(q, corDestaque)),

        const SizedBox(height: 24),
        _buildInput(corDestaque),
      ],
    );
  }

  // Implementação do Slider para exclusão
  Widget _buildDismissibleCard(QuestionModel q, Color accentColor) {
    // Apenas o autor pode deslizar para excluir
    if (!q.isAuthor) return _buildQuestionCard(q, accentColor);

    return Dismissible(
      key: Key(q.id),
      direction:
          DismissDirection.endToStart, // Arrastar da direita para a esquerda
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.campoEscuro,
            title: const Text(
              "Excluir pergunta?",
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              "Tem certeza que deseja remover esta pergunta permanentemente?",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  "CANCELAR",
                  style: TextStyle(color: Colors.white38),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "EXCLUIR",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _handleDelete(q.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
      ),
      child: _buildQuestionCard(q, accentColor),
    );
  }

  Widget _buildQuestionCard(QuestionModel q, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: q.isAuthor
            ? Border.all(color: accentColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: q.isAuthor ? accentColor : Colors.white12,
                radius: 16,
                child: Icon(
                  q.isAuthor ? Icons.person : Icons.alternate_email,
                  size: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                q.isAuthor ? "Você" : "Investidor",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (q.isAuthor)
                const Icon(
                  Icons.chevron_left,
                  color: Colors.white10,
                  size: 16,
                ), // Dica visual de slide
            ],
          ),
          const SizedBox(height: 12),
          Text(
            q.content,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          if (q.answers.isNotEmpty) ...[
            const Divider(color: Colors.white10, height: 24),
            ...q.answers.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "↳ ${a.content}",
                  style: const TextStyle(
                    color: AppColors.verdeMescla,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggle(Color activeColor) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleOption(
            "Público",
            QuestionVisibility.publica,
            activeColor,
          ),
          _buildToggleOption(
            "Privado",
            QuestionVisibility.privada,
            activeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    String label,
    QuestionVisibility val,
    Color activeColor,
  ) {
    bool isSelected = _visibility == val;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _visibility = val);
          _refreshQuestions();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2A2A2A) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? activeColor : Colors.white38,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvisoPrivado(Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        "Área exclusiva para investidores. Suas perguntas são enviadas diretamente aos fundadores.",
        style: TextStyle(color: color, fontSize: 13),
      ),
    );
  }

  Widget _buildInput(Color accentColor) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _perguntaController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Faça uma pergunta...",
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: AppColors.campoEscuro,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _isEnviando ? null : _enviarPergunta,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isEnviando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.send, color: Colors.black),
          ),
        ),
      ],
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
