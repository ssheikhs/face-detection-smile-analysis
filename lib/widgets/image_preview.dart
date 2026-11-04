import 'dart:io';

import 'package:flutter/material.dart';

import '../models/face_result.dart';
import 'face_box_painter.dart';

/// Shows the uploaded image with face bounding boxes drawn on top.
class ImagePreview extends StatelessWidget {
  const ImagePreview({
    super.key,
    required this.image,
    required this.imageSize,
    required this.faces,
    required this.analyzing,
  });

  final File image;
  final Size? imageSize;
  final List<FaceResult> faces;
  final bool analyzing;

  @override
  Widget build(BuildContext context) {
    final size = imageSize;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 420),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (size == null)
              Image.file(image, fit: BoxFit.contain)
            else
              // Lay the image and painter out at the image's real pixel size,
              // then let FittedBox scale both together to fit the screen.
              FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(image, fit: BoxFit.fill),
                      CustomPaint(
                        painter: FaceBoxPainter(faces: faces, imageSize: size),
                      ),
                    ],
                  ),
                ),
              ),
            if (analyzing)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black38,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 12),
                        Text(
                          'Detecting faces...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder shown before any image is uploaded.
class EmptyImagePlaceholder extends StatelessWidget {
  const EmptyImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 56, color: scheme.outline),
          const SizedBox(height: 8),
          Text(
            'No image selected',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
