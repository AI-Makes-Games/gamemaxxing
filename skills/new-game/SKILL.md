---
name: new-game
description: Starts the student's playable game. Use when the game bible and art direction are done and it's time to build, or when a student asks to start their game. Recommends one of three ready-made templates (top-down adventure, side-scrolling platformer, or story with choices), copies it into their folder, puts in their title and colours, tests it, and opens it so they can play.
---

# GameMaxxing: new game

This is the start of **Quest 4 · The Prototype**. Talk the way [tone.md](${CLAUDE_PLUGIN_ROOT}/shared/tone.md) says, and follow [quest.md](${CLAUDE_PLUGIN_ROOT}/shared/quest.md). If Quest 4 hasn't been opened yet, open it first, with the prototype line. The templates are in `${CLAUDE_SKILL_DIR}/templates/`. What's in them, and every command, is in [templates/README.md](templates/README.md).

## Steps

1. **Read** `gamemaxxing/progress.json` (for `godot_path` and `template_hint`), `design/game_bible.md` and `art_bible.json`. If `godot_path` is empty, run the `gamemaxxing:start` setup check first.
2. **Recommend one template** from `template_hint` (or from the bible's main action), in one line: what kind of game it is and why it fits their idea. Then say what you'll do: "I'll put a ready-made <kind> game in your folder, with your title and colours. It'll start as simple shapes. Shall I build it?" If they'd rather have another of the three, use that one.
3. **Copy the template** into the current folder. Copy everything **except** the `.godot` and `build` folders, and **don't overwrite** anything the student already has (`art_bible.json`, `design/`, `gamemaxxing/`, `playtest/`).
   - Windows (PowerShell): `robocopy "<template folder>" "." /E /XD .godot build /XC /XN /XO`. Robocopy's exit codes 0 to 7 mean success.
   - Mac: `rsync -a --ignore-existing --exclude .godot --exclude build "<template folder>/" ./`
4. **Make it theirs**, by editing data files only:
   - `game.json`: `title` is their working title. `tagline` is the Hook from `design/game_bible.md`. For `colours`, use their `art_bible.json` palette: the darkest colour for `background`, the second darkest for `panel` (the text box must stand out from the background), the lightest for `text`, a bright one for `accent`, and the closest matches for the template's other colours (floor, wall, ground...).
   - `how_to_play`: one line of controls for the title screen, matching their game (for example, leave out "Space to swing" if there's no fighting).
   - **Adventure with no fighting** (a rule like "nobody gets hurt"): set `"can_attack": false` in `player` and `"enemy_touch": "send_back"`. Being caught then sends the player back to the last checkpoint, and the hearts disappear.
   - `project.godot`: set `config/name="<their title>"` (it's the name in the window and the browser tab).
   - Log the colour choices as one guess with the `gamemaxxing:decisions` skill.
   - Leave the sample story, characters and level alone for now. The `build` skill turns them into the student's scene next.
5. **Test and save the first checkpoint:** `<godot_path> --headless --path . --import`, then `<godot_path> --headless --path . --script res://tools/checkpoint.gd -- save-tested "fresh game"`. That runs the test bot and saves only if it prints `RUN COMPLETE`. If it says `NOT SAVED`, use the `build-doctor` agent. Add the checkpoint to `checkpoints` in `progress.json`.
6. **Say what they're about to see, then open the game.** Before it opens, say:

   > Your prototype is opening. Everything is **simple coloured shapes on purpose**: studios do this to find the fun before spending time on art. Your real art drops in during Quest 5. For now it plays a short sample story with your title and colours. Next, we put **your** scene in.

   Then open it in a window, without waiting for it to close: `<godot_play> --path .`. Read them the `how_to_play` line. ⭐ +10 XP.
7. **Update `progress.json`:** set `template`, then set `stage` to `build` and add its start time to `stage_started` (`quest.quest` stays 4, `quest.step` "Your first build"). If the `start` skill sent you, run `gamemaxxing:build` with the Skill tool.

## Rules

- Never leave the student without a game that runs. If anything goes wrong, restore the checkpoint and try again.
- Keep Claude's work quiet. The student sees one line per step, not commands.
