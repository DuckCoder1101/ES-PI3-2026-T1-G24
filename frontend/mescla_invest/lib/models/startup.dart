/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:mescla_invest/models/external_member.dart';
import 'package:mescla_invest/models/founder.dart';

enum StartupStage { nova, em_operacao, em_espansao }

enum StartupStageFilter { nova, em_operacao, em_espansao, all }

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
  final String type;
  final String? videoPath;
  final List<String> galleryPaths;
  final List<Founder> founders;
  final List<ExternalMember> externalMembers;
  final List<String> tags;

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
    required this.type,
    this.videoPath,
    this.galleryPaths = const [],
    this.founders = const [],
    this.externalMembers = const [],
    this.tags = const [],
  });

  factory StartupModel.fromMap(String id, Map<String, dynamic> rawMap) {
    // Limpeza de chaves para evitar problemas com espaços do CSV
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));

    // Mapeamento do Enum de estágio
    StartupStage stageEnum;
    switch (map['stage']) {
      case 'em_operacao':
        stageEnum = StartupStage.em_operacao;
        break;
      case 'em_expansao':
        stageEnum = StartupStage.em_espansao;
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
      // Conversão de cents para Real (decimal)
      tokenPrice: ((map['currentTokenPriceCents'] ?? 0) / 100).toDouble(),
      totalTokens: map['totalTokensIssued'] ?? 0,
      totalRaised: ((map['capitalRaisedCents'] ?? 0) / 100).toDouble(),
      stage: stageEnum,
      type: map['type'] ?? 'Start-up',
      // Pega o primeiro vídeo da lista enviada pelo CSV
      videoPath: (map['videos'] as List?)?.isNotEmpty == true
          ? (map['videos'] as List).first.toString()
          : null,
      galleryPaths: List<String>.from(map['galleryPaths'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      founders: (map['founders'] as List? ?? [])
          .map((f) => Founder.fromMap(Map<String, dynamic>.from(f)))
          .toList(),
      externalMembers: (map['externalMember'] as List? ?? [])
          .map((e) => ExternalMember.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  static Future<StartupModel> getStartupDetails(String startupId) async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getStartupDetails')
          .call({'startupId': startupId});

      return StartupModel.fromMap(
        startupId,
        Map<String, dynamic>.from(response.data),
      );
    } catch (e) {
      throw Exception("Erro ao carregar detalhes da startup: $e");
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
            // Garante que offset e limit sejam tratados como números puros
            'offset': offset.toInt(),
            'limit': limit.toInt(),
            'filter': {'stage': stageFilter.name, 'name': nameFilter},
          });

      // Verifique se a estrutura de retorno coincide com o que o backend envia { startups: [...] }
      final data = response.data as Map<dynamic, dynamic>;
      final List rawList = data['startups'] ?? [];

      return rawList
          .map(
            (s) => StartupModel.fromMap(s['id'], Map<String, dynamic>.from(s)),
          )
          .toList();
    } catch (e) {
      debugPrint("Erro ao buscar listagem: $e");
      return [];
    }
  }

  Future<String> getDownloadUrl(String path) async {
    if (path.startsWith('http')) return path;
    return await FirebaseStorage.instance.ref(path).getDownloadURL();
  }
}
