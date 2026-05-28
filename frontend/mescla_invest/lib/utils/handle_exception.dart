/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';

void handleException({
  required dynamic err,
  required StackTrace stack,
  required BuildContext context,
}) {
  if (err is FirebaseException) {
    debugPrint("Erro: $err | Stack: $stack");
    final String errorMessage = switch (err.code) {
      "internal" =>
        "Não foi possível efetuar a ação. Tente novamente mais tarde!",
      "invalid-credential" ||
      "user-not-found" ||
      "wrong-password" => "Email ou senha inválidos!",
      "invalid-email" => "Email inválido!",
      "email-already-in-use" => "Email já utilizado por outro usuário!",
      _ =>
        err.message ??
            "Não foi possível efetuar a ação. Tente novamente mais tarde!",
    };

    showSnackbar(msg: errorMessage, context: context, isError: true);
  } else {
    debugPrint("Erro: $err | Stack: $stack");
    showSnackbar(
      msg: "Não foi possível efetuar a ação. Contate os desenvolvedores",
      context: context,
      isError: true,
    );
  }
}
