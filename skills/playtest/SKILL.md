---
name: playtest
description: Runs a GameMaxxing playtest round. Use at playtest time (around 1:45 and 3:30), or when a student wants someone else to try their game. Before - the student writes who should play and what they should feel. During - the tester plays with no help while the student takes silent notes. After - three questions, then the student picks one fix. Writes playtest/round-N.md.
---

# GameMaxxing: playtest

Watching someone else play is how the student finds what to fix. Talk the way [tone.md](${CLAUDE_PLUGIN_ROOT}/shared/tone.md) says. The exact wording for each step is in [playtest_script.md](playtest_script.md).

## How to run it

1. **Which round?** Look in `playtest/`. If `round-1.md` exists, this is round 2; otherwise round 1. Create the folder if needed.
2. **Make sure the game runs.** Run the test bot (`<godot_path> --headless --path . --script res://tests/run_bot.gd`, with `godot_path` from `gamemaxxing/progress.json`). If it fails, use the `build-doctor` agent to fix it before anyone plays. Then start the game in a window for the tester: `<godot_play> --path .`.
3. **Before** (one question at a time, see the script): the student writes two kinds of player and what each should **do** and **feel**. Their words only. In round 2, offer to reuse round 1's players.
4. **During:** read the "During" part of the script to the student. They swap seats with the tester. The student types short notes while watching (stuck, smiled, stopped trying, anything else); you only record them, with no comments. Don't help the tester, and don't explain the game.
5. **After:** the student asks the tester the three questions, one at a time, and types the answers. Record them as given.
6. **One fix:** show the notes back as a short list of problems, in plain words, and ask the student to pick the **single biggest** one. Don't pick for them. If they want several, say "Let's do the biggest one now. The rest go on your later list." Once they've picked, add **every** other problem from the list to `design/later.md`, so nothing they saw gets lost.
7. **Save `playtest/round-N.md`** (format in the script file).
8. **Fix it:**
   - **Round 1:** the fix happens in the fix stage. Set `stage` to `fix`, add its start time to `stage_started`, and say the next step is reviewing Claude's guesses and then making their fix. If the `start` skill sent you, run `gamemaxxing:decisions` (review) with the Skill tool.
   - **Round 2:** make the one fix now with the `gamemaxxing:build` skill (test bot after). Then set `stage` to `publish` and say it's time to share the game with the world.

## Rules

- The tester gets no help, from you or the student. If the tester asks how to do something, the student says "What would you try?"
- Record notes and answers exactly. Don't soften criticism or add your own opinions of the game. In the "Before" section only, tidy the student's answers into a readable sentence (keep their words).
- Keep each round inside its time: about 45 minutes for round 1, 30 for round 2. Swap testers if there's time; one tester is enough.
