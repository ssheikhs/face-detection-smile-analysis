import 'dart:ui';

import 'package:face_smile_analysis/models/face_result.dart';
import 'package:flutter_test/flutter_test.dart';

FaceResult _face(int n, double? p) =>
    FaceResult(number: n, boundingBox: Rect.zero, smileProbability: p);

void main() {
  group('Smile analysis', () {
    test('4 faces, 3 smiling -> 75%', () {
      final s = AnalysisSummary.fromFaces([
        _face(1, 0.95),
        _face(2, 0.80),
        _face(3, 0.71),
        _face(4, 0.10),
      ]);
      expect(s.totalFaces, 4);
      expect(s.smilingFaces, 3);
      expect(s.notSmilingFaces, 1);
      expect(s.smilingPercentage, 75);
      expect(formatPercent(s.smilingPercentage), '75%');
    });

    test('no faces -> 0%', () {
      final s = AnalysisSummary.fromFaces([]);
      expect(s.smilingPercentage, 0);
      expect(formatPercent(s.smilingPercentage), '0%');
    });

    test('0.7 counts as smiling, 0.69 does not', () {
      expect(_face(1, 0.7).isSmiling, isTrue);
      expect(_face(1, 0.69).isSmiling, isFalse);
    });

    test('missing probability is Not Smiling and shows N/A', () {
      final f = _face(1, null);
      expect(f.isSmiling, isFalse);
      expect(f.smileStatus, 'Not Smiling');
      expect(f.smileProbabilityText, 'N/A');
    });

    test('2 of 3 smiling -> 66.7%', () {
      final s = AnalysisSummary.fromFaces(
        [_face(1, 0.9), _face(2, 0.9), _face(3, 0.2)],
      );
      expect(formatPercent(s.smilingPercentage), '66.7%');
    });
  });
}
