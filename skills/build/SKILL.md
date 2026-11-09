---
name: build
description: The rules for changing a GameMaxxing game safely. Use for any request to change, add to or fix the student's game (characters, levels, dialogue, numbers, screens, endings), and for the first build that puts the student's own scene into the game. One small change at a time, data files before code, a test after every change, save points, and every creative guess logged.
---

# GameMaxxing: build

The student describes what they want. You make it happen without ever leaving them with a broken game. Talk the way [tone.md](${CLAUDE_PLUGIN_ROOT}/shared/tone.md) says. Every data file and field is described in [data_guide.md](data_guide.md). Godot's paths are in `gamemaxxing/progress.json`: `godot_path` for tests and tools (written `<godot>` below) and `godot_play` for opening the game.

## The first build (once, right after new-game)

The game still plays the template's sample story. Replace it with the student's own scene from `design/game_bible.md`, following [first_build.md](first_build.md).

## Every change

1. **Check the art first.** If `art/manifest.json` lists animation jobs that are still `pending`, use the `gamemaxxing:art` skill to check on them (it takes a moment, and finished art drops straight in).
2. **Check it against the rules** in `design/game_bible.md`. If the request breaks one of the student's own rules, say so in one line and ask which they want.
3. **One small change at a time.** If they ask for several things, list them and do them one by one, testing between each.
4. **Data before code.** Most requests are a change to `game.json`, `story.json`, `entities.json` or `level.txt` (use the Edit tool). Only touch the scripts when the data can't do it, and keep code changes small.
   - "No hitting" or "nobody gets hurt" (adventure): that's data, `"can_attack": false` and `"enemy_touch": "send_back"`; see data_guide.md.
   - Never change `tests/run_bot.gd` to make a failing test pass.
5. **Before a big change** (more than one file, or any script), save a checkpoint: `<godot> --headless --path . --script res://tools/checkpoint.gd -- save "before <what>"`.
6. **Test and save after every change:** `<godot> --headless --path . --script res://tools/checkpoint.gd -- save-tested "<what changed>"`. This runs the test bot and saves a working checkpoint only if it passes. Add passing ones to `checkpoints` in `progress.json`.
   - **`NOT SAVED`** (the bot printed `RUN FAILED: ...`): fix it, using the message, or the `build-doctor` agent if the cause isn't obvious. If it still fails after two tries, go back: `-- restore`. Tell the student in one line that you've gone back to the last working version, and try a simpler way.
7. **Log every guess** with the `gamemaxxing:decisions` skill: any name, line of dialogue, number that changes how the game feels, enemy, or colour the student didn't give you. If a change replaces an earlier guess, mark the old entry `changed: replaced by Dnn`.
8. **Show them.** Say in one line what changed and how to see it. Ask them to close the game window if it's open, then reopen it: `<godot_play> --path .` (don't wait for it to close).

## When the build stage is done

The `start` skill's table says when: the first build is in and the student has made up to three changes (or it's lunchtime). Then ask: "Anything else you want to change right now, or shall we add your art next?" and set `stage` to `art`.

## Rules

- **Placeholders are fine.** Keep the simple shapes until the art arrives; the game swaps them automatically. Don't draw art in code.
- **New behaviour needs a test.** If you add something the player must do to finish (a new key, a puzzle), update the test bot so it does it too, and check the bot still reaches an ending.
- **The test bots** take the first choice in conversations; add `-- choice=1` (or `-- choices=1,0,...`) to check the other endings after changing choices. The platformer bot checks every jump with the game's own physics, so feel changes (jump height, speed) are fine; if a level change makes it print "stuck", look at the tile it names.
- **Running behind?** If the clock says they're behind (see `gamemaxxing:start`), suggest the smallest version of the change.
- **Never** delete the student's design files, playtest notes, decision log or art.
