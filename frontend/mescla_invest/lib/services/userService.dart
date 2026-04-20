// Autor: Cristian Fava
// RA: 25000636

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/models/user.dart';

class UserService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Busca os dados do usuário e resolve a URL da imagem no Storage
  Future<Map<String, dynamic>> getFullUserData() async {
    try {
      final result = await _functions.httpsCallable('getMe').call();

      if (result.data == null) {
        throw Exception("Usuário não encontrado no banco de dados.");
      }

      final dataMap = Map<String, dynamic>.from(result.data);
      final user = UserDocument.fromMap(dataMap);

      String? avatarDownloadUrl;
      if (user.avatarUrl.isNotEmpty) {
        avatarDownloadUrl = await _storage.ref(user.avatarUrl).getDownloadURL();
      }

      return {'user': user, 'avatarDownloadUrl': avatarDownloadUrl};
    } catch (e) {
      debugPrint("Erro no UserService: $e");
      rethrow;
    }
  }
}
