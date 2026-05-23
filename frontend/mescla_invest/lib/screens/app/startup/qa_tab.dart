/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/startup/question_model.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';
import 'package:mescla_invest/services/startup_service.dart';
import 'package:mescla_invest/services/user_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';

class TabQA extends StatefulWidget {
  final StartupModel startup;

  const TabQA({super.key, required this.startup});

  @override
  State<TabQA> createState() => _TabQAState();
}

class _TabQAState extends State<TabQA> {
  bool _isLoading = false;
  bool _isEnviando = false;

  String? _avatarUrl;
  QuestionVisibility _visibility = QuestionVisibility.publica;

  List<QuestionModel> _questions = [];
  final _perguntaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshQuestions();
    _loadAvatar();
  }

  @override
  void dispose() {
    _perguntaController.dispose();
    super.dispose();
  }

  Future<void> _loadAvatar() async {
    try {
      final url = await UserService.getAvatarUrl();
      if (mounted) setState(() => _avatarUrl = url);
    } catch (_) {}
  }

  Future<void> _refreshQuestions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await StartupService.getQuestions(
        startupId: widget.startup.id,
        visibility: _visibility,
      );
      if (mounted) setState(() => _questions = data);
    } catch (err) {
      if (mounted) {
        handleException(err: err, context: context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _enviarPergunta() async {
    final texto = _perguntaController.text.trim();
    if (texto.isEmpty) return;

    setState(() => _isEnviando = true);
    try {
      await StartupService.registerQuestion(
        startupId: widget.startup.id,
        content: texto,
        visibility: _visibility,
      );
      _perguntaController.clear();
      await _refreshQuestions();
    } catch (err) {
      if (mounted) {
        handleException(err: err, context: context);
      }
    } finally {
      if (mounted) setState(() => _isEnviando = false);
    }
  }

  Future<void> _handleDelete(String questionId) async {
    try {
      await StartupService.deleteQuestion(
        startupId: widget.startup.id,
        questionId: questionId,
      );
      _refreshQuestions();
    } catch (err) {
      if (mounted) {
        handleException(err: err, context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showInvestorGate =
        _visibility == QuestionVisibility.privada && !widget.startup.isInvestor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggle(),
        const SizedBox(height: 24),
        if (showInvestorGate)
          _buildInvestorGate()
        else ...[
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
                  "Nenhuma pergunta enviada.",
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            )
          else
            ..._questions.map((q) => _buildDismissibleCard(q)),

          const SizedBox(height: 24),
          _buildInput(),
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

  Widget _buildDismissibleCard(QuestionModel q) {
    if (!q.isAuthor) return _buildQuestionCard(q);

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
      child: _buildQuestionCard(q),
    );
  }

  Widget _buildQuestionCard(QuestionModel q) {
    final accentColor = _visibility.color;

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
                child: q.isAuthor && _avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          _avatarUrl!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : Icon(Icons.person, size: 14, color: Colors.black),
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

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleOption(QuestionVisibility.publica),
          _buildToggleOption(QuestionVisibility.privada),
        ],
      ),
    );
  }

  Widget _buildToggleOption(QuestionVisibility visibility) {
    final isSelected = _visibility == visibility;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _visibility = visibility);
          _refreshQuestions();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2A2A2A) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(visibility.icon, color: visibility.color, size: 14),

              const SizedBox(width: 8),

              Text(
                visibility.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? visibility.color : Colors.white38,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput() {
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
              color: _visibility.color,
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
