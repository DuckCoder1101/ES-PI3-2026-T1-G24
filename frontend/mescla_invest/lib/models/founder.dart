/*
 * Autor: Cristian Fava
 * RA: 25000636
 */

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
