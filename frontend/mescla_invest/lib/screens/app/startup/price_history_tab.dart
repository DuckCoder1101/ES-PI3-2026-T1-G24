/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/startup/price_point_model.dart';
import 'package:mescla_invest/services/startup_service.dart';

class TabPriceHistory extends StatefulWidget {
  final String startupId;

  const TabPriceHistory({super.key, required this.startupId});

  @override
  State<TabPriceHistory> createState() => _TabPriceHistoryState();
}

class _TabPriceHistoryState extends State<TabPriceHistory> {
  DateInterval _selectedInterval = DateInterval.oneMonth;

  List<PricePoint> _points = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final points = await StartupService.getTokenPriceHistory(
        startupId: widget.startupId,
        interval: _selectedInterval,
      );
      if (mounted) setState(() => _points = points);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('FirebaseFunctionsException: ${e.message}');
      if (mounted) {
        setState(() => _errorMsg = e.message ?? 'Erro ao carregar histórico.');
      }
    } catch (e) {
      debugPrint('Erro inesperado: $e');
      if (mounted) {
        setState(() => _errorMsg = 'Erro ao carregar histórico.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HISTÓRICO DE PREÇO',
          style: TextStyle(
            color: AppColors.verdeMescla,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildIntervalSelector(),
        const SizedBox(height: 24),
        if (_isLoading)
          const SizedBox(
            height: 220,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.verdeMescla),
            ),
          )
        else if (_errorMsg != null)
          _buildError()
        else if (_points.isEmpty)
          _buildEmpty()
        else
          _buildChart(_points),
      ],
    );
  }

  // Seletor de intervalo

  Widget _buildIntervalSelector() {
    return Row(
      children: DateInterval.values.map((interval) {
        final isSelected = _selectedInterval == interval;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              if (_selectedInterval == interval) return;
              setState(() => _selectedInterval = interval);
              _loadHistory();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.verdeMescla
                    : AppColors.campoEscuro,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.verdeMescla : Colors.white12,
                ),
              ),
              child: Text(
                interval.label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Gráfico

  Widget _buildChart(List<PricePoint> points) {
    final spots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.priceReais))
        .toList();

    final prices = points.map((p) => p.priceReais).toList();
    final minY = prices.reduce((a, b) => a < b ? a : b);
    final maxY = prices.reduce((a, b) => a > b ? a : b);
    final padding = ((maxY - minY) * 0.15).clamp(0.5, double.infinity);

    final firstPrice = points.first.priceReais;
    final lastPrice = points.last.priceReais;
    final isPositive = lastPrice >= firstPrice;
    final lineColor = isPositive ? AppColors.verdeMescla : Colors.redAccent;
    final variation = firstPrice == 0
        ? 0.0
        : ((lastPrice - firstPrice) / firstPrice) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummary(lastPrice, variation, isPositive),
        const SizedBox(height: 20),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: minY - padding,
              maxY: maxY + padding,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY + padding * 2) / 4,
                getDrawingHorizontalLine: (_) =>
                    const FlLine(color: Colors.white10, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    getTitlesWidget: (value, meta) => Text(
                      'R\$${value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: _bottomInterval(points.length),
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= points.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _formatDate(points[idx].createdAt),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
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
                  getTooltipItems: (spots) => spots
                      .map(
                        (s) => LineTooltipItem(
                          'R\$ ${s.y.toStringAsFixed(2)}\n',
                          TextStyle(
                            color: lineColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: _formatDate(points[s.x.toInt()].createdAt),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: lineColor,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: spots.length <= 10,
                    getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                      radius: 4,
                      color: lineColor,
                      strokeWidth: 2,
                      strokeColor: Colors.black,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        lineColor.withValues(alpha: 0.25),
                        lineColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Cabeçalho com preço e variação

  Widget _buildSummary(double price, double variation, bool isPositive) {
    final sign = variation >= 0 ? '+' : '';
    final color = isPositive ? AppColors.verdeMescla : Colors.redAccent;
    final icon = isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          margin: const EdgeInsets.only(bottom: 3),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              Text(
                '$sign${variation.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Estados vazios / erro

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
              'Sem dados para o período selecionado.',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMsg!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Tentar novamente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.verdeMescla,
                side: const BorderSide(color: AppColors.verdeMescla),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers

  double _bottomInterval(int count) {
    if (count <= 6) return 1;
    if (count <= 12) return 2;
    if (count <= 30) return 5;
    return (count / 5).ceilToDouble();
  }

  String _formatDate(DateTime date) {
    return switch (_selectedInterval) {
      DateInterval.oneMonth => DateFormat('dd/MM').format(date),
      DateInterval.sixMonths => DateFormat('MMM/yy', 'pt_BR').format(date),
      DateInterval.oneYear => DateFormat('MMM/yy', 'pt_BR').format(date),
      DateInterval.fiveYears => DateFormat('yyyy').format(date),
    };
  }
}
