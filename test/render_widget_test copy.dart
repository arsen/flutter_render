// test/render_widget_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screenshot_utils.dart';

Future<void> writePng(ui.Image image, String path) async {
  print('writePng: Converting image to bytes...');
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw Exception('Failed to convert image to byte data');
  }

  print('writePng: Got byte data, size: ${byteData.lengthInBytes}');
  final bytes = byteData.buffer.asUint8List();

  print('writePng: Preparing file path: $path');
  final file = File(path);

  // Only create parent directory if the file is in a subdirectory
  if (file.parent.path != '.') {
    print('writePng: Creating parent directory: ${file.parent.path}');
    try {
      await file.parent.create(recursive: true);
      print('writePng: Directory created successfully');
    } catch (e) {
      print('writePng: Directory creation failed: $e');
      rethrow;
    }
  } else {
    print(
        'writePng: No directory creation needed (writing to current directory)');
  }

  print('writePng: Writing ${bytes.length} bytes to file...');
  try {
    await file.writeAsBytes(bytes);
    print('writePng: File written successfully');
  } catch (e) {
    print('writePng: File write failed: $e');
    rethrow;
  }
}

Widget buildWidgetToRender() {
  // Simple widget wrapped in RepaintBoundary for screenshot capture
  return RepaintBoundary(
    key: const ValueKey('capture'),
    child: Container(
      width: 400,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: const Center(
        child: Text(
          'Hello from Flutter!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('Widget Screenshot Tests', () {
    testWidgets('should capture widget screenshot',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await loadFonts();
        // Set a consistent surface size
        tester.view.physicalSize = const Size(1000, 1000);
        tester.view.devicePixelRatio = 1;
        // addTearDown(tester.view.reset);

        print('step 1');
        // Build and pump the widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.grey[100],
              body: Center(
                child: buildWidgetToRender(),
              ),
            ),
          ),
        );

        print('step 2');

        // Wait for the widget to settle
        await tester.pumpAndSettle();

        print('step 3');

        // Find the RepaintBoundary
        final finder = find.byKey(const ValueKey('capture'));
        expect(finder, findsOneWidget);

        print('step 4');
        // Get the RenderRepaintBoundary
        final RenderRepaintBoundary boundary = tester.renderObject(finder);

        // Capture the screenshot
        final ui.Image image = await boundary.toImage(pixelRatio: 5.0);

        print('step 5');

        // Ensure the image was created
        expect(image.width, greaterThan(0));
        expect(image.height, greaterThan(0));

        print('image size: ${image.width}x${image.height}');

        await writePng(image, 'screenshot.png');

        print('step 6 - Successfully captured screenshot!');
        // print('PNG data size: ${byteData.lengthInBytes} bytes');

        // Clean up
        image.dispose();

        print('Screenshot capture test completed successfully!');
      });
    });
  });
}

Future<void> loadFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader('Roboto');
  loader.addFont(
      rootBundle.load('assets/Roboto/static/Roboto-Medium.ttf'));
  await loader.load();
}
