import 'package:flutter/material.dart';

/// Analytics card used for "Total Faces" and "Smiling Percentage".
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.caption,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(title, style: textTheme.titleSmall),
            if (caption != null) ...[
              const SizedBox(height: 4),
              Text(
                caption!,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
