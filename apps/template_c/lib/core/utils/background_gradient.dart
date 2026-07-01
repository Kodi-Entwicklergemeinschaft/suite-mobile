import 'package:flutter/material.dart';

class BackgroundGradient {
  static const backgroundGradient = LinearGradient(
    // Figma: linear-gradient(202.04deg, #0280FF -19.31%, #0028B8 78.05%)
    begin: Alignment(0.375, -0.927),
    end: Alignment(-0.375, 0.927),
    colors: [Color(0xFF026FF1), Color(0xFF0028B8), Color(0xFF0028B8)],
    stops: [0.0, 0.7805, 1.0],
  );
}
