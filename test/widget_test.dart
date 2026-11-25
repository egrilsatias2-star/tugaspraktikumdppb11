// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:play_wave/main.dart';

void main() {
  testWidgets('menampilkan galeri dan berpindah ke pemutar audio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlayWaveApp());

    expect(find.text('Pilih foto,\nceritakan momen.'), findsOneWidget);
    expect(find.text('Pilih dari galeri'), findsOneWidget);

    await tester.tap(find.text('Audio'));
    await tester.pump();

    expect(find.text('Putar ritmemu.'), findsOneWidget);
    expect(find.text('Audio demo'), findsOneWidget);
  });
}
