#!/usr/bin/env dart
/// Command-line script to generate screenshots in a server environment
/// Usage: dart generate_screenshot.dart [output_path] [pixel_ratio]
/// Example: dart generate_screenshot.dart screenshots/my_widget.png 3.0

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'lib/screenshot_utils.dart';

// Global key for the widget we want to capture
final GlobalKey captureKey = GlobalKey();

/// Widget to be captured as screenshot
Widget buildServerWidget() {
  final now = DateTime.now();
  return RepaintBoundary(
    key: captureKey,
    child: Container(
      width: 400,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.purple.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.screenshot,
                size: 64,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Server Screenshot',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Generated: ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ServerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Server Screenshot Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Center(
          child: buildServerWidget(),
        ),
      ),
    );
  }
}

Future<void> main(List<String> args) async {
  print('=== Server Screenshot Generator ===');
  
  // Parse arguments
  String outputPath = 'server_screenshot.png';
  double pixelRatio = 3.0;
  
  if (args.isNotEmpty) {
    outputPath = args[0];
    print('Output path: $outputPath');
  }
  
  if (args.length > 1) {
    final ratio = double.tryParse(args[1]);
    if (ratio != null && ratio > 0) {
      pixelRatio = ratio;
    }
  }
  print('Pixel ratio: $pixelRatio');
  
  try {
    // Initialize Flutter for headless rendering
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter initialized for headless rendering');
    
    // Create the app (but don't show it)
    runApp(ServerApp());
    print('App created, waiting for render...');
    
    // Wait for the widget tree to be built
    await Future.delayed(Duration(milliseconds: 1500));
    
    print('Capturing screenshot...');
    
    // Capture and save the screenshot using our utility
    final success = await ScreenshotCapture.captureAndSave(
      captureKey,
      outputPath,
      pixelRatio: pixelRatio,
    );
    
    if (success) {
      // Verify the file was created
      final file = File(outputPath);
      if (await file.exists()) {
        final size = await file.length();
        print('✅ SUCCESS! Screenshot saved to: $outputPath');
        print('📁 File size: ${(size / 1024).toStringAsFixed(1)} KB');
        print('🎨 Resolution: ${(400 * pixelRatio).toInt()}x${(300 * pixelRatio).toInt()} pixels');
        exit(0);
      }
    }
    
    print('❌ FAILED to generate screenshot');
    exit(1);
    
  } catch (e, stackTrace) {
    print('❌ ERROR: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
