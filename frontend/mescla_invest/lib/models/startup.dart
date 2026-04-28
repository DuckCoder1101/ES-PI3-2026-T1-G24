import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum StartupStage { nova, em_operacao, em_espansao }

class StartupModel {
  final String id;
  final String name;
  final String description;
  final double tokenPrice;
  final int totalTokens;
  final double totalRaised;
  final StartupStage stage;
  final String type; // 'Investidor', etc
  final String? videoPath;
  final List<String> galleryPaths;

  StartupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.tokenPrice,
    required this.totalTokens,
    required this.totalRaised,
    required this.stage,
    required this.type,
    this.videoPath,
    this.galleryPaths = const [],
  });

  factory StartupModel.fromMap(String id, Map<String, dynamic> map) {
    return StartupModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      tokenPrice: (map['tokenPrice'] ?? 0).toDouble(),
      totalTokens: map['totalTokens'] ?? 0,
      totalRaised: (map['totalRaised'] ?? 0).toDouble(),
      stage: map['stage'] ?? 'Inativo',
      type: map['type'] ?? 'Padrão',
      videoPath: map['videoPath'],
      galleryPaths: List<String>.from(map['galleryPaths'] ?? []),
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
      throw Exception("Erro ao buscar detalhes: $e");
    }
  }

  Future<String> getDownloadUrl(String path) async {
    return await FirebaseStorage.instance.ref(path).getDownloadURL();
  }
}
