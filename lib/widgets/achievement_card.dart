import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;

  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isUnlocked
          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
          : Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              color: isUnlocked
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? null : Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isUnlocked ? Colors.grey[700] : Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUnlocked) ...[
              const SizedBox(height: 8),
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
