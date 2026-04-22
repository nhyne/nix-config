---
description: Interactively answer questions Claude asked, one by one, via macOS input dialogs
argument-hint: [optional: override which questions to answer]
---

Collect answers to the questions you asked in your most recent turn, then respond using those answers.

## Step 1: Extract questions

Look at your most recent assistant message (immediately before this `/answer` invocation). Extract every question — sentences ending in `?`, numbered/bulleted items phrased as questions, or anything clearly asking the user to decide or provide information.

If $ARGUMENTS is non-empty, use those as the questions instead.

Number them Q1, Q2, Q3, etc.

## Step 2: Write an AppleScript helper

Write this file to `/tmp/ask.applescript`:

```applescript
on run argv
  set q to item 1 of argv
  set n to item 2 of argv
  set total to item 3 of argv
  set dlg to display dialog q with title ("Question " & n & " of " & total) default answer "" buttons {"OK"} default button "OK"
  return text returned of dlg
end run
```

## Step 3: For each question, open a dialog and collect the answer

Run one osascript invocation per question:

```bash
osascript /tmp/ask.applescript "QUESTION_TEXT" "N" "TOTAL"
```

Store each answer as `A1`, `A2`, etc.

Dialogs appear one at a time. Do not proceed to the next until the current one is closed.

## Step 4: Respond

Once all answers are collected, reply directly to each question using the provided answers — as though the user had typed them in a normal message. Continue the task from there.
