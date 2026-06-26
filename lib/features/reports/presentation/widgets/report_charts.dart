import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/formatters/app_formatters.dart';
import '../../domain/entities/report_models.dart';

class QuotesByStatusPieChart extends StatelessWidget {
  const QuotesByStatusPieChart({super.key, required this.data});

  final List<ReportQuoteStatus> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
    ];

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final color = colors[index % colors.length];

            return PieChartSectionData(
              color: color,
              value: item.count.toDouble(),
              title: '${item.count}',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              badgeWidget: _Badge(item.status.toUpperCase(), color: color),
              badgePositionPercentageOffset: 1.4,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class TopProductsBarChart extends StatelessWidget {
  const TopProductsBarChart({super.key, required this.data});

  final List<ReportTopProduct> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    final theme = Theme.of(context);

    // Solo mostramos los top 5 para no saturar el grafico
    final displayData = data.take(5).toList();
    double maxY = 0;
    for (final item in displayData) {
      if (item.quantity > maxY) {
        maxY = item.quantity.toDouble();
      }
    }
    // Darle un 20% de margen arriba
    maxY = maxY * 1.2;
    if (maxY == 0) {
      maxY = 10;
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${displayData[group.x.toInt()].productName}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${rod.toY.toInt()} uds',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= displayData.length) {
                    return const SizedBox();
                  }
                  final name = displayData[value.toInt()].productName;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      name.length > 10 ? '${name.substring(0, 8)}...' : name,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                reservedSize: 32,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value == maxY) return const SizedBox();
                  return Text(
                    value.toInt().toString(),
                    style: theme.textTheme.bodySmall,
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY / 4).ceilToDouble() > 0
                ? (maxY / 4).ceilToDouble()
                : 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.outlineVariant.withAlpha(50),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: displayData.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: item.quantity.toDouble(),
                  color: theme.colorScheme.primary,
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class MonthlySalesLineChart extends StatelessWidget {
  const MonthlySalesLineChart({super.key, required this.data});

  final List<ReportMonthlySale> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    final theme = Theme.of(context);

    double maxY = 0;
    for (final item in data) {
      if (item.totalAmount > maxY) {
        maxY = item.totalAmount;
      }
    }
    maxY = maxY * 1.2;
    if (maxY == 0) {
      maxY = 1000;
    }

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.totalAmount);
    }).toList();

    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: (maxY / 4) > 0 ? maxY / 4 : 100,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.outlineVariant.withAlpha(50),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: theme.colorScheme.outlineVariant.withAlpha(50),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox();
                  }
                  final period = data[index].period; // YYYY-MM
                  final parts = period.split('-');
                  final month = parts.length > 1 ? parts[1] : period;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _getMonthName(month),
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxY / 4) > 0 ? maxY / 4 : 100,
                getTitlesWidget: (value, meta) {
                  if (value == maxY || value == 0) {
                    return const SizedBox();
                  }
                  return Text(
                    '\$${(value / 1000).toStringAsFixed(1)}k',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  );
                },
                reservedSize: 42,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: data.length.toDouble() - 1,
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.green,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withAlpha(50),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final item = data[spot.x.toInt()];
                  return LineTooltipItem(
                    '${item.period}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: AppFormatters.formatUsd(item.totalAmount),
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '\n${item.totalQuotes} cotizaciones',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(String monthNumber) {
    switch (monthNumber) {
      case '01':
        return 'Ene';
      case '02':
        return 'Feb';
      case '03':
        return 'Mar';
      case '04':
        return 'Abr';
      case '05':
        return 'May';
      case '06':
        return 'Jun';
      case '07':
        return 'Jul';
      case '08':
        return 'Ago';
      case '09':
        return 'Sep';
      case '10':
        return 'Oct';
      case '11':
        return 'Nov';
      case '12':
        return 'Dic';
      default:
        return monthNumber;
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
