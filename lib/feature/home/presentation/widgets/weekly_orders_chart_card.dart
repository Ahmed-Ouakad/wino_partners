import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyOrdersChartCard extends StatelessWidget {
  const WeeklyOrdersChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title, subtitle, calendar button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Commandes Semaine Dernière',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Performance hebdomadaire',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart Section (Overlay of BarChart and LineChart)
          SizedBox(
            height: 190,
            child: Stack(
              children: [
                // BarChart providing bars, grid lines, and axis labels
                BarChart(
                  BarChartData(
                    maxY: 80,
                    minY: 0,
                    alignment: BarChartAlignment.spaceAround,
                    barTouchData: BarTouchData(enabled: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 10,
                      checkToShowHorizontalLine: (value) =>
                          value == 0 ||
                          value == 20 ||
                          value == 50 ||
                          value == 80,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withValues(alpha: 0.22),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          interval: 10,
                          getTitlesWidget: (value, meta) {
                            if (value == 0 ||
                                value == 20 ||
                                value == 50 ||
                                value == 80) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < days.length) {
                              final isHighlighted = days[index] == 'Sam';
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  days[index],
                                  style: TextStyle(
                                    color: isHighlighted
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                    fontWeight: isHighlighted
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      _buildBarGroup(0, 8, false, theme),
                      _buildBarGroup(1, 24, false, theme),
                      _buildBarGroup(2, 22, false, theme),
                      _buildBarGroup(3, 56, true, theme),
                      _buildBarGroup(4, 38, false, theme),
                      _buildBarGroup(5, 64, true, theme),
                      _buildBarGroup(6, 46, false, theme),
                    ],
                  ),
                ),

                // Overlaid LineChart with curved red line & point circles
                LineChart(
                  LineChartData(
                    minX: -0.5,
                    maxX: 6.5,
                    minY: 0,
                    maxY: 80,
                    lineTouchData: const LineTouchData(enabled: false),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          getTitlesWidget: (_, _) => const SizedBox.shrink(),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (_, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 8),
                          FlSpot(1, 32),
                          FlSpot(2, 19),
                          FlSpot(3, 57),
                          FlSpot(4, 46),
                          FlSpot(5, 66),
                          FlSpot(6, 50),
                        ],
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: theme.colorScheme.primary,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          checkToShowDot: (spot, barData) =>
                              spot.x == 3 || spot.x == 5,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                                radius: 4.5,
                                color: Colors.white,
                                strokeWidth: 2.5,
                                strokeColor: theme.colorScheme.primary,
                              ),
                        ),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Bottom Stats Summary Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildStatItem('Lundi', '135', theme.colorScheme.onSurface, theme),
                _buildStatItem('Derniers', '136', theme.colorScheme.onSurface, theme),
                _buildStatItem('En cours', '100', theme.colorScheme.secondary, theme),
                _buildStatItem('Totales', '2 836', theme.colorScheme.primary, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(
    int x,
    double y,
    bool isHighlighted,
    ThemeData theme,
  ) {
    // Jeu and Sam have darker green shade, others have soft green
    final barColor = isHighlighted
        ? const Color(0xFF4C6616)
        : theme.colorScheme.secondary.withValues(alpha: 0.7);

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: barColor,
          width: 15,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color valueColor,
    ThemeData theme,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
