import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_entry.dart';
import '../utils/constants.dart';

class EmojiFrequencyChart extends StatelessWidget {
  final List<MoodEntry> entries;

  const EmojiFrequencyChart({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('No data to display'),
      );
    }

    final emojiCounts = _calculateEmojiCounts();
    final sortedEmojis = emojiCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 8 emojis
    final topEmojis = sortedEmojis.take(8).toList();

    if (topEmojis.isEmpty) {
      return const Center(
        child: Text('No data to display'),
      );
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxCount(topEmojis).toDouble() * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final emoji = topEmojis[groupIndex].key;
                  final count = topEmojis[groupIndex].value;
                  return BarTooltipItem(
                    '$emoji\n$count ${count == 1 ? 'time' : 'times'}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
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
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= topEmojis.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        topEmojis[index].key,
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  },
                  reservedSize: 32,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: _getInterval(topEmojis),
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    );
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
            barGroups: List.generate(
              topEmojis.length,
              (index) {
                final emoji = topEmojis[index].key;
                final count = topEmojis[index].value;
                final sentiment = AppConstants.getSentiment(emoji);

                Color barColor;
                if (sentiment > 0) {
                  barColor = AppConstants.positiveColor;
                } else if (sentiment < 0) {
                  barColor = AppConstants.negativeColor;
                } else {
                  barColor = AppConstants.neutralColor;
                }

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: count.toDouble(),
                      color: barColor,
                      width: 22,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: _getMaxCount(topEmojis).toDouble() * 1.2,
                        color: barColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                );
              },
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _getInterval(topEmojis),
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Map<String, int> _calculateEmojiCounts() {
    final counts = <String, int>{};
    for (var entry in entries) {
      counts[entry.emoji] = (counts[entry.emoji] ?? 0) + 1;
    }
    return counts;
  }

  int _getMaxCount(List<MapEntry<String, int>> emojis) {
    if (emojis.isEmpty) return 10;
    return emojis.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }

  double _getInterval(List<MapEntry<String, int>> emojis) {
    final maxCount = _getMaxCount(emojis);
    if (maxCount <= 5) return 1;
    if (maxCount <= 10) return 2;
    if (maxCount <= 20) return 5;
    return 10;
  }
}
