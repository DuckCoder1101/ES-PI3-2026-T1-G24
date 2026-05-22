/*
 * Autor: Cristian Fava
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

class StartupModel {
  final String id;
  final String name;
  final String description;
  final String shortDescription;
  final double tokenPrice;
  final int totalTokensIssued;
  final int totalTokensAvailable;
  final double totalRaised;
  final StartupStage stage;

  final String? thumbnailPath;
  final String? videoPath;
  final String? executiveSumaryPath;

  String? thumbnailUrl;
  String? videoUrl;

  final List<String> tags;

  final List<FounderModel> founders;
  final List<ExternalMemberModel> externalMembers;

  final bool isInvestor;

  StartupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.executiveSumaryPath,
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

  factory StartupModel.fromMap(Map<String, dynamic> map) {
    return StartupModel(
      id: map["id"],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      tokenPrice:
          ((map['currentTokenPriceCents'] as num?)?.toDouble() ?? 0) / 100,
      totalTokensIssued: (map['totalTokensIssued'] as num?)?.toInt() ?? 0,
      totalTokensAvailable: (map['totalTokensAvailable'] as num?)?.toInt() ?? 0,
      totalRaised: ((map['capitalRaisedCents'] as num?)?.toDouble() ?? 0) / 100,
      stage: StartupStage.values.byName(map["stage"] ?? "nova"),

      executiveSumaryPath: map['executiveSummaryPath'],
      thumbnailPath: map["thumbnailPath"],
      videoPath: map["videoPath"],

      tags: List<String>.from(map['tags'] ?? []),
      isInvestor: map["isInvestor"] == true,

      founders: (map['founders'] as List? ?? [])
          .map((f) => FounderModel.fromMap(Map<String, dynamic>.from(f)))
          .toList(),

      externalMembers: (map['externalMember'] as List? ?? [])
          .map((e) => ExternalMemberModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class StartupListDTO {
  final String id;
  final String name;
  final String shortDescription;
  final double tokenPrice;
  final int totalTokensAvailable;
  final StartupStage stage;
  final String? thumbnailPath;

  final List<String> tags;
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

  factory StartupListDTO.fromMap(Map<String, dynamic> map) {
    return StartupListDTO(
      id: map["id"],
      name: map['name'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      tokenPrice:
          ((map['currentTokenPriceCents'] as num?)?.toDouble() ?? 0) / 100,
      totalTokensAvailable: (map['totalTokensAvailable'] as num?)?.toInt() ?? 0,
      stage: StartupStage.values.byName(map["stage"] ?? "nova"),
      thumbnailPath: map["thumbnailPath"],
    );
  }
}

class StartupResumeDTO {
  final String id;
  final String name;

  const StartupResumeDTO({required this.id, required this.name});

  factory StartupResumeDTO.fromMap(Map<String, dynamic> rawMap) {
    return StartupResumeDTO(id: rawMap["id"], name: rawMap["name"]);
  }
}
