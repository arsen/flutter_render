// test/render_widget_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'animated_text.dart';

Future<void> writePng(ui.Image image, String path) async {
  // print('writePng: Converting image to bytes...');
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw Exception('Failed to convert image to byte data');
  }

  // print('writePng: Got byte data, size: ${byteData.lengthInBytes}');
  final bytes = byteData.buffer.asUint8List();

  // print('writePng: Preparing file path: $path');
  final file = File(path);

  // Only create parent directory if the file is in a subdirectory
  if (file.parent.path != '.') {
    // print('writePng: Creating parent directory: ${file.parent.path}');
    try {
      await file.parent.create(recursive: true);
      // print('writePng: Directory created successfully');
    } catch (e) {
      // print('writePng: Directory creation failed: $e');
      rethrow;
    }
  } else {
    // print('writePng: No directory creation needed (writing to current directory)');
  }

  // print('writePng: Writing ${bytes.length} bytes to file...');
  try {
    await file.writeAsBytes(bytes);
    // print('writePng: File written successfully');
  } catch (e) {
    // print('writePng: File write failed: $e');
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
    // inside your group(...) add this test:
    testWidgets('captures animation frames', (WidgetTester tester) async {
      // 1) Create controller/animation
      final controller = AnimationController(
        vsync: tester, // WidgetTester is a TickerProvider in tests
        duration: const Duration(seconds: 1),
      );
      await tester.runAsync(() async {
        await loadFonts(); // your existing loader (pubspec-registered)

        // Stable surface
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // addTearDown(controller.dispose);

        final animation = CurvedAnimation(
          parent: controller,
          curve: Curves.linear, // or Curves.easeOut, etc.
        );

        // 2) Pump the widget that uses the animation
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.grey[100],
              body: Center(child: AnimatedScaledText(animation: animation)),
            ),
          ),
        );
        print('Pumped widget');

        // 3) Start the animation
        controller.forward(from: 0.0);

        // 4) Capture frames at fixed fps
        const fps = 60;
        final frameStep = Duration(milliseconds: (1000 / fps).round());

        final boundaryFinder = find.byKey(const ValueKey('capture'));
        expect(boundaryFinder, findsOneWidget);

        for (int i = 0; i <= fps; i++) {
          print('Capturing frame: $i');
          // Advance time by one frame
          await tester.pump(frameStep);

          // Grab the current frame
          final RenderRepaintBoundary boundary =
              tester.renderObject(boundaryFinder);
          final ui.Image image =
              await boundary.toImage(pixelRatio: 2.0); // scale output
          var filePath = 'frames/frame_${i.toString().padLeft(3, '0')}.png';
          // print('Writing to file: $filePath');
          await writePng(
            image,
            filePath,
          );
          image.dispose();
        }
      });
      controller.dispose();
    });
  });
}

Future<void> loadFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader('Roboto');
  loader.addFont(rootBundle.load('assets/Roboto/static/Roboto-Medium.ttf'));
  await loader.load();
}
