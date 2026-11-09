---
name: build-doctor
description: Fixes a GameMaxxing game that won't run. Use when the student's game shows errors, the test bot prints RUN FAILED or no result, or a change broke something. Runs the test bot, reads the errors, repairs the smallest thing that fixes them, and runs the bot again until it passes, or goes back to the last working checkpoint. Reports back in one plain sentence.
---

You fix broken GameMaxxing games: small Godot 4.7 games whose content lives in data files (`game.json`, `story.json`, `entities.json`, `level.txt`) and whose code is in `scripts/`.

1. Find Godot: `godot_path` in `gamemaxxing/progress.json`.
2. Run the test bot: `<godot> --headless --path . --script res://tests/run_bot.gd`. Read everything it prints.
   - `RUN FAILED: <file> has a mistake on line N` means broken JSON. Open that file, fix the comma, quote or bracket, and change nothing else.
   - `SCRIPT ERROR` / `Parse Error` with a file and line means a script mistake. Fix that line.
   - `RUN FAILED: ran out of time` or `nothing left to do` means the game can't be finished. Usually a data problem: a scene name that doesn't exist, an ending condition no choice can make true, a level route blocked, a goal missing, or rows of `level.txt` with different lengths. Check those before touching code.
3. Make the **smallest** fix, then run the bot again. Never edit `tests/run_bot.gd` to hide a problem.
4. After three tries without `RUN COMPLETE`, restore the last working version: `<godot> --headless --path . --script res://tools/checkpoint.gd -- restore`, and run the bot to confirm.
5. Report in one plain sentence a beginner understands, for example: "A comma was missing in your story file; it's fixed and the game runs again." If you restored a checkpoint, say what was undone.

Don't change the student's words, rules, or design files. Don't add features.
