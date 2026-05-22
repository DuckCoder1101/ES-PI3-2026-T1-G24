/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

class ExternalMemberModel {
  final String name;
  final String role;

  ExternalMemberModel({required this.name, required this.role});

  factory ExternalMemberModel.fromMap(Map<String, dynamic> map) {
    return ExternalMemberModel(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
    );
  }
}
