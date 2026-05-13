/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescla_invest/models/investment/investment.dart';
import 'package:mescla_invest/models/startup/question.dart';
import 'package:mescla_invest/widgets/ui/primary_button.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/startup/startup.dart';

class StartupDetailsScreen extends StatefulWidget {
  final String? startupId;
  const StartupDetailsScreen({super.key, this.startupId});

  @override
  State<StartupDetailsScreen> createState() => _StartupDetailsScreenState();
}

class _StartupDetailsScreenState extends State<StartupDetailsScreen> {
  Future<StartupModel>? _startupFuture;
  String _activeTab = 'Sobre';

  @override
  void initState() {
    super.initState();

    if (widget.startupId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return;
    }

    String? errorMsg;
    try {
      _startupFuture = StartupModel.getStartupDetails(widget.startupId!);
    } on FirebaseFunctionsException catch (err) {
      if (err.code == "not-found") {
        errorMsg = "Startup não encontrada!";
      } else {
        errorMsg =
            "Erro inesperado interno ao buscar dados de startup! Tente novamente mais tarde!";
      }
    } catch (err) {
      debugPrint("Erro ao buscar dados de startup: $err");
      errorMsg = "Erro inesperado ao buscar dados de startup!";
    } finally {
      if (errorMsg != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg!),
                backgroundColor: Colors.redAccent,
              ),
            );
            Navigator.pop(context);
          }
        });
      }
    }
  }

  // Abre o modal de compra direta de tokens da startup
  void _showBuyTokensModal(StartupModel startup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.campoEscuro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BuyTokensSheet(
        startup: startup,
        onSuccess: () {
          setState(() {
            // Recarrega os detalhes para refletir os novos tokens disponíveis
            _startupFuture = StartupModel.getStartupDetails(widget.startupId!);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tokens comprados com sucesso!'),
              backgroundColor: AppColors.verdeMescla,
            ),
          );
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

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header com imagem de capa
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
                      // Nome e badge de estágio
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
                            startup.stage.name.toUpperCase().replaceAll(
                              '_',
                              ' ',
                            ),
                            AppColors.verdeMescla.withValues(alpha: 0.8),
                            AppColors.verdeMescla,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Métricas rápidas da startup
                      _buildMetricsRow(startup),

                      const SizedBox(height: 24),

                      // Barra de abas
                      _buildTabBar(),

                      const SizedBox(height: 24),

                      // Conteúdo dinâmico conforme aba selecionada
                      _buildTabContent(startup),

                      const SizedBox(height: 30),

                      // Botão de compra direta de tokens
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
          );
        },
      ),
    );
  }

  // Linha de métricas: preço do token, tokens disponíveis e capital captado
  Widget _buildMetricsRow(StartupModel startup) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricChip(
            icon: Icons.token_rounded,
            label: 'Preço/token',
            value:
                'R\$ ${startup.tokenPrice.toStringAsFixed(2).replaceAll('.', ',')}',
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
            value:
                'R\$ ${startup.totalRaised.toStringAsFixed(0).replaceAll('.', ',')}',
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
    final tabs = ['Sobre', 'Sócios', 'Q&A', 'Updates'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tabs.map((tab) {
        final isSelected = _activeTab == tab;
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
        return TabPartners(startup: startup, startupId: widget.startupId!);
      case 'Q&A':
        return TabQA(
          startupId: widget.startupId!,
          startupName: startup.name,
          isInvestor: startup.isInvestor,
        );
      case 'Updates':
        return const Center(
          child: Text(
            "Sem atualizações.",
            style: TextStyle(color: Colors.white38),
          ),
        );
      case 'Sobre':
      default:
        return TabAbout(startup: startup, startupId: widget.startupId!);
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

// Sheet de compra direta de tokens na página da startup
class _BuyTokensSheet extends StatefulWidget {
  final StartupModel startup;
  final VoidCallback onSuccess;

  const _BuyTokensSheet({required this.startup, required this.onSuccess});

  @override
  State<_BuyTokensSheet> createState() => _BuyTokensSheetState();
}

class _BuyTokensSheetState extends State<_BuyTokensSheet> {
  final _qtyController = TextEditingController(text: '1');
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  int get _tokenAmount => int.tryParse(_qtyController.text) ?? 0;
  double get _total => _tokenAmount * widget.startup.tokenPrice;

  Future<void> _submit() async {
    if (_tokenAmount <= 0) {
      setState(() => _error = 'A quantidade deve ser maior que zero.');
      return;
    }

    if (_tokenAmount > widget.startup.totalTokensAvailable) {
      setState(
        () => _error =
            'Quantidade maior que os tokens disponíveis (${widget.startup.totalTokensAvailable}).',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await InvestmentModel.buyTokens(
        startupId: widget.startup.id,
        tokenAmount: _tokenAmount,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        setState(() => _error = e.message ?? 'Erro ao comprar tokens.');
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.startup.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'R\$ ${widget.startup.tokenPrice.toStringAsFixed(2).replaceAll('.', ',')} / token',
                style: const TextStyle(
                  color: AppColors.verdeMescla,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            '${widget.startup.totalTokensAvailable} tokens disponíveis',
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),

          const SizedBox(height: 24),

          // Seletor de quantidade
          const Text(
            'Quantidade de tokens',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  final v = int.tryParse(_qtyController.text) ?? 1;
                  if (v > 1) {
                    _qtyController.text = '${v - 1}';
                    setState(() {});
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    border: Border.all(color: AppColors.verdeMescla),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final v = int.tryParse(_qtyController.text) ?? 0;
                  _qtyController.text = '${v + 1}';
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.verdeMescla,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 20),
                ),
              ),
            ],
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ],

          const SizedBox(height: 20),

          // Resumo do total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total a pagar',
                  style: TextStyle(color: Colors.white54),
                ),
                Text(
                  'R\$ ${_total.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    color: AppColors.verdeMescla,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.verdeMescla,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
                    'Confirmar compra',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Tabs reutilizadas da versão original ────────────────────────────────────

class TabAbout extends StatelessWidget {
  final StartupModel startup;
  final String startupId;

  const TabAbout({super.key, required this.startup, required this.startupId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        if (startup.executiveSummary.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            "SUMÁRIO EXECUTIVO",
            style: TextStyle(
              color: AppColors.verdeMescla,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            startup.executiveSummary,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
        if (startup.videoUrl != null) _buildVideoSection(),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
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
  final String startupId;

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
        if (startup.externalMembers.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            "CONSELHO / MENTORES",
            style: TextStyle(
              color: AppColors.verdeMescla,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...startup.externalMembers.map(
            (m) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.campoEscuro,
                child: Icon(
                  Icons.supervised_user_circle,
                  color: Colors.white38,
                ),
              ),
              title: Text(m.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                m.role,
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class TabQA extends StatefulWidget {
  final String startupId;
  final String startupName;

  // Controla se o usuário pode acessar a aba privada do Q&A
  final bool isInvestor;

  const TabQA({
    super.key,
    required this.startupId,
    required this.startupName,
    this.isInvestor = false,
  });

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

    // Aba privada selecionada mas usuário não é investidor: exibe gate
    final bool showInvestorGate =
        _visibility == QuestionVisibility.privada && !widget.isInvestor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggle(corDestaque),
        const SizedBox(height: 24),
        if (showInvestorGate)
          _buildInvestorGate()
        else ...[
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
      ],
    );
  }

  // Gate exibido quando o usuário tenta acessar o Q&A privado sem ser investidor
  Widget _buildInvestorGate() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFB300).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: Color(0xFFFFB300),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Área exclusiva para investidores',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Adquira tokens desta startup para acessar o canal privado de comunicação com os fundadores.',
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () =>
                setState(() => _visibility = QuestionVisibility.publica),
            icon: const Icon(Icons.public_rounded, size: 16),
            label: const Text('Ver perguntas públicas'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.verdeMescla,
              side: const BorderSide(color: AppColors.verdeMescla),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleCard(QuestionModel q, Color accentColor) {
    if (!q.isAuthor) return _buildQuestionCard(q, accentColor);

    return Dismissible(
      key: Key(q.id),
      direction: DismissDirection.endToStart,
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
                const Icon(Icons.chevron_left, color: Colors.white10, size: 16),
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
    final isSelected = _visibility == val;
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

// Widget auxiliar para posicionar elementos em Stack
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

// Placeholder exibido quando a imagem da startup não está disponível no Storage
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
