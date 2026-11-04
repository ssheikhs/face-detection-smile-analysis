import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/face_result.dart';
import '../providers/face_analysis_provider.dart';
import '../widgets/face_box_painter.dart';
import '../widgets/face_info_card.dart';
import '../widgets/image_preview.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FaceAnalysisProvider>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final summary = p.summary;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: scheme.primaryContainer,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Face Detection & Smile Analysis',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Upload button
            FilledButton.icon(
              onPressed: p.isBusy
                  ? null
                  : () => context.read<FaceAnalysisProvider>().pickAndAnalyze(),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              icon: Icon(
                p.hasImage ? Icons.refresh : Icons.add_photo_alternate_outlined,
              ),
              label: Text(p.hasImage ? 'Upload Another Image' : 'Upload Image'),
            ),
            const SizedBox(height: 16),

            // 2. Image preview with bounding boxes
            if (p.image == null)
              const EmptyImagePlaceholder()
            else
              ImagePreview(
                image: p.image!,
                imageSize: p.imageSize,
                faces: p.faces,
                analyzing: p.isBusy,
              ),
            if (p.hasResult && p.faces.isNotEmpty) ...[
              const SizedBox(height: 8),
              const _BoxLegend(),
            ],
            if (p.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(p.errorMessage!, style: TextStyle(color: scheme.error)),
            ],
            const SizedBox(height: 20),

            // 3 & 4. Analytics cards
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.face_retouching_natural,
                      title: 'Total Faces',
                      value: '${summary.totalFaces}',
                      color: scheme.primary,
                      caption: 'Detected in image',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.sentiment_satisfied_alt,
                      title: 'Smiling Percentage',
                      value: formatPercent(summary.smilingPercentage),
                      color: kSmilingColor,
                      caption:
                          '${summary.smilingFaces} smiling, ${summary.notSmilingFaces} not smiling',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. Individual face information
            Text('Individual Face Information', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            if (p.hasResult && p.faces.isNotEmpty)
              for (final face in p.faces) FaceInfoCard(face: face)
            else
              _InfoMessage(
                text: p.isBusy
                    ? 'Analyzing image...'
                    : p.hasResult
                        ? 'No faces detected in this image.'
                        : 'Upload an image to see details for each face.',
              ),
          ],
        ),
      ),
    );
  }
}

class _BoxLegend extends StatelessWidget {
  const _BoxLegend();

  @override
  Widget build(BuildContext context) {
    Widget item(Color color, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2),
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      children: [
        item(kSmilingColor, 'Smiling (>= 70%)'),
        item(kNotSmilingColor, 'Not smiling'),
      ],
    );
  }
}

class _InfoMessage extends StatelessWidget {
  const _InfoMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: scheme.outline),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
