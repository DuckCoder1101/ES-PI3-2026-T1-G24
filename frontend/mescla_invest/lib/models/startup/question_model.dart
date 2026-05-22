/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:mescla_invest/models/startup/awnser_model.dart';

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
      id: map["id"] ?? '',
      authorUId: map['authorUId'] ?? '',
      content: map['content'] ?? '',
      isAuthor: map['isAuthor'] ?? false,
      visibility: QuestionVisibility.values.byName(map['visibility']),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is int
                ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
                : (map['createdAt'] as Map)['seconds'] != null
                ? DateTime.fromMillisecondsSinceEpoch(
                    (map['createdAt']['seconds'] as int) * 1000,
                  )
                : null)
          : null,
      answers: (map['answers'] ?? [])
          .map((a) => AnswerModel.fromMap(Map<String, dynamic>.from(a)))
          .toList(),
    );
  }
}
