import 'package:clearvisit/src/app.dart';
import 'package:clearvisit/src/data/clearvisit_repository.dart';
import 'package:clearvisit/src/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AI page has a back button that returns Home', (tester) async {
    await tester.pumpWidget(ClearCueApp(repository: _FakeRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('section-back-button')), findsOneWidget);
    expect(find.text('AI helper'), findsOneWidget);

    await tester.tap(find.byKey(const Key('section-back-button')));
    await tester.pumpAndSettle();

    expect(find.text('Where would you like to go?'), findsOneWidget);
  });

  testWidgets('tapping the ClearCue logo returns Home', (tester) async {
    await tester.pumpWidget(ClearCueApp(repository: _FakeRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-logo-button')));
    await tester.pumpAndSettle();

    expect(find.text('Where would you like to go?'), findsOneWidget);
  });

  testWidgets('system back returns a section to Home before exiting', (
    tester,
  ) async {
    await tester.pumpWidget(ClearCueApp(repository: _FakeRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Where would you like to go?'), findsOneWidget);
  });
}

class _FakeRepository implements ClearVisitRepository {
  @override
  Future<List<Appointment>> appointments() async => [];

  @override
  Future<void> deleteEverything() async {}

  @override
  Future<List<HealthLogEntry>> healthLog() async => [];

  @override
  Future<List<Measurement>> measurements() async => [];

  @override
  Future<List<Medication>> medications() async => [];

  @override
  Future<void> saveAppointment(Appointment value) async {}

  @override
  Future<void> saveHealthLogEntry(HealthLogEntry value) async {}

  @override
  Future<void> saveMeasurement(Measurement value) async {}

  @override
  Future<void> saveMedication(Medication value) async {}

  @override
  Future<void> saveSetting(String key, String value) async {}

  @override
  Future<String?> setting(String key) async => null;
}
