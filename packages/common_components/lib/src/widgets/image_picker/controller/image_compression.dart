import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<XFile> compressFile(XFile xFile,
    {int quality = 80, int iteration = 0}) async {
  final filePath = xFile.path.toLowerCase();
  debugPrint("Starting compression for: ${xFile.path}");
  final int maxSizeBytes = 2 * 1024 * 1024; // 2 MB
  // 1. Identify Format & Handle SVGs
  CompressFormat compressFormat = CompressFormat.jpeg;
  if (filePath.endsWith(".png")) {
    compressFormat = CompressFormat.png;
  } else if (filePath.endsWith(".heic") || filePath.endsWith(".heif")) {
    compressFormat = CompressFormat.heic;
  } else if (filePath.endsWith(".webp")) {
    compressFormat = CompressFormat.webp;
  } else if (filePath.endsWith(".svg")) {
    debugPrint(
        "SVG detected: Returning original (Vectors cannot be raster-compressed).");
    return xFile;
  }

  // 2. Generate Output Path safely
  final lastDot = xFile.path.lastIndexOf('.');
  final String outPath =
      "${xFile.path.substring(0, lastDot)}_compressed_$iteration${xFile.path.substring(lastDot)}";

  // 3. Perform Compression
  var result = await FlutterImageCompress.compressAndGetFile(
    xFile.path,
    outPath,
    quality: quality,
    format: compressFormat,
  );

  if (result == null) return xFile;

  // 4. Check Size
  final File file = File(result.path);
  final int currentSize = await file.length();
  debugPrint(
      "Iteration $iteration | Quality: $quality | Size: ${(currentSize / 1024 / 1024).toStringAsFixed(2)} MB");

  // 5. Recursive Exit Strategy
  // If still over 2MB, try again with lower quality, up to 3 attempts.
  if (currentSize > maxSizeBytes && quality > 20 && iteration < 3) {
    return compressFile(result,
        quality: quality - 20, iteration: iteration + 1);
  }

  return result;
}
