class UserDocument {
  final String uid;
  final String avatarUrl;
  final String name;
  final String email;
  final String cpf;
  final String phone;
  final DateTime createdAt;

  UserDocument({
    required this.uid,
    required this.avatarUrl,
    required this.name,
    required this.email,
    required this.cpf,
    required this.phone,
    required this.createdAt,
  });

  factory UserDocument.fromMap(Map<String, dynamic> map) {
    // Extrai o mapa do createdAt
    final createdAtMap = map['createdAt'] as Map<String, dynamic>;

    // Converte para DateTime puro
    final seconds = createdAtMap['_seconds'] as int;
    final nanos = createdAtMap['_nanoseconds'] as int;

    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      (seconds * 1000) + (nanos ~/ 1000000),
      isUtc: true,
    ).toLocal();

    return UserDocument(
      uid: map['uid'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
      phone: map['phone'] ?? '',
      createdAt: dateTime, // Agora é um DateTime comum
    );
  }
}
