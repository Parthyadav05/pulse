import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';

class SentimentPieChart extends StatelessWidget {
  final int positiveCount;
  final int neutralCount;
  final int negativeCount;

  const SentimentPieChart({
    super.key,
    required this.positiveCount,
    required this.neutralCount,
    required this.negativeCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = positiveCount + neutralCount + negativeCount;

    if (total == 0) {
      return const Center(
        child: Text('No data to display'),
      );
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: _buildSections(),
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {},
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = positiveCount + neutralCount + negativeCount;
    final sections = <PieChartSectionData>[];

    // Positive section
    if (positiveCount > 0) {
      sections.add(
        PieChartSectionData(
          color: AppConstants.positiveColor,
          value: positiveCount.toDouble(),
          title: '${((positiveCount / total) * 100).toStringAsFixed(0)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    // Neutral section
    if (neutralCount > 0) {
      sections.add(
        PieChartSectionData(
          color: AppConstants.neutralColor,
          value: neutralCount.toDouble(),
          title: '${((neutralCount / total) * 100).toStringAsFixed(0)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    // Negative section
    if (negativeCount > 0) {
      sections.add(
        PieChartSectionData(
          color: AppConstants.negativeColor,
          value: negativeCount.toDouble(),
          title: '${((negativeCount / total) * 100).toStringAsFixed(0)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }
}
