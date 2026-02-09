import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'screenshot_utils.dart';

/// Example of how to use screenshot capture in a server environment
/// This demonstrates the proper way to capture widgets as images and save them to files

// Global key for the widget we want to capture
final GlobalKey screenshotKey = GlobalKey();

Widget buildWidgetToCapture() {
  return RepaintBoundary(
    key: screenshotKey,
    child: Container(
      width: 400,
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 48,
            color: Colors.blue,
          ),
          SizedBox(height: 16),
          Text(
            'Server-Generated Screenshot',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Generated: ${DateTime.now().toString().split('.')[0]}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class ScreenshotApp extends StatelessWidget {
  const ScreenshotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Server Screenshot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: buildWidgetToCapture(),
        ),
      ),
    );
  }
}

/// Main function for server screenshot generation
Future<void> main(List<String> args) async {
  print('Server Screenshot: Starting...');
  
  // Initialize Flutter for headless rendering
  WidgetsFlutterBinding.ensureInitialized();
  
  // Parse command line arguments
  String outputPath = 'screenshots/server_widget.png';
  double pixelRatio = 3.0;
  
  if (args.isNotEmpty) {
    outputPath = args[0];
  }
  if (args.length > 1) {
    pixelRatio = double.tryParse(args[1]) ?? 3.0;
  }
  
  print('Server Screenshot: Output path: $outputPath');
  print('Server Screenshot: Pixel ratio: $pixelRatio');
  
  // Create a simple app for rendering
  runApp(ScreenshotApp());
  
  // Wait a bit for the widget to be built and rendered
  await Future.delayed(Duration(milliseconds: 1000));
  
  print('Server Screenshot: Attempting to capture screenshot...');
  
  // Capture and save the screenshot
  final success = await ScreenshotCapture.captureAndSave(
    screenshotKey,
    outputPath,
    pixelRatio: pixelRatio,
  );
  
  if (success) {
    print('Server Screenshot: SUCCESS! Screenshot saved to: $outputPath');
    
    // Verify the file was created
    final file = File(outputPath);
    if (await file.exists()) {
      final size = await file.length();
      print('Server Screenshot: File size: $size bytes');
    }
    
    exit(0);
  } else {
    print('Server Screenshot: FAILED to capture screenshot');
    exit(1);
  }
}
