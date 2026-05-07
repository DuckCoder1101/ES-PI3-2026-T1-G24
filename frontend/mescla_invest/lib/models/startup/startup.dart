/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

enum StartupStage { nova, em_operacao, em_expansao }

enum StartupStageFilter { nova, em_operacao, em_expansao, all }

class StartupModel {
  final String id;
  final String name;
  final String description;
  final String shortDescription;
  final String executiveSummary;
  final double tokenPrice;
  final int totalTokens;
  final double totalRaised;
  final StartupStage stage;

  final String? thumbnailPath;
  final String? videoPath;

  String? _thumbnailUrl;
  String? _videoUrl;

  String? get thumbnailUrl => _thumbnailUrl;
  String? get videoUrl => _videoUrl;

  bool _triedToLoadFiles = false;

  final List<String> tags;

  final List<FounderModel> founders;
  final List<ExternalMemberModel> externalMembers;

  StartupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.executiveSummary,
    required this.tokenPrice,
    required this.totalTokens,
    required this.totalRaised,
    required this.stage,
    required this.thumbnailPath,
    required this.videoPath,
    this.founders = const [],
    this.externalMembers = const [],
    this.tags = const [],
  });

  factory StartupModel.fromMap(String id, Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));

    // Mapeamento do Enum de estágio
    StartupStage stageEnum;
    switch (map['stage']) {
      case 'em_operacao':
        stageEnum = StartupStage.em_operacao;
        break;
      case 'em_expansao':
        stageEnum = StartupStage.em_expansao;
        break;
      case 'nova':
      default:
        stageEnum = StartupStage.nova;
    }

    return StartupModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      executiveSummary: map['executiveSummary'] ?? '',
      tokenPrice: ((map['currentTokenPriceCents'] ?? 0) / 100).toDouble(),
      totalTokens: map['totalTokensIssued'] ?? 0,
      totalRaised: ((map['capitalRaisedCents'] ?? 0) / 100).toDouble(),
      stage: stageEnum,

      thumbnailPath: map["thumbnailPath"],
      videoPath: map["videoPath"],

      tags: List<String>.from(map['tags'] ?? []),

      founders: (map['founders'] as List? ?? [])
          .map((f) => FounderModel.fromMap(Map<String, dynamic>.from(f)))
          .toList(),

      externalMembers: (map['externalMember'] as List? ?? [])
          .map((e) => ExternalMemberModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Future<void> loadMedia() async {
    if (_triedToLoadFiles) return;
    _triedToLoadFiles = true;

    try {
      if (thumbnailPath != null) {
        _thumbnailUrl = await FirebaseStorage.instance
            .ref(thumbnailPath)
            .getDownloadURL();
      }

      if (videoPath != null) {
        _videoUrl = await FirebaseStorage.instance
            .ref(videoPath)
            .getDownloadURL();
      }
    } catch (err) {
      debugPrint("Erro ao tentar carregar mídias da startup $id: $err");
    } finally {
      _triedToLoadFiles = true;
    }
  }

  static Future<StartupModel> getStartupDetails(String startupId) async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getStartupDetails')
          .call({'startupId': startupId});

      final startup = StartupModel.fromMap(
        startupId,
        Map<String, dynamic>.from(response.data),
      );

      await startup.loadMedia();

      return startup;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<StartupModel>> getStartups({
    required int offset,
    required int limit,
    required StartupStageFilter stageFilter,
    required String nameFilter,
  }) async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getStartups')
          .call({
            'offset': offset.toInt(),
            'limit': limit.toInt(),
            'filter': {'stage': stageFilter.name, 'name': nameFilter},
          });

      final data = response.data as Map<dynamic, dynamic>;
      final List rawList = data['startups'] ?? [];

      return rawList
          .map(
            (s) => StartupModel.fromMap(s['id'], Map<String, dynamic>.from(s)),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}

class ExternalMemberModel {
  final String name;
  final String role;

  ExternalMemberModel({required this.name, required this.role});

  factory ExternalMemberModel.fromMap(Map<String, dynamic> map) {
    return ExternalMemberModel(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
    );
  }
}

class FounderModel {
  final String name;
  final String role;
  final double equityPercent;

  FounderModel({
    required this.name,
    required this.role,
    required this.equityPercent,
  });

  factory FounderModel.fromMap(Map<String, dynamic> map) {
    return FounderModel(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      equityPercent: (map['equityPercent'] ?? 0).toDouble(),
    );
  }
}
