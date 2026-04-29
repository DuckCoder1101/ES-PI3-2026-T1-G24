import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum StartupStage { nova, em_operacao, em_espansao }

class Founder {
  final String name;
  final String role;
  final double equityPercent;

  Founder({
    required this.name,
    required this.role,
    required this.equityPercent,
  });

  factory Founder.fromMap(Map<String, dynamic> map) {
    return Founder(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      equityPercent: (map['equityPercent'] ?? 0).toDouble(),
    );
  }
}

class ExternalMember {
  final String name;
  final String role;

  ExternalMember({required this.name, required this.role});

  factory ExternalMember.fromMap(Map<String, dynamic> map) {
    return ExternalMember(name: map['name'] ?? '', role: map['role'] ?? '');
  }
}

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

  Future<String> getDownloadUrl(String path) async {
    if (path.startsWith('http')) return path;
    return await FirebaseStorage.instance.ref(path).getDownloadURL();
  }
}
