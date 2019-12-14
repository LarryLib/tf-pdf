import 'dart:async';

import 'package:flutter/services.dart';

class TfPdf {
  static const MethodChannel _channel = const MethodChannel('tf_pdf_channel');

  static Future<String> createPDFByImage(
    List<String> imagePaths, {
    int width = 100,
    int height = 100,
    String savePath,
  }) async {
    var gifPath = await _channel.invokeMethod(
      'createPDFByImage',
      {
        'imagePaths': imagePaths,
        'savePath': savePath,
        'width': width,
        'height': height,
      },
    );
    return gifPath;
  }
}
