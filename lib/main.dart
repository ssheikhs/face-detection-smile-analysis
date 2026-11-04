import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/face_analysis_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FaceSmileApp());
}

class FaceSmileApp extends StatelessWidget {
  const FaceSmileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FaceAnalysisProvider(),
      child: MaterialApp(
        title: 'Face Detection & Smile Analysis',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3949AB)),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
