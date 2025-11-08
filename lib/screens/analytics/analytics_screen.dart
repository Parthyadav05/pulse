import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mood_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/sentiment_pie_chart.dart';
import '../../widgets/mood_trend_chart.dart';
import '../../widgets/emoji_frequency_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedDays = 7; // For trend chart

  @override
  void initState() {
    super.initState();
    // Ensure data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().loadMoodEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider>();
    final totalEntries = moodProvider.totalEntries;
    final positiveEntries = moodProvider.positiveEntries;
    final negativeEntries = moodProvider.negativeEntries;
    final neutralEntries = moodProvider.neutralEntries;
    final mostCommonMood = moodProvider.mostCommonMood;

    if (totalEntries == 0) {
      return _buildEmptyState();
    }

    final positivePercentage =
        totalEntries > 0 ? (positiveEntries / totalEntries * 100) : 0.0;
    final negativePercentage =
        totalEntries > 0 ? (negativeEntries / totalEntries * 100) : 0.0;
    final neutralPercentage =
        totalEntries > 0 ? (neutralEntries / totalEntries * 100) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Overview card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'Your Wellness Journey',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total entries tracked',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    totalEntries.toString(),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sentiment Pie Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sentiment Distribution',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SentimentPieChart(
                    positiveCount: positiveEntries,
                    neutralCount: neutralEntries,
                    negativeCount: negativeEntries,
                  ),
                  const SizedBox(height: 16),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(
                        context,
                        'Positive',
                        AppConstants.positiveColor,
                      ),
                      _buildLegendItem(
                        context,
                        'Neutral',
                        AppConstants.neutralColor,
                      ),
                      _buildLegendItem(
                        context,
                        'Negative',
                        AppConstants.negativeColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Mood Trend Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mood Trend',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 7, label: Text('7D')),
                          ButtonSegment(value: 30, label: Text('30D')),
                        ],
                        selected: {_selectedDays},
                        onSelectionChanged: (Set<int> selected) {
                          setState(() {
                            _selectedDays = selected.first;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Average daily sentiment over time',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 16),
                  MoodTrendChart(
                    entries: moodProvider.moodEntries,
                    days: _selectedDays,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Emoji Frequency Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emoji Frequency',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your most used mood emojis',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 16),
                  EmojiFrequencyChart(entries: moodProvider.moodEntries),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sentiment breakdown
          Text(
            'Detailed Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Positive mood card
          _buildSentimentCard(
            context: context,
            title: 'Positive Days',
            count: positiveEntries,
            percentage: positivePercentage,
            color: AppConstants.positiveColor,
            icon: Icons.sentiment_very_satisfied,
          ),
          const SizedBox(height: 12),

          // Neutral mood card
          _buildSentimentCard(
            context: context,
            title: 'Neutral Days',
            count: neutralEntries,
            percentage: neutralPercentage,
            color: AppConstants.neutralColor,
            icon: Icons.sentiment_neutral,
          ),
          const SizedBox(height: 12),

          // Negative mood card
          _buildSentimentCard(
            context: context,
            title: 'Negative Days',
            count: negativeEntries,
            percentage: negativePercentage,
            color: AppConstants.negativeColor,
            icon: Icons.sentiment_dissatisfied,
          ),
          const SizedBox(height: 24),

          // Most common mood
          if (mostCommonMood != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Most Common Mood',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      mostCommonMood,
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is how you feel most often',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Insights card
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Insights',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getInsightMessage(
                        positivePercentage, negativePercentage),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentCard({
    required BuildContext context,
    required String title,
    required int count,
    required double percentage,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count ${count == 1 ? 'entry' : 'entries'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 100,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No analytics yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your moods to see insights',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  String _getInsightMessage(double positivePercentage, double negativePercentage) {
    if (positivePercentage >= 70) {
      return "You're doing great! You've been feeling positive most of the time. Keep up the good work!";
    } else if (positivePercentage >= 50) {
      return "You're maintaining a good balance. Remember to take time for self-care.";
    } else if (negativePercentage >= 50) {
      return "You've been experiencing some challenging times. Consider reaching out to friends or a professional for support.";
    } else {
      return "Your mood varies throughout the week. Try to identify patterns and what influences your mood.";
    }
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
