---
name: art
description: Makes the student's game art with SpriteCook and puts it in their game. Use at the art direction stage (lock the style, make the hero and main characters), when animations finish, for props and backgrounds, or when a student asks to make or change their art. Checks credits first and stays inside the day's art budget. The game keeps its simple shapes until each piece of art is ready.
---

# GameMaxxing: art

Talk the way [tone.md](${CLAUDE_PLUGIN_ROOT}/shared/tone.md) says, and follow [quest.md](${CLAUDE_PLUGIN_ROOT}/shared/quest.md). The morning art is the rest of **Quest 3 · The Look**; the afternoon art is **Quest 5 · Bring It to Life**. What to make for each template, and what it costs, is in [budget.md](budget.md). For SpriteCook's own details (polling, downloads), follow the SpriteCook plugin's skills. Godot's path is `godot_path` in `gamemaxxing/progress.json` (written `<godot>` below).

## Before anything

1. **Is SpriteCook here?** Call its `get_credit_balance` tool. If the tool doesn't exist, tell the student in plain words to type these two lines, then sign in when asked:
   ```
   /plugin marketplace add SpriteCook/claude-plugin
   /plugin install spritecook@spritecook
   ```
   Meanwhile the game keeps its shapes, so carry on building.
2. **Budget:** if `credits_start` in `progress.json` is empty, set it to the balance. Every generation result reports what it cost (`credits_used`, or `reserved_credits` for an animation run); add each one to `credits_used` in `progress.json`. Don't work it out from the balance, which also falls when anyone else shares the account. **Stop making new art when `credits_used` reaches 650**, or when a batch would cost more than the balance. Say so kindly, keep the placeholders, and add a note for Hex.
3. Read `art_bible.json`: the `style` line, `palette`, and each character's `id` and `prompt`. Every prompt you send = the asset's prompt + the style line. Pixel art only.
4. **Credits, out in the open.** Tell the student, in two lines: how many credits they have, and roughly what their prototype's art needs (budget.md's total for their template). For example: "You have 500 art credits. Your prototype's art needs about 470. After today you can make much more." Save the balance as `quest.credits_left` (and update it after every batch). Answer `credits` the same way any time.
   - **Not enough for everything?** Make art in this order, and stop when the next item won't fit:
     1. the hero (and its animations)
     2. what gets in the way (the creatures or obstacles)
     3. props the rules or scene need (keys, doors, goals)
     4. the logo
     5. other characters
     6. extra props and backgrounds

     Tell the student what fits, in plain words, before making anything: "You have 254 credits. That covers your hero, the mailman and the logo. Everything else stays as simple shapes for now, which is fine for a prototype. Want to swap anything in that list?" Add a note for Hex.
5. **Say it before you make it.** Before each batch, say what you'll make and what it costs, and wait for "ok": "Next I'll draw your hero (12 credits). Ready?"

## Art direction (the morning): the look and the characters

1. **The hero first.** Adventure and platformer: `generate_character` with the perspective from budget.md. Story: `generate_game_art` for a portrait (see budget.md).
   - **Show it:** download it to `art/<id>_base.png` (never inside `art/<id>/`, where the frames tool would treat it as an animation) and open that file for them (`start art\<id>_base.png` on Windows, `open art/<id>_base.png` on Mac). The picture is small, so also say it'll look bigger in the game.
   - Ask: "Is this your hero? Keep it, or try again?" At most 2 tries again per character; a "try again" can change the prompt with their words.
   - When they keep it: award 🎨 Art Director, and set `quest.hero_image` to `"../art/<id>_base.png"` (and `quest.hero_name` if the hero has a name), so their hero appears on the Quest Board.
2. **Up to 3 other characters**, made together under one "ok" ("Next I'll draw the mailman, the cat and the neighbour, 36 credits. Ready?"). Show them together, and ask which to keep or try again.
3. **Record each approved character** in `art/manifest.json` (format below) with its `asset_id`.
4. **Adventure and platformer: start the animations now**, so they're ready after lunch. Run `generate_character_animations` for each approved character, with the animation list from budget.md (in a no-fighting game, leave out `attack` and `hurt`). Save each `run_id` with `status: "pending"`. Tell the student: "Your characters are being animated. That takes a while, so let's build your game meanwhile."
   **Story: put the portraits in now.** For each approved portrait, copy `art/<id>_base.png` to `art/<id>/<id>_idle.png`, then run the frames tool and import (step 3 of the next section). Mark it `done`.
5. **Finish Quest 3** as quest.md says (check-in, boss question offer, quest complete). Then set `stage` to `template` in `progress.json` (with its start time), open **Quest 4 · The Prototype**, and if `start` sent you, run `gamemaxxing:new-game`.

## The afternoon art stage (Quest 5 · Bring It to Life)

The `build` skill opens Quest 5. Show the credits (step 4 above), then check the pending animations (next section), then make the props, story backgrounds and logo (the section after). Each piece that lands is an "Unlocked!" moment: say what's new and ask them to play and look. After they play, do the check-in.

When they're all in, or the budget is used: finish Quest 5 (check-in, boss question offer, quest complete), set `stage` to `playtest_1` (the `start` skill's table says when), and open **Quest 6 · First Players**.

## When animations finish (check whenever the build skill asks, or the student does)

For each `pending` run in the manifest: `check_character_animation_run(run_id)`. A run of 2 to 5 animations usually takes 2 to 5 minutes. When its `status` is `complete`:

1. **Download** each animation's sheet to `art/<sprite id>/<sprite id>_<animation>.png`. In the result, each entry in `items` has a `preset_id` (the animation name: `idle`, `walk`, `walk_right`, `jump`, `attack`, `hurt`...) and `asset_ids`; find that asset in `assets` and download its `spritesheet_url`. Download with `curl -L -o "<file>" "<url>"` (in Windows PowerShell type `curl.exe`). Links expire, so download straight away.
2. **Check the frames.** Each sheet is a row of square frames, so its width should be a whole number times its height. If not, write `art/<id>/meta.json` with `{"frame_size": {"<animation>": [w, h]}}`.
3. **Build and load:** `<godot> --headless --path . --script res://tools/build_frames.gd -- <id>`, then `<godot> --headless --path . --import`.
4. **Test:** run the test bot (see the `build` skill), then save a passing checkpoint.
5. Mark the run `done` in the manifest, add its cost to `credits_used`, and tell the student: "✨ Unlocked: your <character> is in the game now!" Ask them to close the game window if it's open, then reopen it with `godot_play` so they can see it. After they've looked, do the check-in (quest.md).

## Props, items, backgrounds and the logo

`generate_game_art` with `pixel: true`, `bg_mode: "transparent"` (story backgrounds: `"include"`), the style line in `style`, the palette in `colors`, and the size from budget.md. Download `sprite_url` to `art/<id>/<id>_idle.png` (a one-picture "animation"), then the frames tool and import as above.

- **Story backgrounds:** also write `meta.json` with the picture's real size as the frame size.
- **The logo:** use the id `logo` (`art/logo/logo_idle.png`). The title screen shows it above the title.
- Make props in one batch, then show the student the pictures together (open the files). Only remake one if they really dislike it.

Use the same ids as `entities.json` uses for `sprite`, so the game finds the art by itself.

## `art/manifest.json`

```json
{
  "items": [
    { "id": "hero", "kind": "character", "asset_id": "...", "run_id": "...", "status": "pending",
      "animations": ["idle", "walk", "jump", "hurt"], "credits": 86 }
  ]
}
```

`status` is `approved` (made, not animated yet), `pending` (animating), `done` (in the game), or `skipped`.

## Rules

- Check the balance before every batch.
- Never remake a character for each animation. Animate the approved `asset_id`.
- If a job fails, try once more; if it fails again, keep the placeholder and add a note for Hex.
- Art never blocks the day: the student keeps building while jobs run.
