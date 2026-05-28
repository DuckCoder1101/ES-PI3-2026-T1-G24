/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:mescla_invest/formatters/timestamp_to_date.dart';

class StartupNewsModel {
  final String id;
  final String startupId;
  final String title;
  final String content;
  final DateTime? createdAt;

  StartupNewsModel({
    required this.id,
    required this.startupId,
    required this.title,
    required this.content,
    this.createdAt,
  });

  factory StartupNewsModel.fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));
    return StartupNewsModel(
      id: map['id'] ?? '',
      startupId: map['startupId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: parseTimestamp(map['createdAt']),
    );
  }
}
