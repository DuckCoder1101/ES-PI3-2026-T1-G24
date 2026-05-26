/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:mescla_invest/models/startup/external_member_model.dart';
import 'package:mescla_invest/models/startup/founder_model.dart';

enum StartupStage {
  nova,
  em_operacao,
  em_expansao;

  String get label {
    return switch (this) {
      nova => "Nova",
      em_operacao => "Em operação",
      em_expansao => "Em expansão",
    };
  }
}

enum StartupStageFilter { nova, em_operacao, em_expansao, all }

// StartupResumeDTO — resumo mínimo retornado em listas, ordens e transações--
class StartupResumeDTO {
  final String id;
  final String name;

  /// Indica se o usuário autenticado possui tokens desta startup.
  final bool isInvestor;

  const StartupResumeDTO({
    required this.id,
    required this.name,
    this.isInvestor = false,
  });

  factory StartupResumeDTO.fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));
    return StartupResumeDTO(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      isInvestor: map['isInvestor'] == true,
    );
  }
}

// StartupListDTO — item da listagem paginada de startups
class StartupListDTO {
  final String id;
  final String name;
  final String shortDescription;

  /// Preço atual do token em reais (convertido de centavos).
  final double tokenPrice;

  final int totalTokensAvailable;
  final StartupStage stage;
  final String? thumbnailPath;
  final List<String> tags;

  /// Indica se o usuário autenticado possui tokens desta startup.
  final bool isInvestor;

  StartupListDTO({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.tokenPrice,
    required this.totalTokensAvailable,
    required this.stage,
    required this.thumbnailPath,
    this.tags = const [],
    this.isInvestor = false,
  });

  factory StartupListDTO.fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));
    return StartupListDTO(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      tokenPrice:
          ((map['currentTokenPriceCents'] as num?)?.toDouble() ?? 0) / 100,
      totalTokensAvailable: (map['totalTokensAvailable'] as num?)?.toInt() ?? 0,
      stage: StartupStage.values.byName(map['stage'] ?? 'nova'),
      thumbnailPath: map['thumbnailPath'],
      tags: List<String>.from(map['tags'] ?? []),
      isInvestor: map['isInvestor'] == true,
    );
  }
}

// StartupModel — dados completos retornados na página de detalhes
class StartupModel {
  final String id;
  final String name;
  final String description;
  final String shortDescription;
  final String executiveSummary;

  /// Preço atual do token em reais (convertido de centavos).
  final double tokenPrice;

  final int totalTokensIssued;
  final int totalTokensAvailable;

  /// Capital total captado em reais (convertido de centavos).
  final double totalRaised;

  final StartupStage stage;

  // Caminhos de arquivos no storage
  final String? thumbnailPath;
  final String? videoPath;

  // URLs resolvidas após download do storage (mutáveis)
  String? thumbnailUrl;
  String? videoUrl;

  final List<String> tags;
  final List<FounderModel> founders;
  final List<ExternalMemberModel> externalMembers;

  /// Indica se o usuário autenticado possui tokens desta startup.
  final bool isInvestor;

  StartupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.executiveSummary,
    required this.tokenPrice,
    required this.totalTokensIssued,
    required this.totalTokensAvailable,
    required this.totalRaised,
    required this.stage,
    required this.thumbnailPath,
    required this.videoPath,
    this.founders = const [],
    this.externalMembers = const [],
    this.tags = const [],
    this.isInvestor = false,
  });

  factory StartupModel.fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));
    return StartupModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      executiveSummary: map['executiveSummary'] ?? '',
      tokenPrice:
          ((map['currentTokenPriceCents'] as num?)?.toDouble() ?? 0) / 100,
      totalTokensIssued: (map['totalTokensIssued'] as num?)?.toInt() ?? 0,
      totalTokensAvailable: (map['totalTokensAvailable'] as num?)?.toInt() ?? 0,
      totalRaised: ((map['capitalRaisedCents'] as num?)?.toDouble() ?? 0) / 100,
      stage: StartupStage.values.byName(map['stage'] ?? 'nova'),
      thumbnailPath: map['thumbnailPath'],
      videoPath: map['videoPath'],
      tags: List<String>.from(map['tags'] ?? []),
      isInvestor: map['isInvestor'] == true,
      founders: (map['founders'] as List? ?? [])
          .map((f) => FounderModel.fromMap(Map<String, dynamic>.from(f)))
          .toList(),
      externalMembers: (map['externalMember'] as List? ?? [])
          .map((e) => ExternalMemberModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
