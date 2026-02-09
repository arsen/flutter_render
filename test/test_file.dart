import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Save Hello world to a file', (WidgetTester tester) async {
    tester.runAsync(() async {
// Define the file path (this will save in the project's root directory)
      final file = File('hello_world.txt');

      // Write "Hello world" into the file
      await file.writeAsString('Hello world');

      // Optionally print to confirm
      print('File written: ${file.path}');
    });
  });
}
