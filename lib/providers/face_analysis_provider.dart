import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

import '../models/face_result.dart';

enum AnalysisStatus { idle, analyzing, done, error }

class FaceAnalysisProvider extends ChangeNotifier {
  FaceAnalysisProvider({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  // Classification must be enabled to get smilingProbability.
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.05, // also catch smaller faces in group photos
    ),
  );

  File? image;
  ui.Size? imageSize;
  List<FaceResult> faces = const [];
  AnalysisSummary summary = AnalysisSummary.empty;
  AnalysisStatus status = AnalysisStatus.idle;
  String? errorMessage;
  bool _disposed = false;

  bool get isBusy => status == AnalysisStatus.analyzing;
  bool get hasImage => image != null;
  bool get hasResult => status == AnalysisStatus.done;

  /// Opens the gallery, then runs face detection on the chosen image.
  Future<void> pickAndAnalyze() async {
    if (isBusy) return;

    XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      );
    } catch (_) {
      _fail('Could not open the gallery. Check photo permission and try again.');
      return;
    }
    if (picked == null) return; // user cancelled

    // Reset previous results and show the new image right away.
    image = File(picked.path);
    imageSize = null;
    faces = const [];
    summary = AnalysisSummary.empty;
    errorMessage = null;
    status = AnalysisStatus.analyzing;
    _notify();

    try {
      imageSize = await _readImageSize(image!);
      _notify();

      final inputImage = InputImage.fromFilePath(picked.path);
      final detected = [...await _detector.processImage(inputImage)];
      if (_disposed) return;

      // Number faces left to right so "Face 1" is the left-most face.
      detected.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));

      faces = [
        for (var i = 0; i < detected.length; i++)
          FaceResult(
            number: i + 1,
            boundingBox: detected[i].boundingBox,
            smileProbability: detected[i].smilingProbability,
          ),
      ];
      summary = AnalysisSummary.fromFaces(faces);
      status = AnalysisStatus.done;
      _notify();
    } catch (_) {
      _fail('Face analysis failed. Please try another image.');
    }
  }

  /// Decodes the image once to get its real (orientation-corrected) size,
  /// which is the coordinate space ML Kit's bounding boxes use.
  Future<ui.Size> _readImageSize(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final size = ui.Size(
      frame.image.width.toDouble(),
      frame.image.height.toDouble(),
    );
    frame.image.dispose();
    codec.dispose();
    return size;
  }

  void _fail(String message) {
    errorMessage = message;
    status = AnalysisStatus.error;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _detector.close();
    super.dispose();
  }
}
