---
name: coach
description: For the workshop leader only. Shows one screen of a student's status - stage, time per stage, whether they're behind, pitch questions passed, open decisions, last playtest notes, art credits left, and anything broken. Run with /gamemaxxing:coach in the student's session. Changes nothing.
disable-model-invocation: true
---

# GameMaxxing: coach view

This is for Hex, the workshop leader, not the student. Be brief and factual. **Change nothing**: read files and show a summary only. You may run the test bot, which changes no files.

## Gather

- `gamemaxxing/progress.json`: stage, `day_start`, `stage_started`, pitch, `scope_cut`, `template`, credits, checkpoints, `notes`, and `quest` (quest, rank, XP, Depth, boss questions, badges, `suggestions_used`). If `suggestions_used` is high and Depth is low, say so: the student may need encouragement to put more of themselves in.
- The day plan in [run_of_show.md](${CLAUDE_PLUGIN_ROOT}/skills/start/run_of_show.md), to work out ahead or behind.
- `design/decisions.md`: count `Status: open` entries and list their titles.
- The newest `playtest/round-N.md`: the one fix and whether it's fixed.
- SpriteCook `get_credit_balance` if the tool is there (otherwise say "SpriteCook not connected").
- If the game exists (`project.godot` is present) and `godot_path` is set: run the test bot (`<godot_path> --headless --path . --script res://tests/run_bot.gd`) and note whether it prints `RUN COMPLETE`.

## Show one screen, in this shape

```
STUDENT STATUS  (time now, Xh Ym into the day)
Stage: build (started 11:20, 35 min in)   On time / 25 min BEHIND (scope cut: offered, declined)
Quest 4 of 8 · Rank 3 Level Designer · XP 480 · Depth 135 · Boss questions 2 · Badges 6
Template: platformer

Time per stage: setup 22m · pitch 31m · bible 28m · art_direction 40m · template 9m · build 35m

Pitch: passed (Personal, Only game, Swap) · 1 attempt · Hex called: no
Decisions: 6 open of 11 - Enemy speed, Hero's name, Ending text, ...
Last playtest: round 1 - fix "the gap was too far" (not fixed yet)
Art credits: 512 left (used 238 today)
Game: test bot PASSES  /  FAILS: <first error line>
Notes for Hex: <anything in notes>
```

Leave out lines that don't apply yet. If anything needs Hex (behind, Hex called for the pitch, bot failing, credits under 150, notes), end with one line starting **Needs you:**.
