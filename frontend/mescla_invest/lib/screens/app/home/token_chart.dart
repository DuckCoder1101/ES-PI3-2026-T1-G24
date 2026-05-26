// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TokenChart extends StatefulWidget {
  const TokenChart({super.key});

  @override
  State<TokenChart> createState() => _TokenChartState();
}

class _TokenChartState extends State<TokenChart> {
  static const Color verdeMescla = Color(0xFF7FDD3A);
  String _periodoSelecionado = 'Diário';

  final List<String> _periodos = ['Diário', 'Semanal', 'Mensal', '6M', 'YTD'];

  final Map<String, List<FlSpot>> _dadosGrafico = {
    'Diário': [
      FlSpot(0, 800),
      FlSpot(1, 850),
      FlSpot(2, 820),
      FlSpot(3, 900),
      FlSpot(4, 950),
      FlSpot(5, 1000),
      FlSpot(6, 1215),
    ],
    'Semanal': [
      FlSpot(0, 600),
      FlSpot(1, 700),
      FlSpot(2, 750),
      FlSpot(3, 800),
      FlSpot(4, 900),
      FlSpot(5, 1000),
      FlSpot(6, 1215),
    ],
    'Mensal': [
      FlSpot(0, 400),
      FlSpot(1, 500),
      FlSpot(2, 600),
      FlSpot(3, 750),
      FlSpot(4, 900),
      FlSpot(5, 1100),
      FlSpot(6, 1215),
    ],
    '6M': [
      FlSpot(0, 200),
      FlSpot(1, 400),
      FlSpot(2, 600),
      FlSpot(3, 800),
      FlSpot(4, 1000),
      FlSpot(5, 1100),
      FlSpot(6, 1215),
    ],
    'YTD': [
      FlSpot(0, 100),
      FlSpot(1, 300),
      FlSpot(2, 500),
      FlSpot(3, 700),
      FlSpot(4, 900),
      FlSpot(5, 1100),
      FlSpot(6, 1215),
    ],
  };

  final Map<String, List<String>> _labelsPeriodo = {
    'Diário': ['19:00', '12:00', '18:00'],
    'Semanal': ['Seg', 'Qua', 'Dom'],
    'Mensal': ['Sem 1', 'Sem 2', 'Sem 4'],
    '6M': ['Jan', 'Mar', 'Jun'],
    'YTD': ['Jan', 'Abr', 'Dez'],
  };

  @override
  Widget build(BuildContext context) {
    final spots = _dadosGrafico[_periodoSelecionado]!;
    final labels = _labelsPeriodo[_periodoSelecionado]!;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
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

          // Filtros de período
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _periodos.map((p) {
                final isSelected = _periodoSelecionado == p;
                return GestureDetector(
                  onTap: () => setState(() => _periodoSelecionado = p),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? verdeMescla : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      p,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white54,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Gráfico
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == maxY) {
                          return Text(
                            'R\$ ${value.toInt()}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx == 0) {
                          return Text(
                            labels[0],
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          );
                        }
                        if (idx == 3) {
                          return Text(
                            labels[1],
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          );
                        }
                        if (idx == 6) {
                          return Text(
                            labels[2],
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: verdeMescla,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) => spot == spots.last,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: verdeMescla.withValues(alpha: 0.15),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          'R\$ ${spot.y.toInt()}',
                          const TextStyle(
                            color: verdeMescla,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}