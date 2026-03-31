import 'package:edubridge_app/shared/widgets/brand_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('브랜드 앱바가 렌더링된다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(appBar: BrandAppBar())),
    );
    expect(find.text('EduBridge'), findsOneWidget);
  });
}
