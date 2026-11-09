---
name: decisions
description: The GameMaxxing decision log. Use whenever Claude makes a creative choice the student didn't specify (a name, a number that changes how the game feels, a line of dialogue, an enemy, a colour, an art prompt detail), and at review time (the fix stage, around 2:30) to walk the student through every open guess so they can keep, change or cut it. Keeps design/decisions.md.
---

# GameMaxxing: decision log

The student's game must be theirs. Claude will have to guess some things to keep building; this log makes every guess visible so the student can own it. Talk the way [tone.md](${CLAUDE_PLUGIN_ROOT}/shared/tone.md) says.

## Logging a guess

Append one entry to `design/decisions.md` (create it with a `# Decisions` heading if missing) for **each** creative choice the student didn't specify:

```
## D07 · Enemy speed
What I chose: slimes move at 90 (slow), so the first fight is easy.
Why: you didn't say; slow suits "a calm game about gardening".
Status: open
```

- Number entries in order (D01, D02, ...), continuing from the last one in the file.
- **Log:** names, dialogue lines, enemies and creatures, numbers that change how the game feels (speed, health, jump height, timers), colours, art details you added to a prompt, which ending is which.
- **Don't log:** technical choices the student never sees (file names, how the code works, test settings).
- Write "What I chose" and "Why" in plain words, tied to their bible where you can ("because your rule says nobody ever dies").
- Don't interrupt the student for each guess while building. Mention them briefly: "I made 3 guesses, they're in your decision log."

## Reviewing the log (the fix stage, or whenever the student asks)

1. Count the `Status: open` entries and tell the student: "Claude made N guesses while building. Let's go through them. For each one you can keep it, change it, or cut it. Every one you change makes the game more yours." Changing or replacing a guess earns 💎 +5 Depth (up to 5 times; see [quest.md](${CLAUDE_PLUGIN_ROOT}/shared/quest.md)).
2. Show **one entry at a time**, in plain words, and wait for the answer.
   - **Keep:** set `Status: approved`.
   - **Change:** ask what they want instead, then set `Status: changed: <their choice>`. Make the change with the `gamemaxxing:build` skill (so it's tested), or note it for after the review if they'd rather batch them.
   - **Cut:** set `Status: changed: cut`, and remove it from the game with the `gamemaxxing:build` skill. If cutting it would take away something the game needs (its only enemy or challenge, the way to win, an ending), say so in one line and ask what should take its place, or whether they're happy without it.
3. Keep it moving: do the ones that most affect how the game plays or feels first. If there are more than 12 open, or the student keeps saying "that's fine", offer: "Want to keep all the rest as they are? I'll list them so you can stop me." List the rest by title, and mark them `approved` if they agree.
4. When none are open, celebrate in one line: "Every choice in your game is now yours." ⭐ +10 XP. In the fix stage, carry on to their playtest fix with the `gamemaxxing:build` skill. When it's in, award 🛠️ Fixer.
5. Guesses logged **after** the review (from later fixes) get a quick check at publish time: "I made 2 more guesses since your review: <titles>. Keep them?"

## Rules

- Never delete an entry. The log is the history of the student's decisions. When a later change replaces a guess, mark the old one `changed: replaced by Dnn`.
- If a guess conflicts with a rule in `design/game_bible.md`, don't make it; ask the student instead.
