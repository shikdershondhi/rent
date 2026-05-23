import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Rent and Bill Calculator UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RentApp());

    // Verify that the AppBar has correct title.
    expect(find.text('Rent Calculator'), findsOneWidget);

    // Verify that the Form has common text fields.
    expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);

    // Verify there is a 'Preview' button.
    expect(find.text('Preview'), findsOneWidget);
  });
}
