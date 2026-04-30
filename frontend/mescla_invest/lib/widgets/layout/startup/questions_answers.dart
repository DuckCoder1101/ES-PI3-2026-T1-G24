// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/question.dart';

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
      debugPrint("Erro ao buscar perguntas: $e");
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao enviar pergunta.')));
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pergunta removida!')));
      _refreshQuestions();
    } catch (e) {
      if (!mounted) return;
      final msg = e is FirebaseFunctionsException
          ? e.message
          : 'Erro ao deletar';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg ?? 'Erro ao deletar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color corDestaque = _visibility == QuestionVisibility.publica
        ? AppColors.verdeMescla
        : const Color(0xFFFFB300); // Laranja para modo privado

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
                "Nenhuma pergunta encontrada.",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          )
        else
          ..._questions.map((q) => _buildQuestionCard(q, corDestaque)),

        const SizedBox(height: 24),
        _buildInput(corDestaque),
      ],
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

  Widget _buildQuestionCard(QuestionModel q, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: q.isAuthor ? accentColor : Colors.white12,
                radius: 16,
                child: Text(
                  q.isAuthor ? "V" : "U",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  q.isAuthor ? "Você" : "Investidor",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (q.isAuthor)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.white38,
                    size: 20,
                  ),
                  onPressed: () => _handleDelete(q.id),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            q.content,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),

          if (q.answers.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white10),
            ),
            ...q.answers.map(
              (a) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.subdirectory_arrow_right,
                      color: AppColors.verdeMescla,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.content,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
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
