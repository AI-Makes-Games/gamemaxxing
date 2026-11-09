# The progress file: `gamemaxxing/progress.json`

Every GameMaxxing skill reads and updates this file. Keep it valid JSON. Times are local ISO times, for example `2026-11-14T09:05:00`.

```json
{
  "stage": "setup",
  "day_start": "2026-11-14T09:05:00",
  "stage_started": { "setup": "2026-11-14T09:05:00" },
  "godot_path": "",
  "godot_play": "",
  "spritecook": false,
  "template_hint": "",
  "template": "",
  "credits_start": null,
  "credits_used": 0,
  "pitch": { "attempts": 0, "passed": [], "hex_called": false },
  "scope_cut": "not_offered",
  "checkpoints": [],
  "published_url": "",
  "notes": []
}
```

| Field | Meaning |
| --- | --- |
| `stage` | One of: `setup`, `pitch`, `bible`, `art_direction`, `template`, `build`, `art`, `playtest_1`, `fix`, `playtest_2`, `publish`, `showcase` |
| `day_start` | When the student first ran `start`. All timing is measured from here. |
| `stage_started` | When each stage began, so `coach` can show time per stage |
| `godot_path` | The Godot program for tests and tools (Windows: the `_console.exe`). Skills write it as `<godot>`. |
| `godot_play` | The Godot program for opening the game so the student can play (Windows: the normal `.exe`). |
| `spritecook` | `true` once SpriteCook's tools answered |
| `template_hint` | The template the `bible` skill recommended from the main action |
| `template` | `adventure`, `platformer` or `story`, set by `new-game` once the game is copied in |
| `credits_start`, `credits_used` | SpriteCook credits at the start of the art work, and used so far |
| `pitch` | `attempts` (goes through the questions, counting the one that passed, so 1 when it passes first time), which tests passed, and whether Hex was called over |
| `published_url` | The game's itch.io link, once it's public |
| `scope_cut` | `not_offered`, `accepted` or `declined` |
| `checkpoints` | Save points: `{ "time": ..., "label": ..., "passed_bot": true }` |
| `notes` | Short notes for Hex, for example "art skill not built yet" |

Create the `gamemaxxing/` folder if it doesn't exist.
