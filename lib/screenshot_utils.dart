import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScreenshotCapture {
  /// Save image data to file with proper error handling
  static Future<bool> saveImageToFile(ui.Image image, String filePath) async {
    try {
      print('ScreenshotCapture: Converting image to PNG bytes...');
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        print('ScreenshotCapture: Failed to convert image to byte data');
        return false;
      }
      
      print('ScreenshotCapture: Got ${byteData.lengthInBytes} bytes');
      final bytes = byteData.buffer.asUint8List();
      
      final file = File(filePath);
      print('ScreenshotCapture: Creating directories for path: $filePath');
      
      // Create parent directories if they don't exist
      await file.parent.create(recursive: true);
      
      print('ScreenshotCapture: Writing ${bytes.length} bytes to file...');
      await file.writeAsBytes(bytes);
      
      print('ScreenshotCapture: Successfully saved screenshot to: $filePath');
      return true;
      
    } catch (e, stackTrace) {
      print('ScreenshotCapture: Error saving image: $e');
      print('ScreenshotCapture: Stack trace: $stackTrace');
      return false;
    }
  }

  /// Capture screenshot from a RepaintBoundary widget
  static Future<ui.Image?> captureWidgetAsImage(GlobalKey key, {double pixelRatio = 3.0}) async {
    try {
      print('ScreenshotCapture: Looking for RepaintBoundary with key...');
      
      // Find the RenderRepaintBoundary
      final RenderObject? renderObject = key.currentContext?.findRenderObject();
      if (renderObject == null) {
        print('ScreenshotCapture: No render object found for key');
        return null;
      }
      
      if (renderObject is! RenderRepaintBoundary) {
        print('ScreenshotCapture: Render object is not a RenderRepaintBoundary');
        return null;
      }

      print('ScreenshotCapture: Capturing image with pixelRatio: $pixelRatio');
      final ui.Image image = await renderObject.toImage(pixelRatio: pixelRatio);
      
      print('ScreenshotCapture: Captured image ${image.width}x${image.height}');
      return image;
      
    } catch (e, stackTrace) {
      print('ScreenshotCapture: Error capturing widget: $e');
      print('ScreenshotCapture: Stack trace: $stackTrace');
      return null;
    }
  }

  /// Complete capture and save workflow
  static Future<bool> captureAndSave(GlobalKey key, String filePath, {double pixelRatio = 3.0}) async {
    print('ScreenshotCapture: Starting capture and save to: $filePath');
    
    final image = await captureWidgetAsImage(key, pixelRatio: pixelRatio);
    if (image == null) {
      print('ScreenshotCapture: Failed to capture image');
      return false;
    }

    final success = await saveImageToFile(image, filePath);
    
    // Clean up the image
    image.dispose();
    
    if (success) {
      print('ScreenshotCapture: Complete! Screenshot saved to: $filePath');
    } else {
      print('ScreenshotCapture: Failed to save screenshot');
    }
    
    return success;
  }
}
