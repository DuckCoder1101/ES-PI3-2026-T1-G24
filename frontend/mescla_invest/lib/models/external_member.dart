/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

class ExternalMember {
  final String name;
  final String role;

  ExternalMember({required this.name, required this.role});

  factory ExternalMember.fromMap(Map<String, dynamic> map) {
    return ExternalMember(name: map['name'] ?? '', role: map['role'] ?? '');
  }
}
