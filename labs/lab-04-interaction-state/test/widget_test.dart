import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker/data/sample_entries.dart';
import 'package:mood_tracker/main.dart';
import 'package:mood_tracker/models/mood_entry.dart';
import 'package:mood_tracker/widgets/mood_card.dart';

// Self-check for Lab 4, Exercises 1 and 2. Run it with: flutter test
//
// Both tests fail on the starter code and pass once Exercise 2 is done.
// Exercise 3 changes what the Save button should do. Part of that task is
// to update these tests so they check the new requirement.

/// Renders the app in a window tall enough for every card to be built.
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MoodTrackerApp());
}

Finder get saveButton => find.widgetWithText(FilledButton, 'Save entry');
const noScoreError = 'Choose a score from 1 to 10';
final longNoteError = 'Note must be $maxNoteLength characters or fewer';

void main() {
  testWidgets('saving without a score shows an error and adds nothing', (
    tester,
  ) async {
    await pumpApp(tester);

    final initialCardCount = find.byType(MoodCard).evaluate().length;
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);

    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text(noScoreError), findsOneWidget);
    expect(find.byType(MoodCard), findsNWidgets(initialCardCount));
  });

  testWidgets('choosing a score after an error clears it and saves', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(saveButton);
    await tester.pump();
    expect(find.text(noScoreError), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.pump();
    expect(find.text(noScoreError), findsNothing);

    await tester.tap(saveButton);
    await tester.pump();

    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length + 1));
    expect(find.text(noScoreError), findsNothing);
    expect(
      find.descendant(
        of: find.byType(MoodCard).first,
        matching: find.text('No note'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('saving an entry puts it at the top of the history', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Rainy walk home');
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length + 1));
    expect(
      find.descendant(
        of: find.byType(MoodCard).first,
        matching: find.text('Rainy walk home'),
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '3')).selected,
      isFalse,
    );
  });

  testWidgets('a note at the maximum length can be saved', (tester) async {
    await pumpApp(tester);

    final initialCardCount = find.byType(MoodCard).evaluate().length;
    await tester.tap(find.widgetWithText(ChoiceChip, '5'));
    await tester.pump();
    await tester.enterText(
      find.byType(TextField),
      List.filled(maxNoteLength, 'x').join(),
    );
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.byType(MoodCard), findsNWidgets(initialCardCount + 1));
    expect(find.text(longNoteError), findsNothing);
  });

  testWidgets('long notes show an error and can be corrected to save', (
    tester,
  ) async {
    await pumpApp(tester);

    final initialCardCount = find.byType(MoodCard).evaluate().length;
    await tester.tap(find.widgetWithText(ChoiceChip, '4'));
    await tester.pump();
    await tester.enterText(
      find.byType(TextField),
      List.filled(maxNoteLength + 1, 'x').join(),
    );
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text(longNoteError), findsOneWidget);
    expect(find.byType(MoodCard), findsNWidgets(initialCardCount));

    await tester.enterText(find.byType(TextField), 'A shorter note');
    await tester.pump();
    expect(find.text(longNoteError), findsNothing);

    await tester.tap(saveButton);
    await tester.pump();

    expect(find.byType(MoodCard), findsNWidgets(initialCardCount + 1));
    expect(
      find.descendant(
        of: find.byType(MoodCard).first,
        matching: find.text('A shorter note'),
      ),
      findsOneWidget,
    );
    expect(find.text(longNoteError), findsNothing);
  });

  testWidgets('whitespace-only notes are saved as no note', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '6'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(saveButton);
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(MoodCard).first,
        matching: find.text('No note'),
      ),
      findsOneWidget,
    );
  });
}
