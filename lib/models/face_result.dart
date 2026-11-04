import 'dart:ui';

/// A face counts as smiling when ML Kit's smile probability is >= 0.7 (70%).
const double kSmileThreshold = 0.7;

/// One detected face, reduced to what the UI needs.
class FaceResult {
  const FaceResult({
    required this.number,
    required this.boundingBox,
    required this.smileProbability,
  });

  /// 1-based face number shown as "Face 1", "Face 2", ...
  final int number;

  /// Face rectangle in the original image's pixel coordinates.
  final Rect boundingBox;

  /// 0.0 - 1.0, or null when ML Kit could not classify the face.
  final double? smileProbability;

  bool get isSmiling => (smileProbability ?? 0) >= kSmileThreshold;

  String get smileStatus => isSmiling ? 'Smiling' : 'Not Smiling';

  String get smileProbabilityText => smileProbability == null
      ? 'N/A'
      : '${(smileProbability! * 100).toStringAsFixed(1)}%';
}

/// Totals for the analytics cards.
class AnalysisSummary {
  const AnalysisSummary({required this.totalFaces, required this.smilingFaces});

  factory AnalysisSummary.fromFaces(List<FaceResult> faces) => AnalysisSummary(
        totalFaces: faces.length,
        smilingFaces: faces.where((f) => f.isSmiling).length,
      );

  static const empty = AnalysisSummary(totalFaces: 0, smilingFaces: 0);

  final int totalFaces;
  final int smilingFaces;

  int get notSmilingFaces => totalFaces - smilingFaces;

  /// Smiling Percentage = (Smiling Faces / Total Detected Faces) x 100.
  /// Returns 0 when no face is detected.
  double get smilingPercentage =>
      totalFaces == 0 ? 0 : smilingFaces / totalFaces * 100;
}

/// 75.0 -> "75%", 66.666 -> "66.7%".
String formatPercent(double value) => value == value.roundToDouble()
    ? '${value.toInt()}%'
    : '${value.toStringAsFixed(1)}%';
