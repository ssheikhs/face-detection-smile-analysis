import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/face_result.dart';

const Color kSmilingColor = Color(0xFF2E7D32);
const Color kNotSmilingColor = Color(0xFFEF6C00);

/// Draws a rectangle + "Face N" label for each face.
///
/// The painter is laid out at the image's original pixel size (see
/// [ImagePreview]), so ML Kit's bounding boxes can be drawn as-is and are
/// scaled together with the image.
class FaceBoxPainter extends CustomPainter {
  FaceBoxPainter({required this.faces, required this.imageSize});

  final List<FaceResult> faces;
  final Size imageSize;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    // Sizes relative to the image so they look the same after scaling down.
    final stroke = math.max(2.0, imageSize.shortestSide / 150);
    final fontSize = math.max(12.0, imageSize.shortestSide / 28);

    for (final face in faces) {
      final color = face.isSmiling ? kSmilingColor : kNotSmilingColor;
      final box = face.boundingBox;
      final rect = Rect.fromLTRB(
        box.left * scaleX,
        box.top * scaleY,
        box.right * scaleX,
        box.bottom * scaleY,
      );

      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = color,
      );

      // Label above the box (or inside it if there's no room above).
      final text = TextPainter(
        text: TextSpan(
          text: 'Face ${face.number}',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final pad = fontSize * 0.25;
      final labelW = text.width + pad * 2;
      final labelH = text.height + pad * 2;
      final left = rect.left
          .clamp(0.0, math.max(0.0, size.width - labelW))
          .toDouble();
      final top = rect.top - labelH >= 0 ? rect.top - labelH : rect.top;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, labelW, labelH),
          Radius.circular(pad),
        ),
        Paint()..color = color,
      );
      text.paint(canvas, Offset(left + pad, top + pad));
    }
  }

  @override
  bool shouldRepaint(FaceBoxPainter oldDelegate) =>
      oldDelegate.faces != faces || oldDelegate.imageSize != imageSize;
}
