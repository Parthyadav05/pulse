import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MoodEmojiSelector extends StatefulWidget {
  final Function(String emoji, int sentiment) onEmojiSelected;
  final String? selectedEmoji;

  const MoodEmojiSelector({
    super.key,
    required this.onEmojiSelected,
    this.selectedEmoji,
  });

  @override
  State<MoodEmojiSelector> createState() => _MoodEmojiSelectorState();
}

class _MoodEmojiSelectorState extends State<MoodEmojiSelector>
    with SingleTickerProviderStateMixin {
  String? _selectedEmoji;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedEmoji = widget.selectedEmoji;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling today?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: moodEmojiList.length,
              itemBuilder: (context, index) {
                final moodData = moodEmojiList[index];
                final isSelected = _selectedEmoji == moodData.emoji;

                return _buildEmojiButton(
                  moodData: moodData,
                  isSelected: isSelected,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiButton({
    required MoodEmojiData moodData,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEmoji = moodData.emoji;
        });
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
        widget.onEmojiSelected(moodData.emoji, moodData.sentiment);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: isSelected ? 1.2 : 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Text(
                    moodData.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              moodData.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
