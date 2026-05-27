// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/formatters/str_formaters.dart';
import 'package:mescla_invest/models/startup/price_point_model.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';
import 'package:mescla_invest/services/startup_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';

const List<Color> _kSeriesColors = [
  Color(0xFF7FDD3A),
  Color(0xFF4FC3F7),
  Color(0xFFFFB74D),
  Color(0xFFCE93D8),
  Color(0xFFEF5350),
  Color(0xFF4DB6AC),
  Color(0xFFFFF176),
];

Color _colorFor(int index) => _kSeriesColors[index % _kSeriesColors.length];

class TokenChart extends StatefulWidget {
  final ValueNotifier<int> refreshTrigger;

  const TokenChart({super.key, required this.refreshTrigger});

  @override
  State<TokenChart> createState() => _TokenChartState();
}

class _TokenChartState extends State<TokenChart> {
  static const Color _verde = Color(0xFF7FDD3A);
  static const Color _cardColor = Color(0xFF1E1E1E);
  static const Color _fieldDark = Color(0xFF2A2A2A);

  DateInterval _selectedInterval = DateInterval.oneMonth;

  List<StartupPriceSeries> _series = [];
  bool _isLoading = true;

  // Índice da série em destaque; -1 = todas visíveis
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Escuta o gatilho de atualização vindo do widget pai
    widget.refreshTrigger.addListener(_loadData);
  }

  @override
  void dispose() {
    // Remove o listener para evitar leaks de memória
    widget.refreshTrigger.removeListener(_loadData);
    super.dispose();
  }

  // Carregamento
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hoveredIndex = -1;
    });

    try {
      final raw = await StartupService.getInvestedStartupsPriceHistory(
        interval: _selectedInterval,
      );
      if (mounted) setState(() => _series = raw);
    } catch (err, stack) {
      if (mounted) {
        handleException(err: err, stack: stack, context: context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Apreciação de Tokens',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildIntervalSelector(),
          const SizedBox(height: 20),
          _buildBody(),
        ],
      ),
    );
  }

  // Seletor de intervalo
  Widget _buildIntervalSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DateInterval.values.map((interval) {
          final isSelected = _selectedInterval == interval;
          return GestureDetector(
            onTap: () {
              if (_selectedInterval == interval) return;
              setState(() => _selectedInterval = interval);
              _loadData();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _verde : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                interval.value,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Corpo (loading / erro / vazio / gráfico)
  Widget _buildBody() {
    if (_isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF7FDD3A)),
        ),
      );
    }

    if (_series.isEmpty) return _buildEmpty();
    return _buildChart();
  }

  // Gráfico multi-linha
  Widget _buildChart() {
    double globalMinY = double.infinity;
    double globalMaxY = double.negativeInfinity;

    final List<LineChartBarData> bars = [];

    for (int i = 0; i < _series.length; i++) {
      final serie = _series[i];
      final color = _colorFor(i);
      final isDimmed = _hoveredIndex != -1 && _hoveredIndex != i;

      final spots = serie.points
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value.priceReais))
          .toList();

      for (final s in spots) {
        if (s.y < globalMinY) globalMinY = s.y;
        if (s.y > globalMaxY) globalMaxY = s.y;
      }

      bars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: color.withValues(alpha: isDimmed ? 0.2 : 1.0),
          barWidth: isDimmed ? 1.5 : 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: spots.length <= 10 && !isDimmed,
            getDotPainter: (_, _, _, _) => FlDotCirclePainter(
              radius: 3.5,
              color: color,
              strokeWidth: 1.5,
              strokeColor: Colors.black,
            ),
          ),
          belowBarData: BarAreaData(
            show: !isDimmed,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.18),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      );
    }

    final range = (globalMaxY - globalMinY).abs();
    final padding = (range * 0.15).clamp(0.5, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegend(),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: globalMinY - padding,
              maxY: globalMaxY + padding,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (range + padding * 2) / 4,
                getDrawingHorizontalLine: (_) =>
                    const FlLine(color: Colors.white10, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    getTitlesWidget: (value, _) => Text(
                      formatCurrency(value),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: _bottomInterval(_maxPointCount()),
                    getTitlesWidget: (value, _) {
                      final refSerie = _referenceSeries();
                      final idx = value.toInt();
                      if (refSerie == null ||
                          idx < 0 ||
                          idx >= refSerie.points.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          formatDate(refSerie.points[idx].createdAt),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 9,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF1E1E1E),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((s) {
                      final color = _colorFor(s.barIndex);
                      final serie = _series[s.barIndex];
                      final idx = s.x.toInt();
                      final date = idx < serie.points.length
                          ? formatDate(serie.points[idx].createdAt)
                          : '';
                      return LineTooltipItem(
                        '${serie.startupName}\n',
                        TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: '${formatCurrency(s.y)}  $date',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: bars,
            ),
          ),
        ),
      ],
    );
  }

  // Legenda interativa
  Widget _buildLegend() {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: _series.asMap().entries.map((entry) {
        final i = entry.key;
        final serie = entry.value;
        final color = _colorFor(i);
        final isActive = _hoveredIndex == -1 || _hoveredIndex == i;

        return GestureDetector(
          onTap: () {
            setState(() {
              _hoveredIndex = (_hoveredIndex == i) ? -1 : i;
            });
          },
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: isActive ? 1.0 : 0.35,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _fieldDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? color : Colors.white12,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    serie.startupName,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmpty() {
    return const SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart_rounded, color: Colors.white12, size: 48),
            SizedBox(height: 12),
            Text(
              'Você ainda não possui investimentos.',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  int _maxPointCount() =>
      _series.map((s) => s.points.length).reduce((a, b) => a > b ? a : b);

  StartupPriceSeries? _referenceSeries() {
    if (_series.isEmpty) return null;
    return _series.reduce((a, b) => a.points.length >= b.points.length ? a : b);
  }

  double _bottomInterval(int count) {
    if (count <= 6) return 1;
    if (count <= 12) return 2;
    if (count <= 30) return 5;
    return (count / 5).ceilToDouble();
  }
}
