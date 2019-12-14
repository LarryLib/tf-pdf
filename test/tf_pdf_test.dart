import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tf_pdf/tf_pdf.dart';

void main() {
  const MethodChannel channel = MethodChannel('tf_pdf');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await TfPdf.platformVersion, '42');
  });
}
