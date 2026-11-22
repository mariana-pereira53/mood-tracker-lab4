# Form validation: acceptance criteria

1. Given no score is selected, when I tap `Save entry`, then the message
`"Choose a score from 1 to 10"` appears and nothing is added to the history.
2. Given a score from 1 to 10 is selected and the note has at most `maxNoteLength`, when I tap `Save entry`
an entry is added to the history and the forms resets.
3. Given a score from 1 to 10 is selected and the note has at least `maxNoteLength` + 1, when I tap
`Save entry`, then a validation error is shown and nothing is added to the history.
4. Given a validation error is shown, when I fix the input (select a score or shorten the note) and tap `Save entry`,
then the error is cleared and the entry is added to the history.
5. Given a score from 1 to 10 is selected, and the note is empty or contains only whitespaces, when I tap `Save entry`,
then the entry is added to the history with no note.