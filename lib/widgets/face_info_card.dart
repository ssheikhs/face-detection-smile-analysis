import 'package:flutter/material.dart';

import '../models/face_result.dart';
import 'face_box_painter.dart';

/// Card with one face's number, smile status and smile probability.
class FaceInfoCard extends StatelessWidget {
  const FaceInfoCard({super.key, required this.face});

  final FaceResult face;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = face.isSmiling ? kSmilingColor : kNotSmilingColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  child: Text('${face.number}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Face ${face.number}', style: textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            face.isSmiling
                                ? Icons.sentiment_satisfied_alt
                                : Icons.sentiment_neutral,
                            size: 18,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            face.smileStatus,
                            style: textTheme.bodyMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      face.smileProbabilityText,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Smile probability', style: textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: face.smileProbability ?? 0,
                minHeight: 6,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
