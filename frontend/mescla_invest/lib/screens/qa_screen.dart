// Autor: Seu Nome Completo
// RA: seu-ra

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QaScreen extends StatefulWidget {
  final String startupId;
  final String startupName;

  const QaScreen({
    super.key,
    required this.startupId,
    required this.startupName,
  });

  @override
  State<QaScreen> createState() => _QaScreenState();
}

class _QaScreenState extends State<QaScreen> {
  static const Color verdeMescla = Color(0xFF7FDD3A);
  static const Color laranjaPrivado = Color(0xFFFFB300);

  bool _isPublico = true;
  bool _enviando = false;
  final _perguntaController = TextEditingController();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _currentUid => _auth.currentUser?.uid ?? '';

  CollectionReference get _questionsRef => _firestore
      .collection('startups')
      .doc(widget.startupId)
      .collection('questions');

  Stream<QuerySnapshot> get _questionsStream => _questionsRef
    .where('visibility', isEqualTo: _isPublico ? 'publica' : 'privada')
    .snapshots();

  @override
  void dispose() {
    _perguntaController.dispose();
    super.dispose();
  }

  Future<void> _enviarPergunta() async {
    final texto = _perguntaController.text.trim();
    if (texto.isEmpty) return;

    setState(() => _enviando = true);

    try {
      await _questionsRef.add({
        'authorUId': _currentUid,
        'text': texto,
        'visibility': _isPublico ? 'publica' : 'privada',
        'anwsers': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      _perguntaController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar pergunta.')),
      );
    } finally {
      setState(() => _enviando = false);
    }
  }

  Future<void> _apagarPergunta(String questionId) async {
    try {
      await _questionsRef.doc(questionId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao apagar pergunta.')),
      );
    }
  }

  String _formatarTempo(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return 'há ${diff.inDays} dias';
  }

  @override
  Widget build(BuildContext context) {
    final corBotao = _isPublico ? verdeMescla : laranjaPrivado;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.startupName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _isPublico ? 'Q&A Público' : 'Q&A Privado',
                    style: TextStyle(
                      color: corBotao,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isPublico = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isPublico ? const Color(0xFF2A2A2A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Público',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isPublico ? verdeMescla : Colors.white54,
                              fontWeight: _isPublico ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isPublico = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isPublico ? const Color(0xFF2A2A2A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Privado',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_isPublico ? laranjaPrivado : Colors.white54,
                              fontWeight: !_isPublico ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Aviso privado
            if (!_isPublico)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1F00),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Área exclusiva para investidores da ${widget.startupName}. Suas perguntas são respondidas diretamente pela equipe fundadora.',
                    style: const TextStyle(color: laranjaPrivado, fontSize: 13),
                  ),
                ),
              ),

            if (!_isPublico) const SizedBox(height: 16),

            // Lista de perguntas
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _questionsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: verdeMescla),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar perguntas.',
                          style: TextStyle(color: Colors.white54)),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma pergunta ainda.',
                          style: TextStyle(color: Colors.white54)),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${docs.length} ${_isPublico ? 'PERGUNTAS' : 'PERGUNTAS PRIVADAS'}',
                          style: TextStyle(
                            color: corBotao,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final questionId = doc.id;
                            final isAuthor = data['authorUId'] == _currentUid;
                            final respostas = (data['anwsers'] as List<dynamic>?) ?? [];
                            final tempo = _formatarTempo(data['createdAt'] as Timestamp?);
                            final inicial = (data['authorUId'] == _currentUid)
                                ? 'V'
                                : data['authorUId'].toString().substring(0, 1).toUpperCase();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: isAuthor ? verdeMescla : Colors.blueGrey,
                                        radius: 18,
                                        child: Text(
                                          isAuthor ? 'V' : inicial,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isAuthor ? 'Você' : 'Usuário',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              tempo,
                                              style: const TextStyle(
                                                color: Colors.white38,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Botão lixeira (só aparece para o autor)
                                      if (isAuthor)
                                        GestureDetector(
                                          onTap: () => _apagarPergunta(questionId),
                                          child: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.white38,
                                            size: 18,
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    data['text'] ?? '',
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),

                                  const Divider(color: Colors.white12, height: 20),

                                  if (respostas.isNotEmpty)
                                    ...respostas.map((r) {
                                      final resposta = r as Map<String, dynamic>;
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: verdeMescla,
                                            radius: 14,
                                            child: const Text(
                                              'F',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _isPublico
                                                      ? 'Fundador · ${widget.startupName}'
                                                      : 'Fundador · Privado',
                                                  style: TextStyle(
                                                    color: corBotao,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  resposta['text'] ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    })
                                  else
                                    const Text(
                                      'Aguardando resposta...',
                                      style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Campo de envio
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _perguntaController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: _isPublico ? 'Faça uma pergunta...' : 'Pergunta privada...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _enviando ? null : _enviarPergunta,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: corBotao,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _enviando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.arrow_forward, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}