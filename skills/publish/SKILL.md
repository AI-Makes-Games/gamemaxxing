---
name: publish
description: Publishes the student's GameMaxxing game on the web. Use at publish time (around 4:00), or when a student wants to share their game. Tests it, exports it for web browsers, packs it into one zip, and walks the student through posting it on their own free itch.io account, click by click, until they have a public link.
---

# GameMaxxing: publish

This is **Quest 8 · Ship It**. Talk the way [tone.md](${CLAUDE_PLUGIN_ROOT}/shared/tone.md) says, and follow [quest.md](${CLAUDE_PLUGIN_ROOT}/shared/quest.md). Godot's path is `godot_path` in `gamemaxxing/progress.json` (written `<godot>` below). The itch.io steps are in [itch_steps.md](itch_steps.md).

## Steps (Claude does 1 to 5; the student does 6)

1. **Celebrate** in one line: they're about to put their own game on the internet. Say what happens next in one line: "I'll test it and pack it for the web (a couple of minutes). Then I'll walk you through putting it on itch.io, one click at a time."
2. **Web export templates:** check there's a folder starting with `4.7` in the export templates folder (Windows `%APPDATA%\Godot\export_templates\`, Mac `~/Library/Application Support/Godot/export_templates/`) holding `web_nothreads_release.zip`. If not, the student opens Godot, clicks **Editor → Manage Export Templates → Download and Install**, and waits. It's a big download, so start it as early as possible.
3. **Test and save:** `<godot> --headless --path . --script res://tools/checkpoint.gd -- save-tested "ready to publish"`. It must print `RUN COMPLETE` and save.
4. **Export for the web:**
   - Make the folder `build/web` and an empty file `build/.gdignore` (it stops Godot treating the export as part of the game).
   - Run `<godot> --headless --path . --export-release "Web" build/web/index.html`.
   - If it fails, run it once more (the first export after installing templates sometimes fails). Then check that `build/web/index.html`, `index.pck` and `index.wasm` exist.
   - If it still fails, use the `build-doctor` agent.
5. **Pack it:** `<godot> --headless --path . --script res://tools/zip_web.gd`. It prints `ZIP DONE: build/<name>-web.zip`. Give the student the zip's **full address** (they'll paste it into itch.io's file window), and open the `build` folder for them too (`explorer build` on Windows, `open build` on Mac).
   - Quick check of guesses made since the decision review (see the `decisions` skill).
6. **itch.io:** walk them through [itch_steps.md](itch_steps.md) **one step at a time**. Wait for "done" after each, and help if they get stuck.
   - They make their own free account. Never create it or type their password for them.
   - The viewport size is in `project.godot` (`viewport_width` and `viewport_height`; 1280 by 720 unless changed).
7. **Check it works:** they press Play on their itch.io page. If it doesn't load, the usual causes are in itch_steps.md.
8. **Record it:** save their game's link as `published_url` (and `quest.published_url`) in `progress.json`, award 🚀 Shipped It, set `stage` to `showcase` with its start time, and celebrate: their game is live, and here's the link to share.
9. **The finale:**
   1. Finish **Quest 8**: the check-in, the boss question offer ("Write the one line a stranger on itch.io reads. Why would they click Play?"), and the quest complete moment. They reach rank 4, Game Designer (or higher, from their Depth and boss questions).
   2. Set `quest.quest` to 9 and show their final score: rank, XP, Depth, badges.
   3. Show their **Full game list** from `design/later.md` as "Where your game could go next", and remind them this prototype is the spark: they can keep building after today.
   4. Suggest they play everyone else's games.

## Rules

- Publishing is the student's choice. They decide on the title, the description, and whether it's public. Suggest "Draft" first so they can test it privately.
- Never put the student's personal details into the page for them.
- If time is short, publishing comes before polishing: a playable game online beats a perfect one on the laptop.
