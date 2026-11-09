# Templates

Three small Godot 4.7 games. Each one plays from title screen to ending with simple placeholder shapes, and swaps in real art when it arrives.

| Template | For ideas about | Sample game |
| --- | --- | --- |
| `adventure/` | walking, exploring, talking, fighting (top-down) | The Garden Gate: find a gardener's key, then give it back or keep it (2 endings) |
| `platformer/` | running, jumping, timing (side view) | Rooftop Courier: deliver letters across the rooftops, with a hidden golden stamp (2 endings, 1 secret) |
| `story/` | reading, choosing, consequences | The Night Bakery: who gets the last loaf? (3 endings, optional countdown on a choice) |

## Where the student's game lives (data, not code)

| File | Holds |
| --- | --- |
| `game.json` | Title, tagline, colours, how the player feels (speed, health, jump), endings and their conditions |
| `story.json` | Conversations and choices: scenes with `text`, `options`, `set`/`add` flags and counters, `give`/`take` items, `next`, `end`, and `if` conditions |
| `entities.json` | Characters, creatures, items, doors, checkpoints, goals (and story backgrounds), each with the letter it uses in `level.txt` |
| `level.txt` | The map, drawn with letters (adventure and platformer). `#` wall, `~` water (adventure), `=` one-way platform and `^` spikes (platformer), `P` player start; any other letter is looked up in `entities.json` |
| `art_bible.json` | Style, colours and prompts for the art skill |

Conditions look like `met_ada`, `!met_ada`, `has:key`, `kindness>=2`, `mood=angry`, joined with `&`.

## Commands (run from the game folder; `<godot>` is the path in `gamemaxxing/progress.json`)

| What | Command |
| --- | --- |
| Test the game end to end | `<godot> --headless --path . --script res://tests/run_bot.gd` (prints `RUN COMPLETE: <ending>`, or `RUN FAILED: <why>`) |
| Test, and save a working checkpoint if it passes | `<godot> --headless --path . --script res://tools/checkpoint.gd -- save-tested "<what changed>"` |
| Save without testing / go back to the last working one / list | `... checkpoint.gd -- save "<label>"` / `-- restore` / `-- list` |
| Pack the web export for itch.io | `<godot> --headless --path . --script res://tools/zip_web.gd` |
| Turn art strips into animations | `<godot> --headless --path . --script res://tools/build_frames.gd -- <id>`, then `<godot> --headless --path . --import` |
| Export for the web | make `build/web/` and an empty `build/.gdignore`, then `<godot> --headless --path . --export-release "Web" build/web/index.html` |
| Play in a window | `<godot> --path .` |

When copying a template to a student's folder, leave out `.godot/` and `build/`.

## The test bots

All three fail straight away, with a plain message, if a data file has a mistake, a scene or `next` link is missing, or the level has uneven rows, unknown letters or not exactly one `P`. Each takes `-- choice=N` (always take choice N) or `-- choices=0,2,1` (these in order).

- **Adventure:** finds paths around walls and water, picks things up, talks to anyone with something new to say, and opens doors it can. It fights creatures that come close, or routes around them when `can_attack` is false. It stops early if a minute of play passes with no progress.
- **Platformer:** runs toward the goal and talks to anyone with something new to say. Before every jump, or step off an edge, it plays the move out with the game's own physics and only takes it if it lands safely (no spikes, no falling out). It stops early if 30 seconds pass without getting closer. A route that needs going back left, or climbing up to a goal above, can still stump it.
- **Story:** takes the chosen options. If a countdown is switched on, it lets it run out once to test what happens.
