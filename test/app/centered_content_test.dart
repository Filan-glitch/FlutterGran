import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/theme.dart';

/// The wrapper every form-shaped screen (setup, statistics, diagnostics) puts
/// around its `ListView`, so a single column of controls sized for a phone
/// does not stretch into a wall of sparse text and giant tap targets on a
/// tablet.
void main() {
  Future<Size> contentSizeAt(WidgetTester tester, Size viewport) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CenteredContent(
            child: SizedBox(
              key: const Key('content'),
              width: double.infinity,
              height: 10,
            ),
          ),
        ),
      ),
    );

    return tester.getSize(find.byKey(const Key('content')));
  }

  testWidgets('caps the content at the form width on a wide screen', (
    tester,
  ) async {
    final size = await contentSizeAt(tester, const Size(1333, 800));
    expect(size.width, formContentWidth);
  });

  testWidgets('fills the screen when it is narrower than the form', (
    tester,
  ) async {
    final size = await contentSizeAt(tester, const Size(411, 923));
    expect(size.width, 411);
  });
}
