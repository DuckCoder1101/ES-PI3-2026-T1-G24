/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/startup/question.dart';

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
