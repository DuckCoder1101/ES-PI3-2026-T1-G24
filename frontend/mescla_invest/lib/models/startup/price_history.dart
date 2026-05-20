/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';

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

class PriceHistoryPoint {
  final int priceCents;
  final double occupancyRate;
  final String triggerId;

  final DateTime createdAt;

  const PriceHistoryPoint({
    required this.priceCents,
    required this.occupancyRate,
    required this.triggerId,
    required this.createdAt,
  });

  double get priceReais => priceCents / 100;

  factory PriceHistoryPoint.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final raw = map['createdAt'];

    if (raw is Map) {
      final seconds = (raw['_seconds'] as num?)?.toInt() ?? 0;
      parsedDate = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    } else if (raw is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(raw);
    } else {
      parsedDate = DateTime.now();
    }

    return PriceHistoryPoint(
      priceCents: (map['priceCents'] as num?)?.toInt() ?? 0,
      occupancyRate: (map['occupancyRate'] as num?)?.toDouble() ?? 0.0,
      triggerId: map['triggerId'] as String? ?? '',
      createdAt: parsedDate,
    );
  }
}

class PriceHistoryModel {
  static Future<List<PriceHistoryPoint>> getTokenPriceHistory({
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
          .map((e) => PriceHistoryPoint.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
