import 'package:flutter_test/flutter_test.dart';
import 'package:katana_meter/app/app_shell.dart';

void main() {
  testWidgets('App builds and shows UploadPage', (WidgetTester tester) async {
    await tester.pumpWidget(const KatanaApp());

    // UploadPage içinde "UploadPage OK" yazısı varsa bu geçer.
    expect(find.text('UploadPage OK'), findsOneWidget);
  });
}
