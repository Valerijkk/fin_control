// test/ui/screens/photo_viewer_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/ui/screens/photo_viewer_screen.dart';

import '../../helpers/test_host.dart';

void main() {
  testWidgets('PhotoViewer: renders image', (tester) async {
    final state = TestAppState();
    final f = await makeTempPng();

    await tester.pumpWidget(makeHost(home: PhotoViewerScreen(path: f.path), state: state));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
  });
}
