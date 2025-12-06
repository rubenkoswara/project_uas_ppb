import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:projectuasppb/main.dart'; 

void main() {
  testWidgets('Aplikasi MyRenesca menampilkan halaman Auth dan tombol Masuk', (WidgetTester tester) async {
    
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.pumpAndSettle();

    expect(find.text('MyRenesca'), findsOneWidget);

    expect(find.text('Selamat Datang'), findsOneWidget);

    expect(find.byWidgetPredicate((widget) {
      if (widget is TextField) {
        final InputDecoration? decoration = widget.decoration;
        return decoration?.labelText == 'Email';
      }
      return false;
    }), findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Masuk'), findsOneWidget);

    await tester.tap(find.text('Belum punya akun? Daftar'));
    await tester.pump(); 

    expect(find.text('Buat Akun'), findsOneWidget);
    
    expect(find.widgetWithText(ElevatedButton, 'Daftar'), findsOneWidget);
  });
}