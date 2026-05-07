/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';

enum QuestionVisibility { publica, privada }

class QuestionModel {
  final String id;
  final String authorUId;
  final String content;
  final bool isAuthor;
  final QuestionVisibility visibility;
  final DateTime? createdAt;
  final List<AnswerModel> answers;

  QuestionModel({
    required this.id,
    required this.authorUId,
    required this.content,
    required this.isAuthor,
    required this.visibility,
    this.createdAt,
    this.answers = const [],
  });

  factory QuestionModel.fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));

    return QuestionModel(
      id: map["id"] ?? '', //[cite: 16]
      authorUId: map['authorUId'] ?? '', //[cite: 16, 17]
      content: map['content'] ?? '', //[cite: 16, 17]
      isAuthor: map['isAuthor'] ?? false, //[cite: 17]
      visibility: map['visibility'] == 'privada'
          ? QuestionVisibility.privada
          : QuestionVisibility.publica, //[cite: 16, 17]
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is int
                ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
                : (map['createdAt'] as Map)['seconds'] != null
                ? DateTime.fromMillisecondsSinceEpoch(
                    (map['createdAt']['seconds'] as int) * 1000,
                  )
                : null)
          : null,
      answers:
          (map['answers'] as List? ??
                  []) // Ajustado de 'anwsers' para 'answers'[cite: 16, 17]
              .map((a) => AnswerModel.fromMap(Map<String, dynamic>.from(a)))
              .toList(),
    );
  }

  static Future<List<QuestionModel>> getQuestions({
    required String startupId,
    required QuestionVisibility visibility,
  }) async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getQuestions')
          .call({
            'startupId': startupId,
            'visibility': visibility.name, // Envia a string para o TS[cite: 16]
          });

      final Map<String, dynamic> data = Map<String, dynamic>.from(
        response.data,
      );
      final List raw = data['questions'] ?? [];

      return raw
          .map((q) => QuestionModel.fromMap(Map<String, dynamic>.from(q)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> registerQuestion({
    required String startupId,
    required String content,
    required QuestionVisibility visibility,
  }) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('registerQuestion').call({
        'startupId': startupId,
        'content': content,
        'visibility': visibility.name, // Envia a string para o TS[cite: 16]
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteQuestion({
    required String startupId,
    required String questionId,
  }) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('deleteQuestion').call({
        'startupId': startupId,
        'questionId': questionId,
      });
    } catch (e) {
      rethrow;
    }
  }
}

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
