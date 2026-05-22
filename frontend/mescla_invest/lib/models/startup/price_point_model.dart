/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:mescla_invest/formatters/timestamp_to_date.dart';

enum DateInterval {
  oneMonth,
  sixMonths,
  oneYear,
  fiveYears;

  String get value {
    return switch (this) {
      oneMonth => '1M',
      sixMonths => '6M',
      oneYear => '1Y',
      fiveYears => '5Y',
    };
  }

  String get label {
    return switch (this) {
      oneMonth => '1M',
      sixMonths => '6M',
      oneYear => '1A',
      fiveYears => '5A',
    };
  }
}

class PricePoint {
  final int priceCents;
  final double occupancyRate;
  final String triggerId;

  final DateTime createdAt;

  const PricePoint({
    required this.priceCents,
    required this.occupancyRate,
    required this.triggerId,
    required this.createdAt,
  });

  double get priceReais => priceCents / 100;

  factory PricePoint.fromMap(Map<String, dynamic> map) {
    return PricePoint(
      priceCents: (map['priceCents'] as num?)?.toInt() ?? 0,
      occupancyRate: (map['occupancyRate'] as num?)?.toDouble() ?? 0.0,
      triggerId: map['triggerId'] as String? ?? '',
      createdAt: parseTimestamp(map["createdAt"]) ?? DateTime.now(),
    );
  }
}
