import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/auth_provider.dart';
import '../../main.dart' show isFirebaseInitialized;
import '../../widgets/mood_card.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load mood entries when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().loadMoodEntries();
    });
  }

  Future<void> _refreshEntries() async {
    await context.read<MoodProvider>().loadMoodEntries();
  }

  Future<void> _syncWithCloud() async {
    final authProvider = context.read<AuthProvider>();
    final moodProvider = context.read<MoodProvider>();

    if (authProvider.userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to sync with cloud'),
        ),
      );
      return;
    }

    await moodProvider.syncFromCloud(authProvider.userId!);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Synced with cloud successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider>();
    final authProvider = context.watch<AuthProvider>();
    final entries = moodProvider.moodEntries;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshEntries,
        child: entries.isEmpty
            ? _buildEmptyState()
            : Column(
                children: [
                  // Sync button (only show if Firebase is initialized and user is authenticated)
                  if (isFirebaseInitialized && authProvider.isAuthenticated)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: OutlinedButton.icon(
                        onPressed:
                            moodProvider.isLoading ? null : _syncWithCloud,
                        icon: const Icon(Icons.cloud_sync),
                        label: const Text('Sync with Cloud'),
                      ),
                    ),
                  // List of mood entries
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return MoodCard(
                          entry: entry,
                          onTap: () {
                            _showEntryDetails(context, entry);
                          },
                          onDelete: () async {
                            final success = await moodProvider.deleteMoodEntry(
                              entry.id,
                              authProvider.userId,
                            );

                            if (!mounted) return;

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Entry deleted'),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(moodProvider.errorMessage ??
                                      'Failed to delete entry'),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          },
                        );
                      },
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
            Icons.history,
            size: 100,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No mood entries yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your daily mood',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // This would switch to the Add Mood tab in the actual implementation
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Entry'),
          ),
        ],
      ),
    );
  }

  void _showEntryDetails(BuildContext context, entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(entry.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            const Text('Mood Entry'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(entry.date.toString().split('.')[0]),
              contentPadding: EdgeInsets.zero,
            ),
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const Divider(),
              const Text(
                'Note:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(entry.note!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
