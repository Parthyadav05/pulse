import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../utils/constants.dart';

class MoodTrendChart extends StatelessWidget {
  final List<MoodEntry> entries;
  final int days;

  const MoodTrendChart({
    super.key,
    required this.entries,
    this.days = 7,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('No data to display'),
      );
    }

    final data = _prepareChartData();

    if (data.isEmpty) {
      return const Center(
        child: Text('Not enough data for trend analysis'),
      );
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return _buildBottomTitle(value.toInt(), context);
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return _buildLeftTitle(value.toInt());
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
                left: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            minX: 0,
            maxX: (days - 1).toDouble(),
            minY: -1,
            maxY: 1,
            lineBarsData: [
              LineChartBarData(
                spots: data,
                isCurved: true,
                color: AppConstants.primaryColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    Color color;
                    if (spot.y > 0.3) {
                      color = AppConstants.positiveColor;
                    } else if (spot.y < -0.3) {
                      color = AppConstants.negativeColor;
                    } else {
                      color = AppConstants.neutralColor;
                    }
                    return FlDotCirclePainter(
                      radius: 4,
                      color: color,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryColor.withOpacity(0.3),
                      AppConstants.primaryColor.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final date = DateTime.now()
                        .subtract(Duration(days: days - 1 - spot.x.toInt()));
                    final sentiment = spot.y > 0
                        ? 'Positive'
                        : spot.y < 0
                            ? 'Negative'
                            : 'Neutral';
                    return LineTooltipItem(
                      '${DateFormat('MMM dd').format(date)}\n$sentiment',
                      const TextStyle(
                        color: Colors.white,
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
    );
  }

  List<FlSpot> _prepareChartData() {
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 0; i < days; i++) {
      final targetDate = now.subtract(Duration(days: days - 1 - i));
      final dayEntries = entries.where((entry) {
        return entry.date.year == targetDate.year &&
            entry.date.month == targetDate.month &&
            entry.date.day == targetDate.day;
      }).toList();

      if (dayEntries.isNotEmpty) {
        final avgSentiment =
            dayEntries.map((e) => e.sentiment).reduce((a, b) => a + b) /
                dayEntries.length;
        spots.add(FlSpot(i.toDouble(), avgSentiment));
      }
    }

    return spots;
  }

  Widget _buildBottomTitle(int index, BuildContext context) {
    if (index < 0 || index >= days) return const SizedBox.shrink();

    final date = DateTime.now().subtract(Duration(days: days - 1 - index));

    // Show every other day for 7 days, every 5 days for 30 days
    final interval = days <= 7 ? 1 : 5;
    if (index % interval != 0 && index != 0 && index != days - 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        DateFormat('MMM dd').format(date),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildLeftTitle(int value) {
    String text;
    switch (value) {
      case 1:
        text = 'Positive';
        break;
      case 0:
        text = 'Neutral';
        break;
      case -1:
        text = 'Negative';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
