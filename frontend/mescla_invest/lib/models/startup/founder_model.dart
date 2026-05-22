/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

class FounderModel {
  final String name;
  final String role;
  final double equityPercent;

  FounderModel({
    required this.name,
    required this.role,
    required this.equityPercent,
  });

  factory FounderModel.fromMap(Map<String, dynamic> map) {
    return FounderModel(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      equityPercent: (map['equityPercent'] ?? 0).toDouble(),
    );
  }
}
