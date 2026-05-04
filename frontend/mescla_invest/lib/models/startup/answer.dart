/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

class AnswerModel {
  final String authorUId; // Adicionado conforme QuestionAnwserDocument
  final String content;
  final DateTime? createdAt;

  AnswerModel({required this.authorUId, required this.content, this.createdAt});

  factory AnswerModel.fromMap(Map<String, dynamic> map) {
    return AnswerModel(
      authorUId: map['authorUId'] ?? '', //
      content: map['content'] ?? '', //[cite: 16]
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is int
                ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
                : (map['createdAt'] as Map)['seconds'] != null
                ? DateTime.fromMillisecondsSinceEpoch(
                    (map['createdAt']['seconds'] as int) * 1000,
                  )
                : null)
          : null,
    );
  }
}
