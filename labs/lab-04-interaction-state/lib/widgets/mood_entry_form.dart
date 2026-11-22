import 'package:flutter/material.dart';

import '../models/mood_entry.dart';
import 'mood_score_selector.dart';

/// A form for recording a new mood entry.
///
/// Exercise 1, step 3, and Exercise 2, steps 1-3.
class MoodEntryForm extends StatefulWidget {
  const MoodEntryForm({super.key, required this.onSubmit});

  /// Called with the new entry when the user saves it.
  final ValueChanged<MoodEntry> onSubmit;

  @override
  State<MoodEntryForm> createState() => _MoodEntryFormState();
}

class _MoodEntryFormState extends State<MoodEntryForm> {
  int? _score;
  final _noteController = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (_score == null) {
      setState(() {
        _validationError = 'Choose a score from 1 to 10';
      });
      return;
    }

    final rawNote = _noteController.text.trim();
    if (rawNote.length > maxNoteLength) {
      setState(() {
        _validationError = 'Note must be $maxNoteLength characters or fewer';
      });
      return;
    }

    final note = rawNote.isEmpty ? null : rawNote;

    final entry = MoodEntry(
      score: _score!,
      note: note,
      createdAt: DateTime.now(),
    );

    widget.onSubmit(entry);

    setState(() {
      _score = null;
      _noteController.clear();
      _validationError = null;
    });
  }

  String? _currentValidationError() {
    if (_score == null) return 'Choose a score from 1 to 10';
    if (_noteController.text.trim().length > maxNoteLength) {
      return 'Note must be $maxNoteLength characters or fewer';
    }
    return null;
  }

  void _updateScore(int score) {
    setState(() {
      _score = score;
      if (_validationError != null) {
        _refreshValidationError();
      }
    });
  }

  void _updateNote(String _) {
    if (_validationError == null) return;
    setState(_refreshValidationError);
  }

  void _refreshValidationError() {
    _validationError = _currentValidationError();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How are you feeling?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            MoodScoreSelector(selectedScore: _score, onChanged: _updateScore),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              onChanged: _updateNote,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            if (_validationError != null) ...[
              const SizedBox(height: 8),
              Text(
                _validationError!,
                key: const ValueKey('mood-entry-validation-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('Save entry')),
          ],
        ),
      ),
    );
  }
}
