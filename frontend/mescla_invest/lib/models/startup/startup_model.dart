/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:mescla_invest/models/startup/external_member_model.dart';
import 'package:mescla_invest/models/startup/founder_model.dart';
import 'package:mescla_invest/models/startup/price_point_model.dart';

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

// StartupResumeDTO — resumo mínimo retornado em listas, ordens e transações
class StartupResumeDTO {
  final String id;
  final String name;
  final bool isInvestor;
  final int currentTokenPriceCents;
  // Preço de lançamento — usado para calcular valorização percentual
  final int initialTokenPriceCents;

  double get tokenPrice => currentTokenPriceCents / 100;
  double get initialTokenPrice => initialTokenPriceCents / 100;

  /// Valorização percentual desde o lançamento.
  /// Retorna null se o preço inicial for zero (dado ausente).
  double? get appreciationPercent {
    if (initialTokenPriceCents == 0) return null;
    return ((currentTokenPriceCents - initialTokenPriceCents) /
            initialTokenPriceCents) *
        100;
  }

  const StartupResumeDTO({
    required this.id,
    required this.name,
    required this.currentTokenPriceCents,
    required this.initialTokenPriceCents,
    this.isInvestor = false,
  });

  factory StartupResumeDTO.fromMap(Map<String, dynamic> rawMap) {
    final map = rawMap.map((key, value) => MapEntry(key.trim(), value));
    final current = map['currentTokenPriceCents'] as int? ?? 0;
    return StartupResumeDTO(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      currentTokenPriceCents: current,
      // fallback: se initialTokenPriceCents não vier do backend, usa o atual
      // (valorização aparecerá como 0%, que é correto para dados legados)
      initialTokenPriceCents: map['initialTokenPriceCents'] as int? ?? current,
      isInvestor: map['isInvestor'] == true,
    );
  }
}

// StartupListDTO — item da listagem paginada de startups
class StartupListDTO {
  final String id;
  final String name;
  final String shortDescription;

  final int currentTokenPriceCents;
  double get tokenPrice => currentTokenPriceCents / 100;

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
    required this.currentTokenPriceCents,
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
      currentTokenPriceCents: map['currentTokenPriceCents'] ?? 0,
      totalTokensAvailable: (map['totalTokensAvailable'] as num?)?.toInt() ?? 0,
      stage: StartupStage.values.byName(map['stage'] ?? 'nova'),
      thumbnailPath: map['thumbnailPath'],
      tags: List<String>.from(map['tags'] ?? []),
      isInvestor: map['isInvestor'] == true,
    );
  }
}

class StartupModel {
  final String id;
  final String name;
  final String description;
  final String shortDescription;
  final String executiveSummary;

  final int currentTokenPriceCents;
  double get tokenPrice => currentTokenPriceCents / 100;

  final int totalTokensIssued;
  final int totalTokensAvailable;

  final double totalRaised;
  final StartupStage stage;

  final String? thumbnailPath;
  final String? videoPath;

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
    required this.currentTokenPriceCents,
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
      currentTokenPriceCents: map['currentTokenPriceCents'] ?? 0,
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

class StartupPriceSeries {
  final String startupId;
  final String startupName;
  final List<PricePoint> points;

  const StartupPriceSeries({
    required this.startupId,
    required this.startupName,
    required this.points,
  });

  factory StartupPriceSeries.fromMap(Map<String, dynamic> map) {
    final rawPoints = map['priceHistory'] as List? ?? [];
    return StartupPriceSeries(
      startupId: map['startupId'] as String? ?? '',
      startupName: map['startupName'] as String? ?? '',
      points: rawPoints
          .map((e) => PricePoint.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
