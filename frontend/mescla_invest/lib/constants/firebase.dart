// Autor: Cristian Fava
// RA: 25000636

import 'package:cloud_functions/cloud_functions.dart';

import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFunctions functions = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );

  static final FirebaseAuth auth = FirebaseAuth.instance;

  static void init() {
    functions.useFunctionsEmulator('localhost', 5001);
    // auth.useAuthEmulator('localhost', 9099);
  }
}
