import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mescla_invest/models/startup/price_point_model.dart';
import 'package:mescla_invest/models/startup/question_model.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';
import 'package:mescla_invest/models/startup/startup_news_model.dart';

class StartupService {
  static Future<String> loadFile(String thumbnailPath) async {
    try {
      return await FirebaseStorage.instance.ref(thumbnailPath).getDownloadURL();
    } catch (_) {
      rethrow;
    }
  }

  static Future<void> downloadPitch(String startupId, String localPath) async {
    try {
      final File file = File(localPath);
      await FirebaseStorage.instance
          .ref("startups/$startupId/pitch.pdf")
          .writeToFile(file);
    } catch (_) {
      rethrow;
    }
  }

  static Future<StartupModel> getStartupById(String startupId) async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getStartupById')
          .call({'startupId': startupId});

      final startup = StartupModel.fromMap(
        Map<String, dynamic>.from(response.data),
      );

      if (startup.thumbnailPath != null) {
        startup.thumbnailUrl = await loadFile(startup.thumbnailPath!);
      }

      if (startup.videoPath != null) {
        startup.videoUrl = await loadFile(startup.videoPath!);
      }

      return startup;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<StartupModel>> getStartupsList({
    required int offset,
    required int limit,
    required StartupStageFilter stageFilter,
    required String nameFilter,
  }) async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getStartupsList')
          .call({
            'offset': offset.toInt(),
            'limit': limit.toInt(),
            'filter': {'stage': stageFilter.name, 'name': nameFilter},
          });

      final data = response.data as Map<dynamic, dynamic>;
      final List rawList = data['startups'] ?? [];

      final futures = rawList.map((s) async {
        final startup = StartupModel.fromMap(Map<String, dynamic>.from(s));

        if (startup.thumbnailPath != null) {
          startup.thumbnailUrl = await loadFile(startup.thumbnailPath!);
        }
        return startup;
      }).toList();

      return await Future.wait(futures);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<StartupResumeDTO>> getAllStartupsResumes() async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getStartupResumes')
          .call();

      final data = response.data as Map<dynamic, dynamic>;
      final List rawList = data['startups'] ?? [];

      return rawList
          .map(
            (map) => StartupResumeDTO.fromMap(Map<String, dynamic>.from(map)),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
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
        'visibility': visibility.name,
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

  static Future<List<PricePoint>> getTokenPriceHistory({
    required String startupId,
    required DateInterval interval,
  }) async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getTokenPriceHistory')
          .call({'startupId': startupId, 'dateInterval': interval.value});

      final data = response.data as Map<dynamic, dynamic>;
      final List rawList = data['priceHistory'] ?? [];

      return rawList
          .map((e) => PricePoint.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<StartupNewsModel>> getStartupNews({
    required String startupId,
  }) async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getStartupNews')
          .call({'startupId': startupId});

      final data = response.data as Map<dynamic, dynamic>;
      final List rawList = data['news'] ?? [];

      return rawList
          .map((n) => StartupNewsModel.fromMap(Map<String, dynamic>.from(n)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Histórico de todas as startups nas quais o usuário possui tokens
  static Future<List<StartupPriceSeries>> getInvestedStartupsPriceHistory({
    required DateInterval interval,
  }) async {
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('getInvestedStartupsPriceHistory')
          .call({'dateInterval': interval.value});

      final data = response.data as Map<dynamic, dynamic>;
      final List rawList = data['startups'] ?? [];

      return rawList
          .map((e) => StartupPriceSeries.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
